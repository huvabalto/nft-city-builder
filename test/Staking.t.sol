// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseTest.sol";

contract StakingTest is BaseTest {

    function testCannotStakeMoreThanBalance() public {
        buildings.mint(alice, 4, 1e18, 0);

        vm.startPrank(alice);
        vm.expectRevert();
        staking.stake(101, 20, 1);
    }

    function testStakeAndUnstakeCooldown() public {
        buildings.mint(alice, 4, 1e18, 0);

        vm.startPrank(alice);
        staking.stake(101, 5, 1);
        staking.unstake(101, 5);

        (uint128 amount, uint64 cooldownEnd) = staking.locked(alice, 101);
        assertEq(amount, 0);
        assertGt(cooldownEnd, block.timestamp);
    }

    function testCannotStakeWithoutOwningBuilding() public {
        buildings.mint(bob, 4, 1e18, 0);

        vm.startPrank(alice);
        vm.expectRevert("Not building owner");
        staking.stake(101, 1, 1);
    }
}
