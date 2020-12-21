pragma solidity >=0.5.0;

interface ICHI {
    function freeFromUpTo(address from, uint256 value) external returns (uint256);
    function freeUpTo(uint256 value) external returns (uint256);

}