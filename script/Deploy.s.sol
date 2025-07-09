// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {BatchInbox} from "../src/BatchInbox.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";
import {console} from "forge-std/console.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address ownerAddress = vm.envAddress("OWNER_ADDRESS");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the implementation contract
        BatchInbox implementation = new BatchInbox();

        // Encode the initialization data for the implementation contract
        bytes memory data = abi.encodeWithSelector(BatchInbox.initialize.selector, ownerAddress);

        // Deploy the proxy pointing to the implementation
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(implementation), ownerAddress, data);

        vm.stopBroadcast();

        // Log the addresses
        console.log("BatchInbox Implementation Address:", address(implementation));
        console.log("BatchInbox Proxy Address:", address(proxy));
        console.log("BatchInbox Owner Address:", ownerAddress);
    }
}
