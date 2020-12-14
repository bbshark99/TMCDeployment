pragma solidity ^0.6.12;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
abstract contract ERC20TransferLiquidityLock is ERC20, Ownable {
    using SafeMath for uint256;

    event AddLiquidity(uint256 tokenAmount, uint256 ethAmount);
    event BurnedLiquidity(uint256 balance);
    event RewardLiquidityProviders(uint256 tokenAmount);
    event BurnTokens(uint256 amt);

    event FromWhiteListed(address indexed a, bool whitelist);
    event ToWhiteListed(address indexed a, bool whitelist);
    mapping (address => bool) fromWhitelistAddresses;
    mapping (address => bool) toWhitelistAddresses;

    address public uniswapV2Router;
    address public uniswapV2Pair;

    // the amount of tokens to lock for liquidity during every transfer, i.e. 100 = 1%, 50 = 2%, 40 = 2.5%
    uint256 public liquidityLockDivisor = 25;
    uint256 public devDivisor = 4;
    uint256 public poolDivisor = 4;
    uint256 public lpRewardDivisor = 4;
    // few things to do here. out of the 4% collected per transfer:
    // 1% to dev
    // 1% burn
    // 1% to uniswap pool
    // 1% to LP holders

    address public liquidLockDevAddress;

    function setUniswapV2Router(address _uniswapV2Router) public onlyOwner {
        uniswapV2Router = _uniswapV2Router;
    }

    function setUniswapV2Pair(address _uniswapV2Pair) public onlyOwner {
        uniswapV2Pair = _uniswapV2Pair;
    }

    function setLiquidLockDevAddress(address a) internal virtual onlyOwner {
        liquidLockDevAddress = a;
    }
    function setLiquidityLockDivisor(uint256 _liquidityLockDivisor) public onlyOwner {
        liquidityLockDivisor = _liquidityLockDivisor;
    }
    function setDevDivisor(uint256 _devDivisor) public onlyOwner {
        devDivisor = _devDivisor;
    }
    function setPoolDivisor(uint256 _poolDivisor) public onlyOwner {
        poolDivisor = _poolDivisor;
    }
    function setLpRewardDivisor(uint256 _lpRewardDivisor) public onlyOwner {
        lpRewardDivisor = _lpRewardDivisor;
    }
    
    function setToWhitelistAddress(address a, bool whitelist) public onlyOwner {
        toWhitelistAddresses[a] = whitelist;
        emit ToWhiteListed(a,whitelist);
    }

    function setFromWhitelistAddress(address a, bool whitelist) public onlyOwner {
        fromWhitelistAddresses[a] = whitelist;
        emit FromWhiteListed(a,whitelist);
    }

    function _transfer(address from, address to, uint256 amount) internal virtual override{
        // calculate liquidity lock amount
        // dont transfer burn from this contract
        // or can never lock full lockable amount
        if (liquidityLockDivisor != 0 && from != address(this) && !fromWhitelistAddresses[from] && !toWhitelistAddresses[to]) {
            uint256 liquidityLockAmount = amount.div(liquidityLockDivisor);
            super._transfer(from, address(this), liquidityLockAmount); //4% goes to contract
            super._transfer(from, to, amount.sub(liquidityLockAmount));
        }
        else {
            super._transfer(from, to, amount);
        }
    }

    // receive eth from uniswap swap
    receive () external payable {}


    // few things to do here. out of the 4% collected:
    // 1% to dev
    // 1% burn
    // 1% to uniswap pool
    // 1% to LP holders

    // make sure all 3 added up postdivisor is < 100!

    function lockLiquidity(uint256 _lockableSupply) public {
        // lockable supply is the token balance of this contract
        require(_lockableSupply <= super.balanceOf(address(this)), "ERC20TransferLiquidityLock::lockLiquidity: lock amount higher than lockable balance");
        require(_lockableSupply != 0, "ERC20TransferLiquidityLock::lockLiquidity: lock amount cannot be 0");

        uint256 initialLockableSupply = _lockableSupply;
        if (devDivisor != 0){
            uint256 devAmt = initialLockableSupply.div(devDivisor);
            _lockableSupply = _lockableSupply.sub(devAmt);
            super._transfer(address(this), liquidLockDevAddress, devAmt);
        }
        if (poolDivisor != 0){
            uint256 poolAmt = initialLockableSupply.div(poolDivisor);
            _lockableSupply = _lockableSupply.sub(poolAmt);
            uint256 amountToSwapForEth = poolAmt.div(2);
            uint256 amountToAddLiquidity = poolAmt.sub(amountToSwapForEth);

            // needed in case contract already owns eth
            uint256 ethBalanceBeforeSwap = address(this).balance;
            swapTokensForEth(amountToSwapForEth);
            uint256 ethReceived = address(this).balance.sub(ethBalanceBeforeSwap);

            addLiquidity(amountToAddLiquidity, ethReceived);
            emit AddLiquidity(amountToAddLiquidity, ethReceived);
            burnLiquidity();
        }
        if (lpRewardDivisor != 0){
            uint256 lpRewardAmt = initialLockableSupply.div(lpRewardDivisor);
            _lockableSupply = _lockableSupply.sub(lpRewardAmt);
            _rewardLiquidityProviders(lpRewardAmt);
        }

        // remaining is burnt.
        _burn(address(this), _lockableSupply);
        emit BurnTokens(_lockableSupply);
        
    }

    // external util so anyone can easily distribute rewards
    // must call lockLiquidity first which automatically
    // calls _rewardLiquidityProviders
    function rewardLiquidityProviders() external {
        // lock everything that is lockable
        lockLiquidity(super.balanceOf(address(this)));
    }

    function _rewardLiquidityProviders(uint256 liquidityRewards) private {
        require(uniswapV2Pair != address(0), "uniswapV2Pair not set!");
        // avoid burn by calling super._transfer directly
        super._transfer(address(this), uniswapV2Pair, liquidityRewards);
        IUniswapV2Pair(uniswapV2Pair).sync();
        emit RewardLiquidityProviders(liquidityRewards);
    }

    function burnLiquidity() internal {
        uint256 balance = ERC20(uniswapV2Pair).balanceOf(address(this));
        require(balance != 0, "ERC20TransferLiquidityLock::burnLiquidity: burn amount cannot be 0");
        ERC20(uniswapV2Pair).transfer(address(0), balance);
        emit BurnedLiquidity(balance);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory uniswapPairPath = new address[](2);
        uniswapPairPath[0] = address(this);
        uniswapPairPath[1] = IUniswapV2Router02(uniswapV2Router).WETH();

        super._approve(address(this), uniswapV2Router, tokenAmount);

        IUniswapV2Router02(uniswapV2Router)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                uniswapPairPath,
                address(this),
                block.timestamp
            );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        super._approve(address(this), uniswapV2Router, tokenAmount);

        IUniswapV2Router02(uniswapV2Router)
            .addLiquidityETH{value: ethAmount}
            (
                address(this),
                tokenAmount,
                0,
                0,
                address(this),
                block.timestamp
            );
    }

    // returns token amount
    function lockableSupply() external view returns (uint256) {
        return super.balanceOf(address(this));
    }

    // returns token amount
    function lockedSupply() external view returns (uint256) {
        uint256 lpTotalSupply = ERC20(uniswapV2Pair).totalSupply();
        uint256 lpBalance = lockedLiquidity();
        uint256 percentOfLpTotalSupply = lpBalance.mul(1e12).div(lpTotalSupply);

        uint256 uniswapBalance = super.balanceOf(uniswapV2Pair);
        uint256 _lockedSupply = uniswapBalance.mul(percentOfLpTotalSupply).div(1e12);
        return _lockedSupply;
    }

    // returns token amount
    function burnedSupply() external view returns (uint256) {
        uint256 lpTotalSupply = ERC20(uniswapV2Pair).totalSupply();
        uint256 lpBalance = burnedLiquidity();
        uint256 percentOfLpTotalSupply = lpBalance.mul(1e12).div(lpTotalSupply);

        uint256 uniswapBalance = super.balanceOf(uniswapV2Pair);
        uint256 _burnedSupply = uniswapBalance.mul(percentOfLpTotalSupply).div(1e12);
        return _burnedSupply;
    }

    // returns LP amount, not token amount
    function burnableLiquidity() public view returns (uint256) {
        return ERC20(uniswapV2Pair).balanceOf(address(this));
    }

    // returns LP amount, not token amount
    function burnedLiquidity() public view returns (uint256) {
        return ERC20(uniswapV2Pair).balanceOf(address(0));
    }

    // returns LP amount, not token amount
    function lockedLiquidity() public view returns (uint256) {
        return burnableLiquidity().add(burnedLiquidity());
    }
}
