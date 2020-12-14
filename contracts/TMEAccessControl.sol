pragma solidity ^0.6.0;
import "@openzeppelin/contracts/access/Ownable.sol";
// main staking contract
contract TMEAccessControl is Ownable{

  
    bool public pausedHatch;

    modifier whenNotPausedHatch() {
        require(!pausedHatch, "Hatching is paused!");
        _;
    }

    modifier whenPausedHatch {
        require(pausedHatch, "Hatching is not paused!");
        _;
    }

    function pauseHatch() public onlyOwner whenNotPausedHatch {
        pausedHatch = true;
    }

    function unpauseHatch() public onlyOwner whenPausedHatch {
        pausedHatch = false;
    }

    bool public pausedIncubate;

     modifier whenNotPausedIncubate() {
        require(!pausedIncubate, "Incubate is paused!");
        _;
    }

    modifier whenPausedIncubate {
        require(pausedIncubate, "Incubate is not paused!");
        _;
    }

    function pauseIncubate() public onlyOwner whenNotPausedIncubate {
        pausedIncubate = true;
    }

    function unpauseIncubate() public onlyOwner whenPausedIncubate {
        pausedIncubate = false;
    }

}
