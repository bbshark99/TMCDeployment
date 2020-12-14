pragma solidity ^0.6.0;

interface ITAMAG {
    function hatch(address player, uint256 trait, string memory tokenURI) external returns (uint256);

    function getTrait(uint256 tokenId) external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);

        /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function tokenByIndex(uint256 index) external view returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function setApprovalForAll(address operator, bool _approved) external;

    function approve(address to, uint256 tokenId) external;
    
}