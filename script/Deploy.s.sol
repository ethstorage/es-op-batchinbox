// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/proxy/transparent/ProxyAdmin.sol";

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/BatchInbox.sol";

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

    function upgrade(address proxyAddress, address proxyAdminAddress) public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy a new implementation
        BatchInbox newImplementation = new BatchInbox();

        // Get the ProxyAdmin instance
        ProxyAdmin admin = ProxyAdmin(proxyAdminAddress);

        // Upgrade the proxy to use the new implementation
        admin.upgradeAndCall(ITransparentUpgradeableProxy(proxyAddress), address(newImplementation), "0x");

        vm.stopBroadcast();

        console.log("Upgraded proxy at %s to new implementation at %s", proxyAddress, address(newImplementation));
    }
}
