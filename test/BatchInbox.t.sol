// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {BatchInbox} from "../src/BatchInbox.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract BatchInboxTest is Test {
    BatchInbox public batchInbox;

    function setUp() public {
        address owner = address(this);
        address proxy = Upgrades.deployTransparentProxy(
            "BatchInbox.sol:BatchInbox", owner, abi.encodeCall(BatchInbox.initialize, (owner))
        );
        batchInbox = BatchInbox(payable(proxy));
    }

    function testDepositWithdrawOK() public {
        // Give the test contract some ether
        vm.deal(address(this), 1000 ether);

        // deposit 1 ether for target
        address target = address(111);
        uint256 amount = 1 ether;
        uint256 balanceBefore = target.balance;
        assertEq(batchInbox.balances(target), 0);
        batchInbox.deposit{value: amount}(target);
        assertEq(batchInbox.balances(target), amount);

        // withdraw 1 ether from target, to target
        vm.prank(target);
        batchInbox.withdraw(target, amount);
        uint256 balanceAfter = target.balance;

        assertEq(balanceBefore + amount, balanceAfter);
    }

    function testDepositWithdrawNG() public {
        // Give the test contract some ether
        vm.deal(address(this), 1000 ether);

        // deposit 1 ether for target
        address target = address(111);
        uint256 amount = 1 ether;
        assertEq(batchInbox.balances(target), 0);
        batchInbox.deposit{value: amount}(target);
        assertEq(batchInbox.balances(target), amount);

        // withdraw 2 ether from target, to target
        vm.prank(target);
        vm.expectRevert(BatchInbox.BalanceNotEnough.selector);
        batchInbox.withdraw(target, 2 ether);
    }

    function testInitializeSetsOwner() public view {
        assertEq(batchInbox.owner(), address(this));
    }

    function testInitializeCanOnlyBeCalledOnce() public {
        vm.expectRevert(abi.encodeWithSignature("InvalidInitialization()"));
        batchInbox.initialize(address(0x123));
    }

    function testOnlyOwnerCanSetStorageContract() public {
        address nonOwner = address(0x456);
        vm.prank(nonOwner);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", nonOwner));
        batchInbox.setEsStorageContract(address(0x789));

        // Owner can set the storage contract
        address storageContract = address(0x789);
        batchInbox.setEsStorageContract(storageContract);
        assertEq(address(batchInbox.esStorageContract()), storageContract);
    }
}
