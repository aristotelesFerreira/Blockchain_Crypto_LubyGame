pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract NewNFT is ERC721, ERC721Enumerable, Ownable {
	using Counters for Counters.Counter;

	Counters.Counter private _tokenIdCounter;

	address public minter;

	uint256 public balances;

	// mapping(address => uint256) private balances;

	uint256 public minRate = 0.005 ether;
	uint256 public MAX_SUPPLY = 10000;

	constructor() ERC721("AR NFT Brazil", "AR") {
		minter = msg.sender;
	}

	function safeMint(address to) public payable {
		require(totalSupply() < MAX_SUPPLY, "Can't min more.");
		require(msg.value >= minRate, "Not enough ether sent.");
		balances = balances + msg.value;
		_tokenIdCounter.increment();
		uint256 tokenId = _tokenIdCounter.current();
		_safeMint(to, tokenId);
		uri(tokenId);
	}

	function uri(uint256 _tokenId) public view virtual returns (string memory) {
		return
			string(
				abi.encodePacked(
					"ipfs://Qmacdqw6qUdQse39XGDe6n248nYS8LxNr4htGeEeukfU2Q/",
					Strings.toString(_tokenId),
					".json"
				)
			);
	}

	function _beforeTokenTransfer(
		address from,
		address to,
		uint256 tokenId
	) internal override(ERC721, ERC721Enumerable) {
		super._beforeTokenTransfer(from, to, tokenId);
	}

	function supportsInterface(bytes4 interfaceId)
		public
		view
		override(ERC721, ERC721Enumerable)
		returns (bool)
	{
		return super.supportsInterface(interfaceId);
	}

	function withdraw() public onlyOwner {
		require(balances > 0, "Balance is 0");
		payable(owner()).transfer(balances);
	}
}
