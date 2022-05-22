// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "./mocks/MockAuthorised.sol";

contract TestAuthorised is Test {

    MockAuthorised c;

    address alice = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address bob = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    bytes4 Unauthorised = bytes4(keccak256("Unauthorised()"));

    function setUp() public {
        c = new MockAuthorised(alice);
        assertEq(c.owner(), alice);
        assertTrue(c.authorised(alice));
        assertTrue(!c.authorised(bob));
    }

    function testProtected() public {
        _testProtected(alice);
        _testProtected(bob);
    }

    function testUnprotected() public {
        _testUnprotected(alice);
        _testProtected(bob);
    }

    function testSetAuthorised() public {
        vm.prank(alice);
        c.setAuthorised(bob, true);
        assertTrue(c.authorised(bob));

        _testProtected(alice);
        _testProtected(bob);
        _testUnprotected(alice);
        _testUnprotected(bob);

        vm.prank(alice);
        c.setAuthorised(bob, false);
        assertTrue(!c.authorised(bob));

        _testProtected(bob);
        _testUnprotected(bob);
    }

    function testSetPermissions() public {
        vm.prank(alice);
        c.setAuthorised(bob, true);
        vm.expectRevert(Unauthorised);
        vm.prank(bob);
        c.setOwner(bob);
        vm.expectRevert(Unauthorised);
        vm.prank(bob);
        c.setAuthorised(bob, false);
    }

    // Make sure caller cannot call protected functions nor set allowed accounts.
    function _testProtected(address caller) internal {
        if (c.authorised(caller)) {
            vm.prank(caller);
            c.authorisedProtectedFunction(true);
        } else {
            vm.expectRevert(Unauthorised);
            vm.prank(caller);
            c.authorisedProtectedFunction(true);

            vm.expectRevert(Unauthorised);
            vm.prank(caller);
            c.setAuthorised(caller, true);
        }
    }

    // Make sure caller can call unprotected functions.
    function _testUnprotected(address caller) internal {
        vm.prank(caller);
        c.unprotectedFunction(true);
    }

}
