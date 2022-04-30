//SPDX-License-Identifier: Unlicense
pragma solidity >0.4.23 <0.9.0;

library utils {

    function isNotZeroAddress(address addr) public pure returns (bool) {
        return addr != address(0);
    }



}