pragma solidity ^0.6.0;

interface ITMC{

    function mint(address to, uint256 amount) external;
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address a) external returns (uint256);
}