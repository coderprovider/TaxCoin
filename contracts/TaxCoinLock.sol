// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TaxCoinLock is ERC20, Ownable {
    uint256 public taxPercentage;
    uint256 public lockedTaxes;

    struct Proposal {
        string title;
        string description;
        address proposedAddress;
        uint256 startDate;
        uint256 endDate;
        uint256 totalVotes;
        uint256 sendCoinAmount;
        bool executed;
        mapping(address => bool) voted;
    }

    Proposal[] public proposals;

    event TransferTax(address from, address to, uint256 amount);
    event NewProposal(
        uint256 proposalId,
        string title,
        address proposedAddress
    );
    event VoteCast(address voter, uint256 proposalId);
    event ProposalExecuted(uint256 proposalId, address to, uint256 amount);

    constructor(
        string memory name,
        string memory symbol,
        uint256 _initialSupply,
        uint256 _taxPercentage
    ) ERC20(name, symbol) Ownable(msg.sender) {
        _mint(msg.sender, _initialSupply * (10 ** decimals()));
        taxPercentage = _taxPercentage;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint256 tax = (amount * taxPercentage) / 100;
        uint256 amountAfterTax = amount - tax;

        lockedTaxes += tax;
        super.transfer(recipient, amountAfterTax);

        emit TransferTax(_msgSender(), recipient, tax);
        return true;
    }

    function createProposal(
        string memory _title,
        string memory _description,
        address _proposedAddress,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _sendCoinAmount
    ) public onlyOwner {
        require(_proposedAddress != address(0), "Invalid address");
        require(_endDate > _startDate, "End date must be after start date");
        require(_sendCoinAmount > lockedTaxes, "Invalid amount");

        proposals.push();
        uint256 proposalId = proposals.length - 1;

        Proposal storage proposal = proposals[proposalId];
        proposal.title = _title;
        proposal.description = _description;
        proposal.proposedAddress = _proposedAddress;
        proposal.startDate = _startDate;
        proposal.endDate = _endDate;
        proposal.executed = false;
        proposal.sendCoinAmount = _sendCoinAmount;

        emit NewProposal(proposalId, _title, _proposedAddress);
    }

    function vote(uint256 proposalId) public {
        Proposal storage proposal = proposals[proposalId];
        require(
            block.timestamp >= proposal.startDate,
            "Voting has not started"
        );
        require(block.timestamp <= proposal.endDate, "Voting has ended");
        require(!proposal.voted[msg.sender], "You have already voted");

        proposal.voted[msg.sender] = true;
        proposal.totalVotes++;

        emit VoteCast(msg.sender, proposalId);
    }

    function executeProposal(uint256 proposalId) public onlyOwner {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp > proposal.endDate, "Voting has not ended");
        require(!proposal.executed, "Proposal already executed");
        require(proposal.sendCoinAmount > 0, "No locked taxes available");

        // uint256 taxesToSend = proposal.sendCoinAmount;
        lockedTaxes = lockedTaxes - proposal.sendCoinAmount;

        _transfer(
            address(this),
            proposal.proposedAddress,
            proposal.sendCoinAmount
        );
        proposal.executed = true;

        emit ProposalExecuted(
            proposalId,
            proposal.proposedAddress,
            proposal.sendCoinAmount
        );
    }

    // function withdrawRemainingTaxes() public onlyOwner {
    //     require(lockedTaxes > 0, "No taxes to withdraw");
    //     uint256 amount = lockedTaxes;
    //     lockedTaxes = 0;
    //     _transfer(address(this), owner(), amount);
    // }
}
