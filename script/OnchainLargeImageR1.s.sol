// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../src/OnchainLargeImageR1.sol";

contract OnchainLargeImageR1Script is Script {
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
// forge script script/OnchainLargeImageR1.s.sol:OnchainLargeImageR1Script --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv

// forge verify-contract 0x757F402Eb0550E96aA6cEa90aaD7666B0a9779DC src/OnchainLargeImageR1.sol:OnchainLargeImageR1 --rpc-url $GOERLI_RPC_URL

// "OnchainLargeImageR1.sol" --network goerli --rpc-url $GOERLI_RPC_URL --verify -vvvv

// forge verify-contract 0x757F402Eb0550E96aA6cEa90aaD7666B0a9779DC src/OnchainLargeImageR1.sol:OnchainLargeImage --verifier-url https://api-goerli.etherscan.io/api --chain goerli --verifier etherscan
