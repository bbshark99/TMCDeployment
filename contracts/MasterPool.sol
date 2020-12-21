pragma solidity ^0.6.12;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./MyOwnable.sol";
import "./ITMC.sol";
import "./PausableStaking.sol";
import "./ITAMAGRewardCalc.sol";


// MasterChef is the master of TMC. He can make TMC and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once TMC is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterPool is MyOwnable, IERC721Receiver, PausableStaking  {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;


    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public override returns (bytes4){
        // return IERC721Receiver(0).onERC721Received.selector;
        return 0x150b7a02;
    }
    
    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        EnumerableSet.UintSet tamagIds;

        //
        // We do some fancy math here. Basically, any point in time, the amount of TMCs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accTmcPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accTmcPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.1
    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. TMCs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that TMCs distribution occurs.
        uint256 accTmcPerShare; // Accumulated TMCs per share, times 1e12. See below.
        
        IERC721 tamag;
        uint256 totalAmount;
        EnumerableSet.UintSet tamagIds;
    }

    // The TMC TOKEN!
    ITMC public tmc;
    // Dev address.
    address public devAddr;
    // divider for dev fee. 100 = 1% dev fee.
    uint256 public devFeeDivider = 100;
    // Block number when bonus TMC period ends.
    uint256 public bonusEndBlock;
    // TMC tokens created per block.
    uint256 public tmcPerBlock;
    // Bonus muliplier for early stakers.
    uint256 public constant BONUS_MULTIPLIER = 1;

    ITAMAGRewardCalc public tamagRewardCalc;

    // Info of each pool.
    PoolInfo[] private poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) private userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when TMC mining starts.
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event DepositTamag(address indexed user, uint256 indexed _pid, uint256 indexed tamagId, uint256 virtualAmt);
    
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event WithdrawTamag(address indexed user, uint256 indexed _pid, uint256 indexed tamagId);

    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdrawTamag(address indexed user, uint256 indexed _pid, uint256 indexed tamagId);

    event PoolUpdated(uint256 mintToDev, uint256 mintToPool);

    constructor(
        address _tmc,
        address _devAddr,
        uint256 _tmcPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        address _tamagRewardCalc,
        address _owner
    ) public MyOwnable(_owner){
        tmc = ITMC(_tmc);
        devAddr = _devAddr;
        tmcPerBlock = _tmcPerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
        tamagRewardCalc = ITAMAGRewardCalc(_tamagRewardCalc);

        pauseDeposit(); 
        pauseWithdraw();
    }
    function setTmc(address a) public onlyOwner{
        tmc = ITMC(a);
    }
    // MUST MASS UPDATE POOLS FIRST then u can call this!
    function setTMCPerBlock(uint256 i) public onlyOwner{
        tmcPerBlock = i;
    }
    function setTamagRewardCalc(address a) public onlyOwner {
        tamagRewardCalc = ITAMAGRewardCalc(a);

    }
    function setDevAddress(address a) public onlyOwner {
        devAddr = a;
    }

    function setDevFeeDivider(uint256 divider) public onlyOwner{
        devFeeDivider = divider;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);

        PoolInfo memory p;
        p.lpToken = _lpToken;
        p.allocPoint = _allocPoint;
        p.lastRewardBlock = lastRewardBlock;
        p.accTmcPerShare = 0;
        poolInfo.push(p);

    }
    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function addTamagPool(uint256 _allocPoint, IERC721 _tamagToken, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        PoolInfo memory p;
        p.allocPoint = _allocPoint;
        p.lastRewardBlock = lastRewardBlock;
        p.accTmcPerShare = 0;
        p.tamag = _tamagToken;
        p.totalAmount = 0;    
        poolInfo.push(p);
    }
    // Update the given pool's TMC allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        poolInfo[_pid].allocPoint = _allocPoint;
    }


    // check TAMAG traits and OG label

    // Return reward multiplier over the given _from to _to block.
    // specific to each pool
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else if (_from >= bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
                _to.sub(bonusEndBlock)
            );
        }
    }

    // View function to see pending TMCs on frontend.
    function pendingTMCForTamag(uint256 _pid, address _user, uint256 tamagId) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTmcPerShare = pool.accTmcPerShare;
        uint256 lpSupply;
        if (!isTamagPool(_pid)){
            lpSupply = pool.lpToken.balanceOf(address(this));
        }else {
            lpSupply = pool.totalAmount;
        }

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 tmcReward = multiplier.mul(tmcPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accTmcPerShare = accTmcPerShare.add(tmcReward.mul(1e12).div(lpSupply));
        }
        uint256 tamagVirtualAmount = tamagRewardCalc.getVirtualAmt(tamagId);
        return user.amount.mul(accTmcPerShare).div(1e12).sub(user.rewardDebt).mul(tamagVirtualAmount).div(user.amount);

    }

    // View function to see pending TMCs on frontend.
    function pendingTMC(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTmcPerShare = pool.accTmcPerShare;
        uint256 lpSupply;
        if (!isTamagPool(_pid)){
            lpSupply = pool.lpToken.balanceOf(address(this));
        }else {
            lpSupply = pool.totalAmount;
        }

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 tmcReward = multiplier.mul(tmcPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accTmcPerShare = accTmcPerShare.add(tmcReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accTmcPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }
    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply;
        if (!isTamagPool(_pid)){
            lpSupply = pool.lpToken.balanceOf(address(this));
        }else {
            lpSupply = pool.totalAmount;
        }

        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 tmcReward = multiplier.mul(tmcPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        tmc.mint(devAddr, tmcReward.div(devFeeDivider));
        tmc.mint(address(this), tmcReward);
        PoolUpdated(tmcReward.div(devFeeDivider),tmcReward);
        pool.accTmcPerShare = pool.accTmcPerShare.add(tmcReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }
    function getTotalStakedTamag(uint256 _pid) public view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        return pool.tamagIds.length();
    }
    function getTotalStakedTamagByIndex(uint256 _pid, uint256 index) public view  returns (uint256){
        PoolInfo storage pool = poolInfo[_pid];
        require (index < getTotalStakedTamag(_pid),"invalid index");
        return pool.tamagIds.at(index);
    }
    function getUserTotalStakedTamag(uint256 _pid) public view  returns (uint256){
        return userInfo[_pid][_msgSender()].tamagIds.length();
    }
    function getUserStakedTamagByIndex(uint256 _pid, uint256 index) public view  returns (uint256){
        require (index < getUserTotalStakedTamag(_pid),"invalid index");
        return userInfo[_pid][_msgSender()].tamagIds.at(index);
    }
    function claimTamagRewards(uint256 _pid) public whenNotPausedDeposit{
        require(isTamagPool(_pid), "not tamag pool");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];

        updatePool(_pid);

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accTmcPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeTmcTransfer(_msgSender(), pending);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accTmcPerShare).div(1e12);
    }
    function depositTamag(uint256 _pid, uint256 tamagId) public whenNotPausedDeposit{

        require(isTamagPool(_pid), "not tamag pool");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        require(!user.tamagIds.contains(tamagId), "Tamag already staked!");

        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accTmcPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeTmcTransfer(_msgSender(), pending);
            }
        }
        // convert tamag to virtual amount
        uint256 tamagVirtualAmount = tamagRewardCalc.getVirtualAmt(tamagId);
        pool.tamag.safeTransferFrom(_msgSender(), address(this), tamagId);
        user.amount = user.amount.add(tamagVirtualAmount);
        user.tamagIds.add(tamagId);
        pool.totalAmount = pool.totalAmount.add(tamagVirtualAmount);
        pool.tamagIds.add(tamagId);
        user.rewardDebt = user.amount.mul(pool.accTmcPerShare).div(1e12);
        emit DepositTamag(_msgSender(), _pid, tamagId, tamagVirtualAmount);
    }

    // Deposit LP tokens to MasterChef for TMC allocation.
    function deposit(uint256 _pid, uint256 _amount) public whenNotPausedDeposit{
        require(!isTamagPool(_pid), "not erc20 pool");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accTmcPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeTmcTransfer(_msgSender(), pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(_msgSender(), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accTmcPerShare).div(1e12);
        emit Deposit(_msgSender(), _pid, _amount);
    }

    function isTamagPool(uint256 _pid) public view returns (bool){
        PoolInfo storage pool = poolInfo[_pid];
        return address(pool.lpToken) == address(0) && address(pool.tamag) != address(0);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public whenNotPausedWithdraw{
        require(!isTamagPool(_pid), "not erc20 pool");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accTmcPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeTmcTransfer(_msgSender(), pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(_msgSender(), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accTmcPerShare).div(1e12);
        emit Withdraw(_msgSender(), _pid, _amount);
    }

    // Withdraw TAMAG tokens from MasterChef.
    function withdrawTamag(uint256 _pid, uint256 tamagId) public whenNotPausedWithdraw{

        require(isTamagPool(_pid), "not tamag pool");
        PoolInfo storage pool = poolInfo[_pid];
        require (pool.tamagIds.contains(tamagId), "pool don't have tamag");
        UserInfo storage user = userInfo[_pid][_msgSender()];
        require(user.tamagIds.contains(tamagId), "tamag not yet staked by user");
        
        updatePool(_pid);

        uint256 pending = user.amount.mul(pool.accTmcPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeTmcTransfer(_msgSender(), pending);
        }

        uint256 tamagVirtualAmount = tamagRewardCalc.getVirtualAmt(tamagId);

        user.amount = user.amount.sub(tamagVirtualAmount);
        user.tamagIds.remove(tamagId);

        pool.totalAmount = pool.totalAmount.sub(tamagVirtualAmount);
        pool.tamagIds.remove(tamagId);

        pool.tamag.safeTransferFrom(address(this), _msgSender(), tamagId);

        user.rewardDebt = user.amount.mul(pool.accTmcPerShare).div(1e12);
        emit WithdrawTamag(_msgSender(), _pid, tamagId);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(_msgSender(), amount);
        emit EmergencyWithdraw(_msgSender(), _pid, amount);
    }
    
    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdrawTamag(uint256 _pid, uint256 tamagId) public {
        require(isTamagPool(_pid), "not tamag pool");
        PoolInfo storage pool = poolInfo[_pid];
        require (pool.tamagIds.contains(tamagId), "pool don't have tamag");
        UserInfo storage user = userInfo[_pid][_msgSender()];
        require (user.tamagIds.contains(tamagId), "tamag not in pool");

        uint256 tamagVirtualAmount = tamagRewardCalc.getVirtualAmt(tamagId);

        user.amount = user.amount.sub(tamagVirtualAmount);
        user.tamagIds.remove(tamagId);

        pool.totalAmount = pool.totalAmount.sub(tamagVirtualAmount);
        pool.tamagIds.remove(tamagId);

        pool.tamag.safeTransferFrom(address(this), _msgSender(), tamagId);
        emit EmergencyWithdraw(_msgSender(), _pid, tamagId);
    }

    // Safe tmc transfer function, just in case if rounding error causes pool to not have enough TMCs.
    function safeTmcTransfer(address _to, uint256 _amount) internal {
        uint256 tmcBal = tmc.balanceOf(address(this));
        if (_amount > tmcBal) {
            tmc.transfer(_to, tmcBal);
        } else {
            tmc.transfer(_to, _amount);
        }
    }

    // utility methods for poolInfo, userInfo
    function getUserInfo(uint256 _pid, address a) public view returns (uint256, uint256){
        UserInfo storage user = userInfo[_pid][a];
        uint256 amount = user.amount;
        uint256 rewardDebt = user.rewardDebt;
        return (amount, rewardDebt);
    }
    // utility methods for poolInfo, userInfo
    function getUserInfoTamagIdSize(uint256 _pid, address a) public view returns (uint256){
        return userInfo[_pid][a].tamagIds.length();
    }
    function getUserInfoTamagIdAtIndex(uint256 _pid, address a, uint256 i) public view returns(uint256){
        return userInfo[_pid][a].tamagIds.at(i);
    }
    function getUserInfoTamagIdContains(uint256 _pid, address a, uint256 tamagId) public view returns(bool){
        return userInfo[_pid][a].tamagIds.contains(tamagId);
    }

    // utility methods for poolInfo, userInfo
    function getPool(uint256 poolIndex) public view returns (address lpToken, uint256 allocPoint, uint256 lastRewardBlock, uint256 accTmcPerShare, address tamag, uint256 totalAmount){
        PoolInfo storage pool = poolInfo[poolIndex];
        return (address(pool.lpToken), pool.allocPoint, pool.lastRewardBlock, pool.accTmcPerShare, address(pool.tamag), pool.totalAmount);
    }

    // utility methods for poolInfo, userInfo
    function getPoolTamagIdSize(uint256 poolIndex) public view returns (uint256){
        return poolInfo[poolIndex].tamagIds.length();
    }
    function getPoolTamagIdAtIndex(uint256 poolIndex, uint256 i) public view returns(uint256){
        return poolInfo[poolIndex].tamagIds.at(i);
    }
    function getPoolTamagIdContains(uint256 poolIndex, uint256 tamagId) public view returns(bool){
        return poolInfo[poolIndex].tamagIds.contains(tamagId);
    }
}