// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./CenterBank.sol";

contract CheckBankPermission {
    CenterBank public centerBank;

    event SetUpCenterBank(address indexed _centerBank);

    modifier CheckCenterBank() {
        require(centerBank.initCenterBank() == msg.sender, "Isn't Center Bank!");
        _;
    }

    constructor(address _chairMan) {
        centerBank = CenterBank(_chairMan);
        emit SetUpCenterBank(address(centerBank));
    }
}
