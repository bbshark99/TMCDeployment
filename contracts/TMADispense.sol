pragma solidity ^0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./MyOwnable.sol";
// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155Holder.sol";
import "./ICHI.sol";

interface IERC1155 {
    // function mint(address to, uint256 id, uint256 amount, bytes memory data) external;
    function balanceOf(address a, uint256 id) external returns (uint256);
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;
}

interface IERC20{
    function mint(address to, uint256 amount) external;
    function balanceOf(address a) external returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
// to dispense stuff for a certian TMC price.
contract TMADispense is 
    MyOwnable, ERC1155Holder
{
    using SafeMath for uint256;
    // using SafeERC20 for IERC20;

    IERC1155 public tma;
    IERC20 public tmc;
    ICHI public chi;

    modifier discountCHI {
        uint256 gasStart = gasleft();
        _;
        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 *
                        msg.data.length;
        chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41947);
    }

    mapping (address => mapping(uint256 => uint256)) public purchasedPerAcc; // address => tokenId => amt sold
    // mapping (uint256 => bool) public forSale; // equipId => bool
    // mapping (uint256 => uint256) public amtSold; // equipId => amtSold
    // mapping (uint256 => uint256) public capPerAcc; // equipId => cap

    struct EquipSales {
        bool isForSale;
        uint256 amtSold;
        uint256 capPerAdd; // 0 means no cap
        uint256 tmcForEach; // 0 means free
        bool isExists;
    }
    mapping (uint256 => EquipSales) public allSales;
    mapping (address => bool) public authorizedClaimer;


    modifier onlyOwnerOrAuthorised() {
        require(owner() == _msgSender() || authorizedClaimer[address(_msgSender())], "Ownable: caller is not the owner");
        _;
    }

    constructor(address owner, address _tma, address _tmc, address _chi) public MyOwnable(owner) {
        tma = IERC1155(_tma);
        tmc = IERC20(_tmc);
        chi = ICHI(_chi);
    }

    function setAuthorized(address a, bool b) public onlyOwner{
        authorizedClaimer[a] = b;
    }

    function setSalesInfo(uint256 equipId, bool forSale, uint256 capPerAdd, uint256 tmcForEach) public onlyOwner {
        require(allSales[equipId].isExists, "No such sales");
        allSales[equipId].isForSale = forSale;
        allSales[equipId].capPerAdd = capPerAdd;
        allSales[equipId].tmcForEach = tmcForEach;
    }
    
    function exchange(uint256 equipId, uint256 amtToReceive) public discountCHI{
        EquipSales memory m = allSales[equipId];
        require(tma.balanceOf(address(this), equipId) >= amtToReceive, "No equip left");
        require(m.isForSale, "Not for sale");
        uint256 purchased = purchasedPerAcc[address(_msgSender())][equipId];
        uint256 afterPurchase = purchased.add(amtToReceive);
        require (m.capPerAdd == 0 || afterPurchase <= m.capPerAdd, "Cap met");
        if (m.tmcForEach > 0){
            require(tmc.transferFrom(_msgSender(), address(this), amtToReceive.mul(m.tmcForEach)), "Failed to transfer TMC");
        }
        purchasedPerAcc[_msgSender()][equipId] = afterPurchase;
        m.amtSold += amtToReceive;

        tma.safeTransferFrom(address(this), _msgSender(), equipId, amtToReceive, "0x0");
    }
    function createSales(uint256 equipId, bool b, uint256 capPerAdd, uint256 tmcForEach) public onlyOwner{
        allSales[equipId] = EquipSales(b, 0, capPerAdd, tmcForEach, true);
    }

    function close() public onlyOwner { 
        address payable p = payable(owner());
        selfdestruct(p); 
    }
    function claimProceeds() public onlyOwnerOrAuthorised{
        uint256 b = tmc.balanceOf(address(this));
        tmc.transferFrom(address(this), _msgSender(), b);
    }
    function claimERC1155(address a, uint256 equipId) public onlyOwner {
        IERC1155 token = IERC1155(a);
        uint256 bal = token.balanceOf(address(this), equipId);
        IERC1155(a).safeTransferFrom(address(this), _msgSender(), equipId, bal, "0x0");
    }
    function setTma(address a) public onlyOwner {
        tma = IERC1155(a);
    }
    function setTmc(address a) public onlyOwner {
        tmc = IERC20(a);
    }
}