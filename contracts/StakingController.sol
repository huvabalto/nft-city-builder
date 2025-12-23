// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Person1155.sol";
import "./Building721.sol";

contract StakingController is Ownable {
    enum PersonState {
        IDLE,
        STAKED,
        RENTED,
        COOLDOWN
    }

    struct LockedBalance {
        uint128 amount;
        uint64 cooldownEnd;
    }

    Person1155 public immutable people;
    Building721 public immutable buildings;

    // user => tokenId => locked info
    mapping(address => mapping(uint256 => LockedBalance)) public locked;

    event Staked(address indexed user, uint256 tokenId, uint128 amount, uint256 buildingId);
    event Unstaked(address indexed user, uint256 tokenId, uint128 amount);

    constructor(address _people, address _buildings) {
        people = Person1155(_people);
        buildings = Building721(_buildings);
    }

    function stake(
        uint256 tokenId,
        uint128 amount,
        uint256 buildingId
    ) external {
        require(amount > 0, "Amount zero");
        require(buildings.ownerOf(buildingId) == msg.sender, "Not building owner");

        uint256 balance = people.balanceOf(msg.sender, tokenId);
        uint256 currentlyLocked = locked[msg.sender][tokenId].amount;
        require(balance >= currentlyLocked + amount, "Insufficient unlocked balance");

        // TODO:
        // - Check profession compatibility
        // - Check building slot availability (backend mirrored)
        // - Emit building occupancy events if needed

        locked[msg.sender][tokenId].amount += amount;

        emit Staked(msg.sender, tokenId, amount, buildingId);
    }

    function unstake(
        uint256 tokenId,
        uint128 amount
    ) external {
        LockedBalance storage lb = locked[msg.sender][tokenId];
        require(lb.amount >= amount, "Not enough locked");

        lb.amount -= amount;
        lb.cooldownEnd = uint64(block.timestamp + 6 hours);

        emit Unstaked(msg.sender, tokenId, amount);
    }

    function lockedAmount(
        address user,
        uint256 tokenId
    ) external view returns (uint256) {
        return locked[user][tokenId].amount;
    }
}
