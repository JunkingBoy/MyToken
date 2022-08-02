// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../bank/ChinaBank.sol";

contract LocalBankFactory {
    address private dependencyCenterBank;
    address public latestBank;

    address[] public localBank;

    modifier CheckDependencyCenterBank() {
        require(msg.sender == dependencyCenterBank);
        _;
    }

    constructor(address _centerBank) { dependencyCenterBank = _centerBank; }

    function createBank() CheckDependencyCenterBank external returns (uint256, address) {
        uint256 tempIndex;
        for (uint256 i = 0; i < 10; i++) {
            if (address(0) == localBank[i]) {
                latestBank = address(new ChinaBank(address(this), i));
                tempIndex = i;
                localBank[i] = latestBank;
                break;
            }
        }
        return (tempIndex, latestBank);
    }
}
