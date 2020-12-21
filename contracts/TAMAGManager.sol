pragma solidity ^0.6.0;
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "./MyOwnable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155Holder.sol";
import "./ICHI.sol";

interface OldTAMAG {

    function getTrait(uint256 tokenId) external view returns (uint256);
    function idToNounce(uint256 tokenId) external view returns (uint256);
    function burn(uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
    function tokenURI(uint256 tokenId) external view returns (string memory);

}
interface ITAMAG2 {
    function ownerOf(uint256 tokenId) external view returns (address);
    function managerMint(address to, uint256 id, uint256 nounce) external;
    function managerSetTokenURI(uint256 id, string memory tokenURI) external;
    function managerSetTraitAndURI(uint256 id, uint256 _traits, string memory tokenURI) external;
    function getAndIncrementNounce(uint256 tokenId) external returns (uint256);
    function equipNoChangeGif(address owner, uint256 tamagId, uint256 equipId, uint256 slot) external;
    function unequipNoChangeGif(address owner, uint256 tamagId, uint256 equipId, uint256 slot) external;
}

// manage metadata changes and upgrades to v2 and minting new v2
contract TAMAGManager is MyOwnable{
    address public signerAddress;
    OldTAMAG public oldTamag;
    ITAMAG2 public newTamag;
    ICHI chi;
    
   modifier discountCHI {
        uint256 gasStart = gasleft();
        _;
        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 *
                        msg.data.length;
        chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41947);
    }
    constructor(address _signerAddress, address owner, address _oldTamag, address _newTamag, address _chi) public MyOwnable(owner) {
    // constructor(address _signerAddress, address owner, address _oldTamag, address _newTamag) public MyOwnable(owner) {
        signerAddress = _signerAddress;
        oldTamag = OldTAMAG(_oldTamag);
        newTamag = ITAMAG2(_newTamag);
        chi = ICHI(_chi);
    }

    function setOldTamagContract(address a) public onlyOwner{
        oldTamag = OldTAMAG(a);
    }
    function setNewTamagContract(address a) public onlyOwner{
        newTamag = ITAMAG2(a);
    }
   function setSignerAddress(address a) public onlyOwner {
        signerAddress = a;
    }
    modifier isTamagOwner(uint256 tamagId) {
        require(newTamag.ownerOf(tamagId) == _msgSender(), "Caller must be tamag owner");
        _;
    }
    // includes using a new tokenUri for the new gif style
    function upgradeOldTamag(uint256 oldTamagId, string memory tokenURI, uint8 v, bytes32 r, bytes32 s) public discountCHI {
        require(oldTamag.ownerOf(oldTamagId) == _msgSender());
        // oldTamagContract.safeTransferFrom(_msgSender(), address(this), oldTamagId);

        // transfer traits, id, nounce,
        uint256 oldTraits = oldTamag.getTrait(oldTamagId);
        uint256 oldNounce = oldTamag.idToNounce(oldTamagId);

        newTamag.managerMint(_msgSender(), oldTamagId, oldNounce + 1);

        bytes32 hashInSignature = prefixed(keccak256(abi.encodePacked("V2UPGRADE_",oldNounce,"_",oldTamagId,"_",tokenURI)));
        address signer = ecrecover(hashInSignature, v, r, s);
        require(signer == signerAddress, "Msg needs to be signed by valid signer!");

        newTamag.managerSetTraitAndURI(oldTamagId, oldTraits, tokenURI);
        oldTamag.burn(oldTamagId);
    }
    
    // assumes hash is always 32 bytes long as it is a keccak output
    function prefixed(bytes32 myHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", myHash));
    }

    // requires both owner and dev to participate in this;
    function setMetadataByUser(uint256 tamagId, uint256 newTraits, string memory tokenURI, uint8 v, bytes32 r, bytes32 s) public discountCHI isTamagOwner(tamagId){
        uint256 currNounce = newTamag.getAndIncrementNounce(tamagId);

        bytes32 hashInSignature = prefixed(keccak256(abi.encodePacked(currNounce,"_",newTraits,"_",tamagId,"_",tokenURI)));
        address signer = ecrecover(hashInSignature, v, r, s);
        require(signer == signerAddress, "Msg needs to be signed by valid signer!");
        
        newTamag.managerSetTraitAndURI(tamagId, newTraits, tokenURI);
    }

    function equip(uint256 tamagId, uint256 equipId, uint256 slot, string memory tokenURI, uint8 v, bytes32 r, bytes32 s) public discountCHI isTamagOwner(tamagId) {
        newTamag.equipNoChangeGif(_msgSender(), tamagId, equipId, slot);

        // now change the gif
        uint256 currNounce = newTamag.getAndIncrementNounce(tamagId);

        bytes32 hashInSignature = prefixed(keccak256(abi.encodePacked(currNounce,"_",tamagId,"_",equipId,"_",slot,"_",tokenURI)));
        address signer = ecrecover(hashInSignature, v, r, s);
        require(signer == signerAddress, "Msg needs to be signed by valid signer!");
        
        newTamag.managerSetTokenURI(tamagId, tokenURI);
    }

    function unequip(uint256 tamagId, uint256 equipId, uint256 slot, string memory tokenURI, uint8 v, bytes32 r, bytes32 s) public discountCHI isTamagOwner(tamagId) {
        newTamag.unequipNoChangeGif(_msgSender(), tamagId, equipId, slot);

        // now change the gif
        uint256 currNounce = newTamag.getAndIncrementNounce(tamagId);

        bytes32 hashInSignature = prefixed(keccak256(abi.encodePacked(currNounce,"_",tamagId,"_",equipId,"_",slot,"_",tokenURI)));
        address signer = ecrecover(hashInSignature, v, r, s);
        require(signer == signerAddress, "Msg needs to be signed by valid signer!");
        
        newTamag.managerSetTokenURI(tamagId, tokenURI);
    }

    function close() public onlyOwner { 
        address payable p = payable(owner());
        selfdestruct(p); 
    }

}