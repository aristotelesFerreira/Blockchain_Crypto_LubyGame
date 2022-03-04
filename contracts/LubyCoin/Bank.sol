pragma solidity ^0.8.4;

// https://eips.ethereum.org/EIPS/eip-20
// SPDX-License-Identifier: MIT
import "hardhat/console.sol";

interface Token {
	/// @param _owner The address from which the balance will be retrieved
	/// @return balance the balance
	// function balanceOf(address _owner) view returns (uint256 balance);

	/// @notice send `_value` token to `_to` from `msg.sender`
	/// @param _to The address of the recipient
	/// @param _value The amount of token to be transferred
	/// @return success Whether the transfer was successful or not
	function transfer(address _to, uint256 _value)
		external
		returns (bool success);

	/// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
	/// @param _from The address of the sender
	/// @param _to The address of the recipient
	/// @param _value The amount of token to be transferred
	/// @return success Whether the transfer was successful or not
	function transferFrom(
		address _from,
		address _to,
		uint256 _value
	) external returns (bool success);

	// / @notice `msg.sender` approves `_addr` to spend `_value` tokens
	// / @param _spender The address of the account able to transfer the tokens
	/// @param _value The amount of wei to be approved for transfer
	/// @return success Whether the approval was successful or not
	function approve(uint256 _value) external returns (bool success);

	/// @param _owner The address of the account owning tokens
	/// @return remaining Amount of remaining tokens allowed to spent
	function allowance(address _owner)
		external
		view
		returns (uint256 remaining);

	function mint(address sender, uint256 amount) external;

	function getBalance(address from) external view returns (uint256);

	function balanceOf(address _owner) external view returns (uint256 balance);

	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(
		address indexed _owner,
		address indexed _spender,
		uint256 _value
	);
}

contract ERC20 is Token {
	uint256 private constant MAX_UINT256 = 2**256 - 1;

	mapping(address => uint256) public balances;
	mapping(address => mapping(address => uint256)) public allowed;

	uint256 public totalSupply;
	/*
	NOTE:
	The following variables are OPTIONAL vanities. One does not have to include them.
	They allow one to customise the token contract & in no way influences the core functionality.
	Some wallets/interfaces might not even bother to look at this information.
	*/
	string public name;
	uint8 public decimals;
	string public symbol;
	address public minter;
	address public address_contract;

	constructor() {
		balances[address(this)] = 10 * 10**18; // Give the contract all initial tokens
		totalSupply = 10 * 10**18; // Update total supply
		name = "LubyGame"; // Set the name for display purposes
		decimals = 18; // Amount of decimals for display purposes
		symbol = "LBC"; // Set the symbol for display purposes
		minter = msg.sender;
		address_contract = address(this);
	}

	function transfer(address _to, uint256 _value)
		public
		override
		returns (bool success)
	{
		require(
			balances[address_contract] >= _value,
			"token balance is lower than the value requested"
		);
		balances[address_contract] -= _value;
		balances[_to] += _value;

		emit Transfer(address_contract, _to, _value); //solhint-disable-line indent, no-unused-vars
		return true;
	}

	function transferFrom(
		address _from,
		address _to,
		uint256 _value
	) public override returns (bool success) {
		uint256 allowance = allowed[_from][_to];

		require(
			balances[_from] >= _value && allowance >= _value,
			"token balance or allowance is lower than amount requested"
		);

		balances[_to] += _value;
		balances[_from] -= _value;

		if (allowance < MAX_UINT256) {
			allowed[_from][_to] -= _value;
		}

		emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
		return true;
	}

	function getBalance(address from) public view override returns (uint256) {
		require(from == minter, "Only Owner have permissions!");
		return balances[address_contract];
	}

	function balanceOf(address _owner)
		public
		view
		override
		returns (uint256 balance)
	{
		return balances[_owner];
	}

	function approve(uint256 _value) public override returns (bool success) {
		allowed[msg.sender][address(this)] = _value;
		emit Approval(msg.sender, minter, _value); //solhint-disable-line indent, no-unused-vars
		return true;
	}

	function allowance(address _owner)
		public
		view
		override
		returns (uint256 remaining)
	{
		return allowed[_owner][address(this)];
	}

	function mint(address account, uint256 amount) public override {
		require(account != address(0), "ERC20: mint to the zero address");

		totalSupply += amount;
		balances[account] += amount;

		emit Transfer(address(0), account, amount);
	}
}
