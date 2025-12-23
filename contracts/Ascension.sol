// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Person1155.sol";

contract Legendary721 is ERC721, Ownable {
    uint256 public nextId;

    constructor() ERC721("Legendary Citizens", "LEGEND") {}

    function mint(address to) external onlyOwner returns (uint256) {
        uint256 id = ++nextId;
        _mint(to, id);
        return id;
    }
}

contract Ascension is Ownable {
    Person1155 public immutable people;
    Legendary721 public immutable legends;

    mapping(uint256 => uint256) public requiredBurn; // tokenId => amount

    event Ascended(address indexed user, uint256 tokenId, uint256 legendaryId);

    constructor(address _people, address _legends) {
        people = Person1155(_people);
        legends = Legendary721(_legends);
    }

    function setRequirement(uint256 tokenId, uint256 amount) external onlyOwner {
        requiredBurn[tokenId] = amount;
    }

    function ascend(uint256 tokenId) external {
        uint256 burnAmount = requiredBurn[tokenId];
        require(burnAmount > 0, "Ascension disabled");

        // TODO:
        // - Ensure tokens are not locked or rented

        people.burn(msg.sender, tokenId, burnAmount);
        uint256 legendId = legends.mint(msg.sender);

        emit Ascended(msg.sender, tokenId, legendId);
    }
}
