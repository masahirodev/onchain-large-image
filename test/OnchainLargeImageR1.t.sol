// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./helper/TestHelpers.t.sol";
import {OnchainLargeImage} from "../src/OnchainLargeImageR1.sol";
import {SSTORE2} from "solady/utils/SSTORE2.sol";

// forge test --match-contract OnchainLargeImageR1Test --match-test testSetBundleDataGetTokenURI -vvvvv

contract OnchainLargeImageR1Test is TestHelpers {
    using SSTORE2 for bytes;
    using SSTORE2 for address;

    OnchainLargeImage public testContract;

    function setUp() public {
        testContract = new OnchainLargeImage();
    }

    function testSetDataGetTokenURI(string memory image) public onlyOwner {
        uint256 tokenId = 1;

        address pointer = bytes(image).write();

        bytes memory data; // bundleAddressData
        assembly {
            data := mload(0x40) // get free memory pointer
            mstore(data, 0x14) // length: 20 bytes
            mstore(add(data, 0x20), shl(96, pointer)) // first 32 bytes
            mstore(0x40, add(data, 0x34)) // update free memory pointer
        }

        testContract.safeMint(data);
        string memory result = testContract.tokenURI(tokenId);

        assertEq(result, string(abi.encodePacked(defaultInfo, image, '"}')));
    }

    function testSetBundleDataGetTokenURI(string memory image1, string memory image2) public onlyOwner {
        image1 = "aaa";
        image2 = "bbb";

        uint256 tokenId = 1;

        address pointer1 = bytes(image1).write();
        address pointer2 = bytes(image2).write();

        bytes memory data; // bundleAddressData
        assembly {
            data := mload(0x40) // get free memory pointer
            mstore(data, 0x28) // length: 40 bytes
            mstore(add(data, 0x20), shl(96, pointer1)) // first 32 bytes
            mstore(add(data, 0x34), shl(96, pointer2)) // second 32 bytes
            mstore(0x40, add(data, 0x48)) // update free memory pointer
        }

        testContract.safeMint(data);
        string memory result = testContract.tokenURI(tokenId);

        assertEq(result, string(abi.encodePacked(defaultInfo, image1, image2, '"}')));
    }

    string defaultInfo =
        'data:application/json,{"name":"OnchainLargeImage","description":"This is Onchain Large Image.","image":"data:image/jpeg;base64,';
}
