pragma solidity ^0.6.12;

import "@openzeppelin/contracts/presets/ERC20PresetMinterPauser.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "./ERC20Governance.sol";
import "./ERC20TransferLiquidityLock.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "./IUnicrypt.sol";

contract TMC is 
    ERC20PresetMinterPauser("TMC NiftyGotchi", "TMC"), 
    Ownable,
    // governance must be before transfer liquidity lock
    // or delegates are not updated correctly
    // ERC20Governance,
    ERC20TransferLiquidityLock
{

    bool public initialized = false;
    // function initialize0(uint256 amtTMC, uint256 amtTME, address routerAdd, address tme) public onlyOwner{
    //     _approve(address(this), routerAdd, amtTMC);

    //     IERC20 tmeTok = IERC20(tme);
    //     tmeTok.approve(routerAdd, amtTME);
    // }
    address public uniswapTMETMCPair;
    function initialize(uint256 amtTMC, uint256 amtTME, address routerAdd, address factoryAdd, address tme) public onlyOwner{
        require (!initialized, "Already initialized");
        // mint, pair with TME, send to uniswap.
        // prepare TMC
        mint(address(this), amtTMC);
        _approve(address(this), routerAdd, amtTMC);

        // prepare TME
        IERC20 tmeTok = IERC20(tme);
        require(tmeTok.balanceOf(address(this)) >= amtTME, "contract needs more TME");
        tmeTok.approve(routerAdd, amtTME);

        IUniswapV2Factory fac = IUniswapV2Factory(factoryAdd);
        uniswapTMETMCPair = fac.createPair(address(this), tme);

        IUniswapV2Router02(routerAdd).addLiquidity(address(this), tme, amtTMC, amtTME, 0, 0, address(this),block.timestamp);
        uint256 amtLPheld = IUniswapV2Pair(uniswapTMETMCPair).balanceOf(address(this));
        IUniswapV2Pair(uniswapTMETMCPair).transfer(_msgSender(), amtLPheld);
        setToWhitelistAddress(uniswapTMETMCPair,true);
        setFromWhitelistAddress(uniswapTMETMCPair,true);
        // send LP to owner, owner manually lock
        // if (pol != address(0)){
        //     IUniswapV2Pair(uniswapTMETMCPair).approve(pol,amtLPheld);
        //     IUnicrypt(pol).depositToken(uniswapTMETMCPair, amtLPheld, block.timestamp.add(lockDuration));
        // }
        _pause();
        initialized = true;
    }
    
    // function claimLiquidity(address pol, address uniswapPair) public onlyOwner{
    //     (uint256 timeStamp, uint256 amtClaimable) = IUnicrypt(pol).getUserVestingAtIndex(uniswapPair, address(this),0);
    //     require(block.timestamp >= timeStamp, "Not claimable yet!");

    //     IUnicrypt(pol).withdrawToken(uniswapPair, amtClaimable);
    //     IUniswapV2Pair pair = IUniswapV2Pair(uniswapPair);
    //     uint amtLPheld = pair.balanceOf(address(this));
    //     pair.transfer(owner(), amtLPheld);
    // }   

    constructor() public{
        super.setLiquidLockDevAddress(_msgSender());
    }
    function setUniswapTMETMCPair(address a) public onlyOwner {
        uniswapTMETMCPair = a;
    }
    function _transfer(address from, address to, uint256 amount) internal virtual override(ERC20, ERC20TransferLiquidityLock) {
        super._transfer(from,to,amount);
    }
    function _mint(address to, uint256 amount) internal virtual override(ERC20) {
        super._mint(to,amount);
    }
    function _burn(address account, uint256 amount) internal virtual override(ERC20) {
        super._burn(account,amount);
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20, ERC20PresetMinterPauser) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function addMinter(address a) public onlyOwner {
        grantRole(MINTER_ROLE, a);
    }
    function addPauser(address a) public onlyOwner {
        grantRole(PAUSER_ROLE, a);
    }
    function revokeMinter(address a) public onlyOwner {
        revokeRole(MINTER_ROLE, a);
    }
    function revokePauser(address a) public onlyOwner {
        revokeRole(PAUSER_ROLE, a);
    }


}