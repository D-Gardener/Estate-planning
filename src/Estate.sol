//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract Ownable {
    address owner = msg.sender;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

contract Mortal is Ownable {
    function kill() public onlyOwner {
        selfdestruct(msg.sender);
    }
}

contract Estate is Mortal {
    address beneficiary;
    uint256 public waitingPeriodLength;
    uint256 public endOfWaitingPeriod;

    event Challenge(uint256 endOfWaitingPeriod);

    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary);
        _;
    }

    modifier heartbeat() {
        _;
        endOfWaitingPeriod = 10 ** 18;
    }

    constructor(address _beneficiary, uint256 _waitingPeriodLength) public heartbeat {
        waitingPeriodLength = _waitingPeriodLength;

    }
        
    function assertDeath() public onlyBeneficiary {
        endOfWaitingPeriod = block.timestamp + (waitingPeriodLength * 1 seconds);
        emit Challenge(endOfWaitingPeriod);
    }

    function claimInheritance(address newBeneficiary) public onlyBeneficiary heartbeat {
        require(block.timestamp >= endOfWaitingPeriod);

        owner = beneficiary;
        beneficiary = newBeneficiary;
    }

    function deposit(uint256 _amount) public payable onlyOwner heartbeat {}

    function withdraw(uint256 _amount) public onlyOwner {
        (bool sent, ) = msg.sender.call{ value: _amount }("");
        require(sent);
    } 
}