// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./CheckPermission.sol";
import "../bank/LocalBankFactory.sol";

contract CenterBank is CheckPermission {
    struct LocalBankInfo{
        uint256 _localBankIndex;
        address _localBankAddress;
        uint256 _startTime;
        uint256 _endTime;
    }

    address public localBankFactory;
    address public oderMan;
    address public initCenterBank;

    address[] public indexOfLocalBank;
    mapping(uint256 => LocalBankInfo) public localBankInfoMap;

    event SetUpCenterBank(address indexed _orderMan);

    constructor(address _chairMan, address _factory) CheckPermission(_chairMan) {
        oderMan = _chairMan;
        initCenterBank = address(this);
        localBankFactory = _factory;
        emit SetUpCenterBank(_chairMan);
    }

    function createBank() CheckChairMan external {
        (uint256 _bankIndex, address _localBank) = ILocalBankFactory(localBankFactory).createBank();
        indexOfLocalBank.push(_localBank);
        localBankInfoMap[_bankIndex]._localBankIndex = _bankIndex;
        localBankInfoMap[_bankIndex]._localBankAddress = _localBank;
        localBankInfoMap[_bankIndex]._startTime = block.timestamp;
        localBankInfoMap[_bankIndex]._endTime = 0;
    }

    function actionMint(address _localBank, uint256 _mintAmount) CheckChairMan external {
        ILocalBankFactory(localBankFactory).mintCoin(_localBank, _mintAmount);
    }

    function actionBurn(address _localBank, uint256 _burnAmount) CheckChairMan external {
        ILocalBankFactory(localBankFactory).burnCoin(_localBank, _burnAmount);
    }

    function getLocalBankLength() external view returns (uint256) {
        return indexOfLocalBank.length;
    }
}
