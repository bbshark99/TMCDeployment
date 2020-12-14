pragma solidity ^0.6.0; 

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/presets/ERC1155PresetMinterPauser.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155Holder.sol";
import "./ITAMAG.sol";

// 10 slots. 
// 1. hat, the rest are empty for now/
// this contract keeps track of the items assigned to equipment slots of the tamag
contract TAMAGDresser is Ownable, ERC1155Holder {
    using SafeMath for uint256;

    ERC1155PresetMinterPauser equipmentContract;
    ITAMAG tamagContract;
    uint256 public NUM_SLOTS = 20;

    mapping (uint256 => mapping(uint256 => uint256)) tamagToEquipped;
    mapping (uint256 => mapping(uint256 => address)) tamagToEquippedBy;
    mapping (uint256 => uint256) equippedTo;
    mapping (uint256 => mapping(address=>bool)) approveToEquipTamag;

    event Equipped(uint256 tamagId, uint256 equipId, uint256 slot);
    event UnEquipped(uint256 tamagId, uint256 equipId, uint256 slot);

    modifier isTamagOwner(uint256 tamagId) {
        require(tamagContract.ownerOf(tamagId) == _msgSender(), "Caller must be tamag owner");
        _;
    }

    // modifier isEquipOwner(uint256 equipId) {
    //     require(equipmentContract.ownerOf(equipId) == _msgSender(), "Caller must be equip owner");
    //     _;
    // }

    modifier isValidSlotNum(uint256 slot) {
        require(slot < NUM_SLOTS, "Invalid slot");
        _;
    }

    constructor(address _tamag, address _equipment) public{
        tamagContract = ITAMAG(_tamag);
        equipmentContract = ERC1155PresetMinterPauser(_equipment);
    }
    function setTamag(address a) public onlyOwner{
        tamagContract = ITAMAG(a);
    }
    function setTamaga(address a) public onlyOwner{
        equipmentContract = ERC1155PresetMinterPauser(a);
    }
    function setSlotNumber(uint256 slots) public onlyOwner {
        NUM_SLOTS = slots;
    }

    // convenience method for if u own both tamags and equipped both tamags
    function shiftEquipToOtherTamagOrSlot(uint256 oldTamagId, uint256 oldSlot, uint256 newTamagId, uint256 newSlot, uint256 equipId) public isTamagOwner(oldTamagId) isTamagOwner(newTamagId) isValidSlotNum(oldSlot) isValidSlotNum(newSlot){
        require(equippedTo[equipId] == oldTamagId && tamagToEquipped[oldTamagId][oldSlot] == equipId, "item not currently equipped to tamag in the right slot");
        require(tamagToEquipped[newTamagId][newSlot] == 0, "new tamag slot is occupied");
        require(tamagToEquippedBy[oldTamagId][oldSlot] == _msgSender(), "Can only shift equip u equipped");

        tamagToEquipped[oldTamagId][oldSlot] = 0;
        tamagToEquipped[newTamagId][newSlot] = equipId;
        equippedTo[equipId] = newTamagId;
        tamagToEquippedBy[oldTamagId][oldSlot] = address(0);
        tamagToEquippedBy[newTamagId][newSlot] = _msgSender();
        emit UnEquipped(oldTamagId, equipId, oldSlot);
        emit Equipped(newTamagId, equipId, newSlot);
    }

    function approveTamagEquipper(uint256 tamagId, address a, bool allowed) public isTamagOwner(tamagId) {
        approveToEquipTamag[tamagId][a] = allowed;
    }

    // you can equip your own tamag, or those you grant permission to.
    function equip(uint256 tamagId, uint256 equipId, uint256 slot) public isValidSlotNum(slot){
        require(tamagContract.ownerOf(tamagId) == _msgSender() || approveToEquipTamag[tamagId][_msgSender()], "Not allowed to equip tamag");
        equipmentContract.safeTransferFrom(_msgSender(), address(this), equipId, 1, "0x0");


        require(equippedTo[equipId] > 0, "Equip already equipped!");
        require(tamagToEquipped[tamagId][slot] == 0, "Equip slot already taken up");

        // now equip
        tamagToEquipped[tamagId][slot] = equipId;
        equippedTo[equipId] = tamagId;
        tamagToEquippedBy[tamagId][slot] = _msgSender();
        emit Equipped(tamagId, equipId, slot);
    }
    // i can unequip if: 
    // 1) i own the tamag
    // 2) the equip was equipped by me.
    function unequip(uint256 tamagId, uint256 equipId, uint256 slot) public isTamagOwner(tamagId) isValidSlotNum(slot){
        require(equippedTo[equipId] == tamagId && tamagToEquipped[tamagId][slot] == equipId, "item not currently equipped to tamag");
        require(tamagContract.ownerOf(tamagId) == _msgSender() || tamagToEquippedBy[tamagId][slot] == _msgSender(), "No permission to unequip");
        
        tamagToEquipped[tamagId][slot] = 0;
        equippedTo[equipId] = 0;
        emit UnEquipped(tamagId, equipId, slot);
        
        address a = tamagToEquippedBy[tamagId][slot];
        tamagToEquippedBy[tamagId][slot] = address(0);
        equipmentContract.safeTransferFrom(address(this), a, equipId, 1, "0x0");
    }
    function emergencyWithdraw(uint256 equipId) public onlyOwner {
        uint256 bal = equipmentContract.balanceOf(address(this), equipId);
        equipmentContract.safeTransferFrom(address(this), _msgSender(), equipId, bal, "0x0");

    }
    // for contract upgrade
    function transferAssets(uint256[] memory equipIds, address a) public onlyOwner {
        uint256[] storage balances;
        
        for (uint i = 0; i < equipIds.length; i++){
            uint256 equipId = equipIds[i];
            uint256 bal = equipmentContract.balanceOf(address(this), equipId);
            balances.push(bal);
        }
        equipmentContract.safeBatchTransferFrom(address(this), a, equipIds, balances, "0x0");
    }
}