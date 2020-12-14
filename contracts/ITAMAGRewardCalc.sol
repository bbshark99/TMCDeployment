pragma solidity ^0.6.12;

interface ITAMAGRewardCalc{
    // make sure this amt roughly on same magnitude with 1e18
    function getVirtualAmt(uint256 tamagId) external view returns (uint256);
}