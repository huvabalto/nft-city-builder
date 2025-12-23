// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Person1155.sol";
import "./StakingController.sol";

contract RentalController is Ownable {
    struct RentalOffer {
        address owner;
        uint256 tokenId;
        uint128 amount;
        uint256 pricePerHour;
        uint64 minDuration;
        uint64 maxDuration;
        bool active;
    }

    struct ActiveRental {
        address renter;
        uint64 endTime;
    }

    Person1155 public immutable people;
    StakingController public immutable staking;

    uint256 public nextOfferId;
    mapping(uint256 => RentalOffer) public offers;
    mapping(uint256 => ActiveRental) public rentals;

    event RentalListed(uint256 offerId);
    event RentalStarted(uint256 offerId, address renter, uint64 endTime);
    event RentalEnded(uint256 offerId);

    constructor(address _people, address _staking) {
        people = Person1155(_people);
        staking = StakingController(_staking);
    }

    function listForRent(
        uint256 tokenId,
        uint128 amount,
        uint256 pricePerHour,
        uint64 minDuration,
        uint64 maxDuration
    ) external {
        require(amount > 0, "Amount zero");

        uint256 balance = people.balanceOf(msg.sender, tokenId);
        uint256 lockedAmt = staking.lockedAmount(msg.sender, tokenId);
        require(balance >= lockedAmt + amount, "Insufficient unlocked");

        uint256 offerId = ++nextOfferId;
        offers[offerId] = RentalOffer({
            owner: msg.sender,
            tokenId: tokenId,
            amount: amount,
            pricePerHour: pricePerHour,
            minDuration: minDuration,
            maxDuration: maxDuration,
            active: true
        });

        emit RentalListed(offerId);
    }

    function acceptRental(
        uint256 offerId,
        uint64 duration
    ) external payable {
        RentalOffer storage offer = offers[offerId];
        require(offer.active, "Inactive offer");
        require(duration >= offer.minDuration && duration <= offer.maxDuration, "Invalid duration");

        uint256 cost = offer.pricePerHour * duration;
        require(msg.value == cost, "Incorrect payment");

        offer.active = false;
        rentals[offerId] = ActiveRental({
            renter: msg.sender,
            endTime: uint64(block.timestamp + duration)
        });

        // TODO:
        // - Route protocol fee
        // - Lock balances via StakingController (controller permission)

        payable(offer.owner).transfer(msg.value * 98 / 100);

        emit RentalStarted(offerId, msg.sender, rentals[offerId].endTime);
    }

    function endRental(uint256 offerId) external {
        ActiveRental storage rental = rentals[offerId];
        require(rental.endTime > 0, "No rental");
        require(block.timestamp >= rental.endTime, "Not ended");

        delete rentals[offerId];

        // TODO:
        // - Force unstake if needed
        // - Apply cooldown via StakingController

        emit RentalEnded(offerId);
    }
}
