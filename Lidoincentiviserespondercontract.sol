responder contract 

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LidoIncentiveResponder {
    address public owner;
    address public partner;

    event Initialized(address owner, address partner);
    event IncentiveForwarded(uint256 amount, address partner);

    // Accept ETH to forward
    receive() external payable {}

    /// @notice Initialize owner and partner (callable only once)
    function initialize(address _owner, address _partner) external {
        require(owner == address(0), "Already initialized");
        require(_owner != address(0) && _partner != address(0), "Zero address");
        owner = _owner;
        partner = _partner;
        emit Initialized(_owner, _partner);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    /// @notice Called by Drosera to forward incentives
    function respondWithIncentive(uint256 amount) external onlyOwner {
        require(amount > 0, "Zero amount");
        require(address(this).balance >= amount, "Insufficient funds");
        (bool success, ) = partner.call{value: amount}("");
        require(success, "Transfer failed");
        emit IncentiveForwarded(amount, partner);
    }

    /// @notice Change partner address (owner only)
    function setPartner(address _partner) external onlyOwner {
        require(_partner != address(0), "Zero address");
        partner = _partner;
    }
}