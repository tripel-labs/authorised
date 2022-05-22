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

    function testProtected(address caller) public {
        _testProtected(caller);
        _testProtected(alice);
        _testProtected(bob);
    }

    function testUnprotected(address caller) public {
        _testUnprotected(caller);
        _testUnprotected(alice);
        _testProtected(bob);
    }

    function testSetAuthorised(address user) public {
        vm.prank(alice);
        c.setAuthorised(user, true);
        assertTrue(c.authorised(user));

        _testProtected(user);
        _testProtected(alice);
        _testProtected(bob);
        _testUnprotected(user);
        _testUnprotected(alice);
        _testUnprotected(bob);

        vm.prank(alice);
        c.setAuthorised(user, false);
        assertTrue(!c.authorised(user));

        _testProtected(user);
        _testUnprotected(user);
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
