// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {SSTORE2} from "solady/utils/SSTORE2.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract OnchainLargeImage is ERC721 {
    using SSTORE2 for bytes;
    using SSTORE2 for address;

    uint256 private _nextTokenId = 1;

    /**
     * @dev `bundleAddressData` is data that bundles the addresses of storage contracts that store each image.`stackRoom` stores the address of the storage contract that stores `bundleAddressData` for each `tokenID`.
     */
    mapping(uint256 => address) public stackRoom;

    event Upload(address indexed pointer, address indexed from);

    constructor() ERC721("OnchainLargeImage", "OLI") {}

    function safeMint(bytes memory bundleAddressData) public {
        uint256 tokenId = _nextTokenId++;
        _setStackRoom(tokenId, bundleAddressData);
        _safeMint(msg.sender, tokenId);
    }

    /**
     * @dev Create storage contracts
     */
    function upload(string memory data) public {
        address pointer = bytes(data).write();
        emit Upload(pointer, msg.sender);
    }

    /**
     * @dev Set `bundleAddressData` to `stackRoom`
     */
    function _setStackRoom(uint256 tokenId, bytes memory bundleAddressData) internal {
        // create storage contract (SSTORE2 function)
        address pointer = bundleAddressData.write();
        stackRoom[tokenId] = pointer;
    }

    /**
     * @dev Bundle and display each image
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory result) {
        address pointer = stackRoom[tokenId];

        assembly {
            /**
             * @dev SSTORE2 ptr.read()
             * @param ptr address
             * @param sp start memory pointer
             * @return ep end memory pointer
             */
            function readSstore2(ptr, sp) -> ep, size {
                // check
                let pointerCodesize := extcodesize(ptr)
                if iszero(pointerCodesize) { pointerCodesize := 1 }

                // Offset all indices by 1 to skip the STOP opcode.
                size := sub(pointerCodesize, 1)

                // Get data and copy it to memory
                extcodecopy(ptr, sp, 1, size)
                ep := add(sp, size)
            }

            // memory counter to the start of the free memory.
            let mc := mload(0x40)

            // start pointer for address data
            let sp := mc
            let size

            // get `bundleAddressData`
            mc, size := readSstore2(pointer, mc)

            // move free memory pointer
            mstore(0x40, mc)

            // return data
            result := mload(0x40)

            // Skip the first slot, which stores the length.
            mc := add(mc, 0x20)

            // default information
            mstore(mc, 'data:application/json,{"name":"O')
            mc := add(mc, 32)

            mstore(mc, 'nchainLargeImage","description":')
            mc := add(mc, 32)

            mstore(mc, '"This is Onchain Large Image.","')
            mc := add(mc, 32)

            mstore(mc, 'image":"data:image/jpeg;base64,')
            mc := add(mc, 31)

            // bundle Data
            for {
                let ptr
                let last := add(sp, size)
            } 1 {
                // step by step address
                sp := add(sp, 0x14)
            } {
                ptr := shr(96, mload(sp))
                mc, size := readSstore2(ptr, mc)
                if lt(last, sp) { break }
            }

            mstore(mc, '"}')
            mc := add(mc, 2)

            // Allocate the memory for the string.
            mstore(0x40, and(add(mc, 31), not(31)))

            // Write the length of the string.
            mstore(result, sub(sub(mc, 0x20), result))
        }
    }
}
