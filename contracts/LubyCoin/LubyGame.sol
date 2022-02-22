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
		// TransferFrom é para tirar da carteira (precisa aprovação) e mandar para o contrato.

		bank.transferFrom(msg.sender, address(this), amount);

		individualBalance[msg.sender] += amount;

		emit StartGame(msg.sender, amount);
	}

	function correctAnswer(uint256 amount) public virtual {
		// require(individualBalance[msg.sender] > 0, "Invidual balance is 0");
		uint256 value = amount;

		// Transfer é para mover do contrato e enviar para uma carteira.
		// bank.transfer(msg.sender, value);
		individualBalance[msg.sender] += value;
		//bank.discountBalanceIndividual(msg.sender, amount);
	}

	function incorrectAnswer(uint256 amount) public virtual {
		// require(individualBalance[msg.sender] > 0, "Invidual balance is 0");
		uint256 value = amount;

		// Transfer é para mover do contrato e enviar para uma carteira.
		// bank.transfer(msg.sender, value);
		individualBalance[msg.sender] -= value;
		//bank.discountBalanceIndividual(msg.sender, amount);
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

	// function winGame(address _tokenContract, uint256 bonus)
	// 	public
	// 	returns (uint256)
	// {
	// 	require(individualBalance[msg.sender] > 0, "Invidual balance is 0");
	// 	uint256 value = individualBalance[msg.sender];

	// 	ILBC tokenContract = ILBC(_tokenContract);

	// 	tokenContract.transfer(msg.sender, value + bonus);
	// 	// tokenContract.transfer(msg.sender, value + bonus);

	// 	individualBalance[msg.sender] = 0;
	// 	balances -= value;
	// 	return value;
	// }

	// function withdraw(address _tokenContract) public onlyOwner {
	// 	// require(balances > 0, "Balance is 0");

	// 	ILBC tokenContract = ILBC(_tokenContract);

	// 	tokenContract.transfer(msg.sender, balances);

	// 	// This transfer only ETHER
	// 	// payable(owner()).transfer(balances);

	// 	emit WithDraw(msg.sender, balances);

	// 	balances = 0;
	// }

	// function getBalance() public view onlyOwner returns (uint256) {
	// 	return balances;
	// }

	// function getBalanceIndividual() external view returns (uint256) {
	// 	return individualBalance[msg.sender];
	// }
}
