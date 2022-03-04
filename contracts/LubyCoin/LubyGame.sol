pragma solidity ^0.8.11;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "hardhat/console.sol";
import "./Bank.sol";

// Interface do customToken

contract LubyGame is ERC20, Ownable {
	event StartGame(address from, uint256 amount);
	event WithDraw(address from, address to, uint256 amount);
	event ClaimBalance(address from, address to, uint256 amount);

	mapping(address => uint256) private individualBalance;

	Token bank;

	constructor() {
		bank = Token(address(this));
	}

	function mintLbc(uint256 amount) public returns (bool) {
		Token contractAddress = Token(address(this));

		contractAddress.mint(msg.sender, amount);

		return true;
	}

	function startGame(uint256 amount) public {
		bank.transferFrom(msg.sender, address(this), amount);

		individualBalance[msg.sender] += amount;

		emit StartGame(msg.sender, amount);
	}

	function correctAnswer(uint256 amount) public virtual {
		uint256 value = amount;

		individualBalance[msg.sender] += value;
	}

	function incorrectAnswer(uint256 amount) public virtual {
		uint256 value = amount;

		individualBalance[msg.sender] -= value;
	}

	function withdraw() public onlyOwner {
		uint256 balance = bank.getBalance(msg.sender);
		require(balance > 0, "Balance is 0");

		bank.transfer(msg.sender, balance);

		emit WithDraw(address(this), msg.sender, balance);
	}

	function claimBalance(uint256 bonus) public {
		require(individualBalance[msg.sender] > 0, "Individual balance is 0!");

		bank.transfer(msg.sender, individualBalance[msg.sender] + bonus);

		individualBalance[msg.sender] = 0;

		emit ClaimBalance(
			address(this),
			msg.sender,
			individualBalance[msg.sender] + bonus
		);
	}

	function getBalanceIndividual() public view returns (uint256 balance) {
		return individualBalance[msg.sender];
	}
}
