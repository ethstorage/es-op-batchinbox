// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Options} from "openzeppelin-foundry-upgrades/Options.sol";
import {BatchInbox} from "../src/BatchInbox.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address ownerAddress = vm.envAddress("OWNER_ADDRESS");
        vm.startBroadcast(deployerPrivateKey);

        address proxy = Upgrades.deployTransparentProxy(
            "BatchInbox.sol:BatchInbox",
            ownerAddress,
            abi.encodeWithSelector(BatchInbox.initialize.selector, ownerAddress)
        );

        vm.stopBroadcast();

        // Log the addresses
        console.log("BatchInbox Proxy Address:", address(proxy));
        console.log("BatchInbox Owner Address:", ownerAddress);
    }

    function upgrade(address proxyAddress) public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // refer to https://docs.openzeppelin.com/upgrades-plugins/foundry-upgrades#upgrade_a_proxy_or_beacon for more details
        Options memory opts;
        opts.referenceContract = "BatchInbox.sol:BatchInbox";
        Upgrades.upgradeProxy(proxyAddress, "BatchInboxV2.sol:BatchInboxV2", "", opts);

        vm.stopBroadcast();

        console.log("Upgraded proxy at %s to new implementation", proxyAddress);
    }
}
