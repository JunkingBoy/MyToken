// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../core/CenterBank.sol";
import "../interface/Ilicensor.sol";

contract Licensor is Ilicensor {
    CenterBank public centerBank;

    event SetCenterBank(address indexed centerBankAddress);

    modifier CheckCenterBank() {
        require(centerBank.getCenterBank() == msg.sender, "Isn't Center Bank!");
        _;
    }

    constructor() {
        centerBank = CenterBank(msg.sender);
        emit SetCenterBank(msg.sender);
    }

    function checkCenterBank() external view returns (address) {
        return centerBank.getCenterBank();
    }
}
