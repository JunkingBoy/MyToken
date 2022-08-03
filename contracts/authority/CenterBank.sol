// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./CheckPermission.sol";
import "../bank/LocalBankFactory.sol";

contract CenterBank is CheckPermission {
    LocalBankFactory public localBankFactory;

    address public oderMan;
    address public initCenterBank;

    event SetUpCenterBank(address indexed _orderMan);

    constructor(address _chairMan, address _factory) CheckPermission(_chairMan) {
        oderMan = _chairMan;
        initCenterBank = address(this);
        localBankFactory = LocalBankFactory(_factory);
        emit SetUpCenterBank(_chairMan);
    }

    function createBank() CheckChairMan external {

    }
}
