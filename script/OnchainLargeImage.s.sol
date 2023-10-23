// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../src/OnchainLargeImage.sol";

contract OnchainLargeImageScript is Script {
    OnchainLargeImage public token;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        token = new OnchainLargeImage();

        vm.stopBroadcast();
    }
}

// To load the variables in the .env file
// source .env

// To deploy and verify our contract
// forge script script/OnchainLargeImage.s.sol:OnchainLargeImageScript --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv
