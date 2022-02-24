pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract NewNFT is ERC721, ERC721Enumerable, Ownable {
	using Counters for Counters.Counter;

	Counters.Counter private _tokenIdCounter;

	mapping(uint256 => string) private _tokenURIs;

	string private _baseURIextended;

	address public minter;

	uint256 public balances;

	// mapping(address => uint256) private balances;

	uint256 public minRate = 0.005 ether;
	uint256 public MAX_SUPPLY = 10000;

	constructor() ERC721("AR NFT Brazil", "AR") {
		minter = msg.sender;
	}

	function setBaseURI(string memory baseURI_) external onlyOwner {
		_baseURIextended = baseURI_;
	}

	function _setTokenURI(uint256 tokenId, string memory _tokenURI)
		internal
		virtual
	{
		require(
			_exists(tokenId),
			"ERC721Metadata: URI set of nonexistent token"
		);
		_tokenURIs[tokenId] = _tokenURI;
	}

	function _baseURI() internal view virtual override returns (string memory) {
		return _baseURIextended;
	}

	function safeMint(address to, string memory tokenURI_)
		external
		payable
		onlyOwner
	{
		require(totalSupply() < MAX_SUPPLY, "Can't min more.");
		// require(msg.value >= minRate, "Not enough ether sent.");
		_tokenIdCounter.increment();
		uint256 tokenId = _tokenIdCounter.current();
		_safeMint(to, tokenId);
		_setTokenURI(tokenId, tokenURI_);

		balances += msg.value;
	}

	function tokenURI(uint256 tokenId)
		public
		view
		virtual
		override
		returns (string memory)
	{
		require(
			_exists(tokenId),
			"ERC721Metadata: URI query for nonexistent token"
		);

		string memory _tokenURI = _tokenURIs[tokenId];
		string memory base = _baseURI();

		// If there is no base URI, return the token URI.
		if (bytes(base).length == 0) {
			return _tokenURI;
		}
		// If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
		if (bytes(_tokenURI).length > 0) {
			return string(abi.encodePacked(base, _tokenURI));
		}
		// If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
		return string(abi.encodePacked(base, tokenId));
	}

	// transferFrom

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

	// Receive all balances;
	function withdraw() public onlyOwner {
		require(balances > 0, "Balance is 0");
		payable(owner()).transfer(balances);
	}

	function buyNFT(uint256 tokenId) public payable {
		require(
			_isApprovedOrOwner(address(this), tokenId),
			"ERC721: transfer caller is not owner nor approved"
		);
		uint256 amount = (msg.value / 2);
		address owner = ownerOf(tokenId);
		_transfer(owner, msg.sender, tokenId);
		balances += amount;
		payable(owner).transfer(amount);
	}
}
