// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../authority/Licensor.sol";
import "../bank/ChinaBank.sol";

contract LocalBankFactory is Licensor {
    address public latestBank;

    address[] public localBank;

    constructor(address _centerBank) {

    }

    function createBank() external returns (address) {
        for (uint256 i = 0; i < 10; i++) {
            if (address(0) == localBank[i]) {
                latestBank = address(new ChinaBank(address(centerBank), i));
                localBank[i] = latestBank;
                break;
            }
        }
        return latestBank;
    }
}
