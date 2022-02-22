pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "hardhat/console.sol";

// Interface do customToken
interface ILBC {
	function totalSupply() external view returns (uint256);

	function balanceOf(address account) external view returns (uint256);

	function allowance(address owner, address spender)
		external
		view
		returns (uint256);

	function _transfer(
		address from,
		address to,
		uint256 amount
	) external;

	function transfer(address _to, uint256 _amount) external returns (bool);

	function approve(address spender, uint256 amount) external returns (bool);

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(
		address indexed owner,
		address indexed spender,
		uint256 value
	);
}

contract LubyCoin is ERC20, Ownable {
	address public minter;
	uint256 public balances;
	uint256 public supply;

	mapping(address => uint256) private individualBalance;

	event StartGame(address indexed from, uint256 value);
	event WithDraw(address indexed to, uint256 value);

	// uint256 public minRate = 0.005 ether;

	constructor() ERC20("Luby Coin", "LBC") {
		minter = msg.sender;
		// balances += 10 * 10**18;
		// supply += balances;
	}

	function mint(uint256 amount) public {
		require(
			individualBalance[msg.sender] == 0,
			"Voce ja tem LBC em carteira!"
		);
		_mint(msg.sender, amount);
		supply += amount;
	}

	function startGame(address _tokenContract, uint256 amount) public {
		individualBalance[msg.sender] += amount;

		balances += amount;

		ILBC tokenContract = ILBC(_tokenContract);

		// TransferFrom é para tirar da carteira (precisa aprovação) e mandar para o contrato.
		tokenContract.transferFrom(msg.sender, _tokenContract, amount);

		// testar esse
		// tokenContract.transfer(recipient, amount);

		emit StartGame(msg.sender, amount);
	}

	function quitGame(address _tokenContract, uint256 amount) public virtual {
		require(individualBalance[msg.sender] > 0, "Invidual balance is 0");
		uint256 value = amount;

		ILBC tokenContract = ILBC(_tokenContract);

		// Transfer é para mover do contrato e enviar para uma carteira.
		tokenContract.transfer(msg.sender, value);

		balances -= value;
		individualBalance[msg.sender] -= value;
	}

	function winGame(address _tokenContract, uint256 bonus)
		public
		returns (uint256)
	{
		require(individualBalance[msg.sender] > 0, "Invidual balance is 0");
		uint256 value = individualBalance[msg.sender];

		ILBC tokenContract = ILBC(_tokenContract);

		tokenContract.transfer(msg.sender, value + bonus);
		// tokenContract.transfer(msg.sender, value + bonus);

		individualBalance[msg.sender] = 0;
		balances -= value;
		return value;
	}

	function withdraw(address _tokenContract) public onlyOwner {
		// require(balances > 0, "Balance is 0");

		ILBC tokenContract = ILBC(_tokenContract);

		tokenContract.transfer(msg.sender, balances);

		// This transfer only ETHER
		// payable(owner()).transfer(balances);

		emit WithDraw(msg.sender, balances);

		balances = 0;
	}

	// function approve(
	// 	address _tokenContract,
	// 	address spender,
	// 	uint256 amount
	// ) external onlyOwner returns (bool) {
	// 	ILBC tokenContract = ILBC(_tokenContract);

	// 	tokenContract.approve(spender, amount);
	// }

	function getBalance() public view onlyOwner returns (uint256) {
		return balances;
	}

	function getBalanceIndividual() external view returns (uint256) {
		return individualBalance[msg.sender];
	}
}
