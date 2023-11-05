// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {SSTORE2} from "solady/utils/SSTORE2.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract OnchainLargeImage is ERC721 {
    using SSTORE2 for bytes;
    using SSTORE2 for address;

    uint256 private _nextTokenId = 1;

    /**
     * @dev `bundleAddressData` is data that bundles the addresses of storage contracts that store each image.`stackRoom` stores the length of bundleAddressData in [0] and `bundleAddress` in [1~] for each `tokenID`.
     */
    mapping(uint256 => mapping(uint256 => uint256)) public stackRoom;

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
        assembly {
            // get `bundleAddressData`
            let len := mload(bundleAddressData)

            // slot for `stackRoom[tokenId]`
            mstore(0x00, tokenId)
            mstore(0x20, stackRoom.slot)
            let slot := keccak256(0x00, 0x40)

            // set `bundleAddressData`.length to stackRoom[tokenId][0]
            mstore(0x00, 0x00)
            mstore(0x20, slot)
            sstore(keccak256(0x00, 0x40), len)

            let mc := add(bundleAddressData, 0x20)

            for {
                let cc := 1
                let last := add(mc, len)
            } 1 {
                // step by step address
                mc := add(mc, 0x14)
                cc := add(cc, 1)
            } {
                // set `bundleAddressData`.data to stackRoom[tokenId][cc]
                mstore(0x00, cc)
                // mstore(0x20, slot)
                sstore(keccak256(0x00, 0x40), shr(96, mload(mc)))

                if lt(last, mc) { break }
            }
        }
    }

    /**
     * @dev Bundle and display each image
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory result) {
        assembly {
            // slot for `stackRoom[tokenId]`
            mstore(0x00, tokenId)
            mstore(0x20, stackRoom.slot)
            let slot := keccak256(0x00, 0x40)

            // GET `bundleAddressData`.length from stackRoom[tokenId][0]
            mstore(0x00, 0x00)
            mstore(0x20, slot)
            let len := sload(keccak256(0x00, 0x40))

            // memory counter to the start of the free memory.
            let mc := mload(0x40)

            // return data
            result := mc

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
                let cc := 1
                let last := div(len, 0x14)
                // for sstore2
                let pointerCodesize
                let size
            } 1 {
                // step by step address
                ptr := add(ptr, 0x14)
                cc := add(cc, 1)
            } {
                mstore(0x00, cc)
                // mstore(0x20, slot)
                ptr := sload(keccak256(0x00, 0x40))

                // check
                pointerCodesize := extcodesize(ptr)
                if iszero(pointerCodesize) { pointerCodesize := 1 }

                // Offset all indices by 1 to skip the STOP opcode.
                size := sub(pointerCodesize, 1)

                // Get data and copy it to memory
                extcodecopy(ptr, mc, 1, size)
                mc := add(mc, size)

                if lt(last, cc) { break }
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
