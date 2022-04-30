// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.2;

contract SelfAuth {
    function requireSelfCall() private view {
        require(msg.sender == address(this), "unauthorized");
    }

    modifier authorized() {
        // This is a function call as it minimized the bytecode size
        requireSelfCall();
        _;
    }
}