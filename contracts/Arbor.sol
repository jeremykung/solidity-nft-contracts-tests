// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

using Strings for uint256;


contract Arbor is ERC721, ERC721Enumerable, ERC721Pausable, Ownable, PaymentSplitter {
    uint256 private _nextTokenId;
    uint256 public maxSupply = 100;

    bool public publicMintOpen = false;
    bool public allowListMintOpen = false;
    
    mapping(address => bool) public allowList;

    constructor(address initialOwner, address[] memory _payees, uint[] memory _shares)
        ERC721("Arbor", "ABR")
        Ownable(initialOwner)
        PaymentSplitter(_payees, _shares)
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://Qmauh3XxsrotPU7y5zzgyo9D3zDCHyUUfH9N9eXqXdgsn8/";
    }

    function contractURI() public pure returns (string memory) {
        return "ipfs://QmNsho5SWG24YQSdPdKmHGWuZidY6ajtXguKRiz5noACvG";
    }

    function baseTokenURI() public pure returns (string memory) {
        return _baseURI();
    }

    function tokenURI(uint256 _tokenId) public pure override returns (string memory) {
        return string(abi.encodePacked(baseTokenURI(), Strings.toString(_tokenId), ".json"));
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function editMintWindows(bool _publicMintOpen, bool _allowListMintOpen) external onlyOwner {
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;
    }

    function allowListMint() public payable {
        require(allowListMintOpen == true, "allowList Mint Closed");
        require(allowList[msg.sender], "Account not on allow list");
        require(msg.value == 0.001 ether, "Not Enough Funds, need 0.001 eth");
        internalMint();
    }

    function publicMint() public payable  {
        require(publicMintOpen == true, "public Mint Closed");
        require(msg.value == 0.01 ether, "Not Enough Funds, need 0.01 eth");
        internalMint();
    }

    function internalMint() internal {
        require(totalSupply() < maxSupply, "NFT sold out!");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    function setAllowList(address[] calldata addresses) external onlyOwner {
        for(uint256 i = 0; i < addresses.length; i++) {
            allowList[addresses[i]] = true;
        }
    }

    function addAllowList(address _address, bool _allowed) external onlyOwner {
        allowList[_address] = _allowed;
    }


    function withdraw(address _address) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_address).transfer(balance);
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}