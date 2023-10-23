// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

abstract contract TestHelpers is Test {
    address public constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    uint256 private constant _MASK_UINT8 = (1 << 8) - 1;
    uint256 private constant _MASK_UINT16 = (1 << 16) - 1;
    uint256 private constant _MASK_UINT32 = (1 << 32) - 1;
    uint256 private constant _MASK_UINT64 = (1 << 64) - 1;
    uint256 private constant _MASK_UINT128 = (1 << 128) - 1;

    address public zeroAddress = address(0);
    address public owner = makeAddr("owner");
    address public notOwner = makeAddr("notOwner");
    address public operator = makeAddr("operator");
    address public user1 = vm.addr(1);
    address public user2 = vm.addr(2);
    address public user3 = vm.addr(3);
    address public anotherContractAddress = makeAddr("anotherContract");

    constructor() {}

    modifier onlyOwner() {
        vm.startPrank(owner);
        vm.deal(owner, 100 ether);
        _;
        vm.stopPrank();
    }

    modifier onlyOperator() {
        vm.startPrank(operator);
        vm.deal(operator, 100 ether);
        _;
        vm.stopPrank();
    }

    modifier nonOwner() {
        vm.startPrank(notOwner);
        vm.deal(user1, 100 ether);
        _;
        vm.stopPrank();
    }

    modifier User(address user) {
        vm.startPrank(user, user);
        vm.deal(user, 100 ether);
        _;
        vm.stopPrank();
    }

    modifier anotherContract() {
        vm.startPrank(user1, anotherContractAddress);
        vm.deal(user1, 100 ether);
        _;
        vm.stopPrank();
    }

    function _testCreateBytes(string memory str, bytes4 sign) internal {
        assertEq(bytes4(keccak256(bytes(str))), sign);
    }
}
