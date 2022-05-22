// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "./mocks/MockOwned.sol";

contract TestOwned is Test {

    MockOwned c;

    address alice = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address bob = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    bytes4 Unauthorised = bytes4(keccak256("Unauthorised()"));

    function setUp() public {
        c = new MockOwned(alice);
        assertEq(c.owner(), alice);
    }

    function testProtected() public {
        _testProtected(alice);
        _testProtected(bob);
    }

    function testUnprotected() public {
        _testUnprotected(alice);
        _testUnprotected(bob);
    }

    function testChangeOnwer() public {
        vm.prank(alice);
        c.setOwner(bob);
        assertEq(c.owner(), bob);
        
        _testProtected(address(this));
        _testUnprotected(address(this));
        _testProtected(bob);
        _testUnprotected(bob);

        vm.expectRevert(Unauthorised);
        c.setOwner(alice);
        vm.prank(bob);
        c.setOwner(alice);
        assertEq(c.owner(), alice);
    }

    // Make sure caller cannot call protected functions nor cahnge the owner.
    function _testProtected(address caller) internal {
        if (caller != c.owner()) {
            vm.expectRevert(Unauthorised);
            vm.prank(caller);
            c.setOwner(caller);
            vm.expectRevert(Unauthorised);
            vm.prank(caller);
            c.protectedFunction(true);
        } else {
            vm.prank(caller);
            c.protectedFunction(true);
        }
    }
    
    // Make sure caller (and owner) can call unprotected functions.
    function _testUnprotected(address caller) internal {
        vm.prank(caller);
        c.unprotectedFunction(true);
    }

}
