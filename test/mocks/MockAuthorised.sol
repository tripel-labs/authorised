// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "src/Authorised.sol";

contract MockAuthorised is Authorised {
    
    bool public value;
    
    constructor(address _owner) Authorised(_owner) {}

    function unprotectedFunction(bool v) public {
        value = v;
    }

    function ownedProtectedFunction(bool v) public onlyOwner {
        value = v;
    }

    function authorisedProtectedFunction(bool v) public isAuthorised {
        value = v;
    }
}
