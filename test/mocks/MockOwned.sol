// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "src/Owned.sol";

contract MockOwned is Owned {
    
    bool public value;
    
    constructor(address _owner) Owned(_owner) {}

    function unprotectedFunction(bool v) public {
        value = v;
    }

    function protectedFunction(bool v) public onlyOwner {
        value = v;
    }
}
