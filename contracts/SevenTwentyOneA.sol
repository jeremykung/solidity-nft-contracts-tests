// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// ERC-720
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// ERC-721A
import "https://github.com/chiru-labs/ERC721A/blob/main/contracts/ERC721A.sol";
// ERC-721R (from 
// import "https://github.com/exo-digital-labs/ERC721R/blob/main/contracts/ERC721A.sol";
// import "https://github.com/exo-digital-labs/ERC721R/blob/main/contracts/IERC721R.sol";

contract Arbor is ERC721A, Ownable {
    constructor(address initialOwner)
        ERC721A("Arbor", "ABR")
        Ownable(initialOwner)
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://Qmauh3XxsrotPU7y5zzgyo9D3zDCHyUUfH9N9eXqXdgsn8";
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }
}