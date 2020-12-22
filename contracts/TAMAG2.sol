pragma solidity ^0.6.0;
import "./MyOwnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155Holder.sol";

interface EquipmentContract{
    function balanceOf(address a, uint256 id) external view returns (uint256);
    function safeBatchTransferFrom(address a, address b,uint256[] memory ids, uint256[] memory bals, bytes memory data) external;
    function safeTransferFrom(address a, address b, uint256 id, uint256 amt, bytes memory data) external;
}
contract TAMAGProperties {
    mapping (uint256 => uint256) public traits;
    mapping (uint256 => uint256) public idToNounce;
}
contract TAMAG2 is MyOwnable, Pausable, ERC721, TAMAGProperties, ERC721Burnable, ERC1155Holder {
    uint256 _tokenIds;
    address public hatchery;
    address public signerAddress;
    address public manager;

    modifier onlyManager() {
        require(_msgSender() == manager || _msgSender() == owner(), "Only manager or owner!");
        _;
    }
    modifier onlyHatchery() {
        require((_msgSender() == owner()) || (hatchery == address(0))|| (_msgSender() == hatchery), "Only owner or hatchery");
        _;
    }
    
    constructor(address _signerAddress, address owner) public MyOwnable(owner) ERC721("TAMAGV2 NiftyGotchi", "TAMAGV2") {
        signerAddress = _signerAddress;
        pause();
    }
    function exists(uint256 tokenId) public view returns (bool){
        return _exists(tokenId);
    }
    function setTokenId(uint256 i) public onlyOwner {
        _tokenIds = i;
    }
     function setHatchery(address a) public onlyOwner {
        hatchery = a;
    }
    function setSignerAddress(address a) public onlyOwner {
        signerAddress = a;
    }
    function setManagerAddress(address a) public onlyOwner {
        manager = a;
    }

    function pause() public onlyOwner {
        _pause();
    }
    function unpause() public onlyOwner {
        _unpause();
    }
    function getAndIncrementNounce(uint256 tokenId) public onlyManager returns (uint256) {
        uint256 n = idToNounce[tokenId];
        idToNounce[tokenId] += 1;
        return n;
    }
   
    function getTrait(uint256 tokenId) public view returns (uint256){
        return traits[tokenId];
    }

    // contract to be paused and set to max tokenIds first.
    function hatch(address player, uint256 trait, string memory tokenURI)
        public onlyHatchery
        whenNotPaused
        returns (uint256)
    {
        _tokenIds = _tokenIds.add(1);

        uint256 newItemId = _tokenIds;
        traits[newItemId] = trait;
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
    function managerMint(address to, uint256 id, uint256 nounce) public onlyManager{
        _mint(to, id);
        idToNounce[id] = nounce;
    }
    function managerSetTokenURI(uint256 id, string memory tokenURI) public onlyManager{
        _setTokenURI(id, tokenURI);
    }
    function managerSetTraitAndURI(uint256 id, uint256 _traits, string memory tokenURI) public onlyManager{
        _setTokenURI(id, tokenURI);
        traits[id] = _traits;
    }

   
    // stuff about equipping
    EquipmentContract public equipmentContract;
    uint256 public NUM_SLOTS = 20;
    // tamag -> slot -> equip
    mapping (uint256 => mapping(uint256 => uint256)) tamagToEquipped;
    // equip -> tamag -> slot 
    mapping (uint256 => mapping(uint256 => uint256)) equippedToTamagSlot;
    mapping (uint256 => EnumerableSet.UintSet) tamagToEquippedTma;

    function burn(uint256 tamagId) public virtual override {
        require(tamagToEquippedTma[tamagId].length() == 0, "tamag still has equips");
        super.burn(tamagId);
    }
    function getEquipAtSlot(uint256 tamagId, uint256 slot) public view isValidSlotNum(slot) returns (uint256){
        return tamagToEquipped[tamagId][slot];
    }

    function getEquippedSlot(uint256 tamagId, uint256 equipId) public view returns (uint256){
        return equippedToTamagSlot[equipId][tamagId];
    }

    event Equipped(uint256 tamagId, uint256 equipId, uint256 slot);
    event UnEquipped(uint256 tamagId, uint256 equipId, uint256 slot);

    modifier isValidSlotNum(uint256 slot) {
        require(slot > 0 && slot < NUM_SLOTS, "Invalid slot"); // slot 0 is used to indicate absence of equipment
        _;
    }

    function isEquipped(uint256 tamagId, uint256 equipId) public view returns (bool){
        return equippedToTamagSlot[equipId][tamagId] > 0; 
    }

    function setSlotNumber(uint256 slots) public onlyOwner {
        NUM_SLOTS = slots;
    }
    function setEquipmentContract(address a) public onlyOwner{
        equipmentContract = EquipmentContract(a);
    }
    function getNumEquipped(uint256 tamagId) public view returns(uint256){
        return tamagToEquippedTma[tamagId].length();
    }

    // nounce is incremented outside of this function by the manager.
    function equipNoChangeGif(address owner, uint256 tamagId, uint256 equipId, uint256 slot) public onlyManager isValidSlotNum(slot){
        equipmentContract.safeTransferFrom(owner, address(this), equipId, 1, "0x0");

        require(equippedToTamagSlot[equipId][tamagId] == 0, "Equip already equipped!");
        require(tamagToEquipped[tamagId][slot] == 0, "Equip slot already taken up");

        // now equip
        tamagToEquipped[tamagId][slot] = equipId;
        equippedToTamagSlot[equipId][tamagId] = slot;
        tamagToEquippedTma[tamagId].add(equipId);
        emit Equipped(tamagId, equipId, slot);
    }
   
    // nounce is incremented outside of this function by the manager.
    // i can unequip if: 
    // 1) i own the tamag
    // 2) the equip was equipped by me.
    function unequipNoChangeGif(address owner, uint256 tamagId, uint256 equipId, uint256 slot) public onlyManager isValidSlotNum(slot){
        require(equippedToTamagSlot[equipId][tamagId] > 0 && tamagToEquipped[tamagId][slot] == equipId, "item not currently equipped to tamag");
        
        tamagToEquipped[tamagId][slot] = 0;
        equippedToTamagSlot[equipId][tamagId] = 0;
        tamagToEquippedTma[tamagId].remove(equipId);
        emit UnEquipped(tamagId, equipId, slot);
        
        equipmentContract.safeTransferFrom(address(this), owner, equipId, 1, "0x0");
    }

}