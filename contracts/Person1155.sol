// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Person1155 is ERC1155, Ownable {
    constructor(string memory uri_) ERC1155(uri_) {}

    function mint(
        address to,
        uint256 tokenId,
        uint256 amount
    ) external onlyOwner {
        _mint(to, tokenId, amount, "");
    }

    function burn(
        address from,
        uint256 tokenId,
        uint256 amount
    ) external {
        require(
            msg.sender == from || isApprovedForAll(from, msg.sender),
            "Not authorized"
        );
        _burn(from, tokenId, amount);
    }
}
