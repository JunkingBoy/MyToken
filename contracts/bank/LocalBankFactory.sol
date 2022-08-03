// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../authority/CheckBankPermission.sol";
import "./ChinaBank.sol";
import "../token/JunToken.sol";

import "../interface/ILocalBankFactory.sol";

contract LocalBankFactory is CheckBankPermission, ILocalBankFactory {
    address private dependencyCenterBank;
    address private currencyAddress;
    address public latestBank;

    address[] public localBank;

    constructor(address _chairMan, address _currency) CheckBankPermission(_chairMan) {
        currencyAddress = _currency;
    }

    function createBank() CheckCenterBank external returns (uint256, address) {
        uint256 tempIndex;
        for (uint256 i = 0; i < 10; i++) {
            if (address(0) == localBank[i]) {
                latestBank = address(new ChinaBank(address(this), i, currencyAddress));
                tempIndex = i;
                localBank[i] = latestBank;
                break;
            }
        }
        return (tempIndex, latestBank);
    }
}
