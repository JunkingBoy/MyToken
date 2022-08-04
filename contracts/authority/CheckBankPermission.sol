// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./CenterBank.sol";
import "../interface/ICheckBankPermission.sol";

contract CheckBankPermission is ICheckBankPermission {
    CenterBank public immutable centerBank;

    event SetUpCenterBank(address indexed _centerBank);

    error CanNotFindLocalBank(address _localBank);

    modifier CheckCenterBank() {
        require(centerBank.initCenterBank() == msg.sender, "Isn't Center Bank!");
        _;
    }

    modifier CheckLocalBank() {
        uint256 tempLength = centerBank.getLocalBankLength();
        bool onOff = false;
        for (uint256 i = 0; i < tempLength; i++) {
            if (msg.sender == centerBank.indexOfLocalBank(i)) {
                onOff = true;
            }
        }
        if (onOff) {
            _;
        }else {
            revert CanNotFindLocalBank(msg.sender);
        }
    }

    constructor(address _chairMan) {
        centerBank = CenterBank(_chairMan);
        emit SetUpCenterBank(address(centerBank));
    }

    function checkCenterBank() external view override returns (address) {
        return address(centerBank);
    }
}
