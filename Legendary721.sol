// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Legendary721 is ERC721, Ownable {
    uint256 public nextId;

    constructor() ERC721("Legendary Citizens", "LEGEND") {}

    function mint(address to) external onlyOwner returns (uint256) {
        uint256 id = ++nextId;
        _mint(to, id);
        return id;
    }
}
