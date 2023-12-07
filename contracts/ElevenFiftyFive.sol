// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Nubila is ERC1155, Ownable, ERC1155Pausable, ERC1155Supply {

    uint256 public publicPrice = 0.01 ether;
    uint256 public allowListPrice = 0.001 ether;
    uint256 public oneTokenMaxSupply = 2;   // owners per nft
    uint256 public allTokenMaxSupply = 10;  // nft max supply

    bool public publicMintOpen = false;
    bool public allowListMintOpen = false;

    constructor(address initialOwner) ERC1155("ipfs://QmY8sn9cp4FmrVcQebSyhoN4196XkWdNmfMSrpWVnxWJLp/") Ownable(initialOwner) {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
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

    function allowListMint(uint256 id, uint256 amount) public payable {
        require(allowListMintOpen, "Allow list mint closed.");
        require(id <= 10, "Minting wrong token number (only 0-10 tokens)");
        require(totalSupply(id) + amount <= oneTokenMaxSupply, "Max supply for token reached.");
        require(msg.value == allowListPrice * amount, "not enough funds, 0.001 ETH per mint");
        _mint(msg.sender, id, amount, "");
    }

    function mint(uint256 id, uint256 amount)
        public
        payable
    {
        require(publicMintOpen, "Public mint is closed.");
        require(id <= 10, "Minting wrong token number (only 0-10 tokens)");
        require(totalSupply(id) + amount <= oneTokenMaxSupply, "Max supply for token reached.");
        require(msg.value == publicPrice * amount, "Not enough funds, requires 0.01 ETH");
        _mint(msg.sender, id, amount, "");
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function withdraw(address _address) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_address).transfer(balance);
    }

    function uri(uint256 _id) public view virtual override returns (string memory) {
        require(exists(_id), "URI error, token does not exist!");
        return string(abi.encodePacked(super.uri(_id), Strings.toString(_id), ".json"));
    }

    // function uriTest(uint256 _id) public view virtual returns (string memory) {
    //     return string(super.uri(_id));
    // }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Pausable, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }
}
