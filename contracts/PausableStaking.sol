pragma solidity ^0.6.0;
import "@openzeppelin/contracts/access/Ownable.sol";

contract PausableStaking is Ownable{
  
    bool public pausedDeposit;
    bool public pausedWithdraw;

    modifier whenNotPausedDeposit() {
        require(!pausedDeposit, "Deposit is paused!");
        _;
    }

    modifier whenPausedDeposit {
        require(pausedDeposit, "Deposit is not paused!");
        _;
    }

    function pauseDeposit() public onlyOwner whenNotPausedDeposit {
        pausedDeposit = true;
    }

    function unpauseDeposit() public onlyOwner whenPausedDeposit {
        pausedDeposit = false;
    }


     modifier whenNotPausedWithdraw() {
        require(!pausedWithdraw, "Incubate is paused!");
        _;
    }

    modifier whenPausedWithdraw {
        require(pausedWithdraw, "Incubate is not paused!");
        _;
    }

    function pauseWithdraw() public onlyOwner whenNotPausedWithdraw {
        pausedWithdraw = true;
    }

    function unpauseWithdraw() public onlyOwner whenPausedWithdraw {
        pausedWithdraw = false;
    }



}
