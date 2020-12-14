pragma solidity ^0.6.0;
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./ITAMAG.sol";

contract TAMAGProperties {
    mapping (uint256 => uint256) traits;
    mapping (uint256 => uint256) public idToNounce;

}

contract TAMAG2 is ERC721, TAMAGProperties, ERC721Burnable, ERC1155Holder, Ownable, Pausable{
    using Counters for Counters.Counter;
    uint256 _tokenIds;
    address public hatchery;
    address public signerAddress;

    modifier onlyHatchery() {
        require((_msgSender() == owner()) || (hatchery == address(0))|| (_msgSender() == hatchery), "Only owner or hatchery");
        _;
    }
    
    constructor(address _signerAddress) public ERC721("TAMAG NiftyGotchi", "TAMAG") TAMAGProperties() {
        signerAddress = _signerAddress;
    }

    // function create(uint256 trait, string memory tokenURI) public onlyOwner {
    //     _tokenIds.increment();
    //     uint256 newItemId = _tokenIds.current();
    //     traits[newItemId] = trait;
    //     _mint(msg.sender, newItemId);
    //     _setTokenURI(newItemId, tokenURI);
    // }
    ITAMAG oldTamagContract;
    function setOldTamagContract(address a) public onlyOwner{
        oldTamagContract = ITAMAG(a);
    }
    function setTokenId(uint256 i) public onlyOwner {
        _tokenIds = i;
    }
    
    function pause() public onlyOwner {
        _pause();
    }
    function unpause() public onlyOwner {
        _unpause();
    }

    function upgradeOldTamag(uint256 oldTamagId) public {
        require(oldTamagContract.ownerOf(oldTamagId) == _msgSender());
        oldTamagContract.safeTransferFrom(_msgSender(), address(this), oldTamagId);

        // transfer traits, id, nounce,
        uint256 oldTraits = oldTamagContract.traits(oldTamagId);
        uint256 oldNounce = idToNounce[oldTamagId];

        _mint(_msgSender(), oldTamagId);
        traits[oldTamagId] = oldTraits;
        idToNounce[oldTamagId] = oldTamagContract.idToNounce(oldTamagId);
        _setTokenURI(oldTamagId, oldTamagContract.tokenURI(oldTamagId));

        oldTamagContract.burn(oldTamagId);
    }
    // contract to be paused and set to max tokenIds first.
    function hatch(address player, uint256 trait, string memory tokenURI)
        public onlyHatchery
        whenNotPaused
        returns (uint256)
    {
        _tokenIds.add(1);

        uint256 newItemId = _tokenIds;
        traits[newItemId] = trait;
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    function getTrait(uint256 tokenId) public view returns (uint256){
        return traits[tokenId];
    }
    
    // assumes hash is always 32 bytes long as it is a keccak output
    function prefixed(bytes32 myHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", myHash));
    }

    // requires both owner and dev to participate in this;
    function setMetadataByUser(uint256 tokenId, uint256 newTraits, string memory tokenURI, uint8 v, bytes32 r, bytes32 s) public whenNotPaused{
        require(ownerOf(tokenId) == msg.sender, "Only owner can change tokenURI");

        uint256 currNounce = idToNounce[tokenId];

        bytes32 hashInSignature = prefixed(keccak256(abi.encodePacked(currNounce,"_",newTraits,"_",tokenId,"_",tokenURI)));
        address signer = ecrecover(hashInSignature, v, r, s);
        require(signer == signerAddress, "Msg needs to be signed by valid signer!");
        
        idToNounce[tokenId] += 1;

        _setTokenURI(tokenId, tokenURI);
        traits[tokenId] = newTraits;
    }

    function setHatchery(address a) public onlyOwner {
        hatchery = a;
    }
    function setSignerAddress(address a) public onlyOwner {
        signerAddress = a;
    }

    // stuff about equipping
    // ERC1155PresetMinterPauser public equipmentContract;
    // uint256 public NUM_SLOTS = 20;
    // mapping (uint256 => mapping(uint256 => uint256)) tamagToEquipped;
    // mapping (uint256 => mapping(uint256 => address)) tamagToEquippedBy;
    // mapping (uint256 => uint256) equippedTo;
    // mapping (uint256 => mapping(address=>bool)) approveToEquipTamag;

    // event Equipped(uint256 tamagId, uint256 equipId, uint256 slot);
    // event UnEquipped(uint256 tamagId, uint256 equipId, uint256 slot);
    // modifier isValidSlotNum(uint256 slot) {
    //     require(slot < NUM_SLOTS, "Invalid slot");
    //     _;
    // }
    // function setSlotNumber(uint256 slots) public onlyOwner {
    //     NUM_SLOTS = slots;
    // }
    // function setTamaga(address a) public onlyOwner{
    //     equipmentContract = ERC1155PresetMinterPauser(a);
    // }
    // function equip(uint256 tamagId, uint256 equipId) 
}