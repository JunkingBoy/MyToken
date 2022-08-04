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

    error UnknowLocalBank(address _localBank);

    constructor(address _chairMan, address _currency) CheckBankPermission(_chairMan) {
        currencyAddress = _currency;
    }

    function createBank() external returns (uint256, address) {
        uint256 tempIndex = localBank.length;
        if (tempIndex < 10) {
            latestBank = address(new ChinaBank(address(this), tempIndex, currencyAddress));
        }
        return (tempIndex, latestBank);
    }

    // 央行下令让地方银行增强货币流动性
    function mintCoin(address _localBank, uint256 _mintAmount) CheckCenterBank external {
        require(address(0) != _localBank, "Can't do that!");
        address tempLocalBank = address(0);
        for (uint256 i = 0; i < localBank.length; i++) {
            if (_localBank == localBank[i]) {
                tempLocalBank = _localBank;
                break;
            }
        }
        if (tempLocalBank != address(0)) {
            IJunToken(currencyAddress).ActionMint(_localBank, _mintAmount);
        }else {
            revert UnknowLocalBank(_localBank);
        }
    }

    // 央行下令缩减资产负债表
    function burnCoin(address _localBank, uint256 _burnAmount) CheckCenterBank external {
        require(address(0) != _localBank, "Can't do that!");
        address tempLocalBank = address(0);
        for (uint256 i = 0; i < localBank.length; i++) {
            if (_localBank == localBank[i]) {
                tempLocalBank = _localBank;
                break;
            }
        }
        if (tempLocalBank != address(0)) {
            IJunToken(currencyAddress).ActionBurn(_localBank, _burnAmount);
        }else {
            revert UnknowLocalBank(_localBank);
        }
    }
}
