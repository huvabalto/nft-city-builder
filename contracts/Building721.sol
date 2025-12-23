// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Building721 is ERC721, Ownable {
    struct BuildingData {
        uint8 slotCount;
        uint256 baseMultiplier; // fixed-point (e.g. 1e18 = 1.0x)
        uint256 upkeepPerHour;
    }

    uint256 public nextId;
    mapping(uint256 => BuildingData) public buildingData;

    constructor() ERC721("City Buildings", "BUILD") {}

    function mint(
        address to,
        uint8 slotCount,
        uint256 baseMultiplier,
        uint256 upkeepPerHour
    ) external onlyOwner {
        uint256 id = ++nextId;
        _mint(to, id);
        buildingData[id] = BuildingData(
            slotCount,
            baseMultiplier,
            upkeepPerHour
        );
    }
}
