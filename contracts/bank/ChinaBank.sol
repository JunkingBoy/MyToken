// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ChinaBank {
    struct BankInfo{
        address originator;
        uint256 createTime;
    }

    struct UserInfo{
        uint256 amount;
        uint256 depositTime;
    }

    mapping(uint256 => BankInfo) public bankMap;
    mapping(address => UserInfo) private userMap;

    event CreateBank(address _caller);

    constructor(address _originator, uint256 _bankIndex) {
        bankMap[_bankIndex].originator = _originator;
        bankMap[_bankIndex].createTime = block.timestamp;
        emit CreateBank(msg.sender);
    }

    function deposit(address account, uint256 amount) external returns (bool) {
        bool result = false;

        return result;
    }
}
