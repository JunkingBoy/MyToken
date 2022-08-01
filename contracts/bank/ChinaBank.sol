// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ChinaBank {
    struct BankInfo{
        address originator;
        uint256 createTime;
    }

    mapping(uint256 => BankInfo) public bankMap;

    event CreateBank(address _caller);

    constructor(address _originator, uint256 _bankIndex) {
        bankMap[_bankIndex].originator = _originator;
        bankMap[_bankIndex].createTime = block.timestamp;
        emit CreateBank(msg.sender);
    }


}
