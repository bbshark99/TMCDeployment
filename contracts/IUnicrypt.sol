pragma solidity >=0.6.0;

interface IUnicrypt {
    function depositToken(address token, uint256 amount, uint256 unlock_date) external payable;
    function withdrawToken(address token, uint256 amount) external;

    function getTokenReleaseAtIndex (address token, uint index) external view returns (uint256, uint256);
    function getUserTokenInfo (address token, address user) external view returns (uint256, uint256, uint256);
    function getUserVestingAtIndex (address token, address user, uint index) external view returns (uint256, uint256);
}