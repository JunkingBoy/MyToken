// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../token/JunToken.sol";

contract ChinaBank {
    struct BankInfo{
        address originator;
        uint256 createTime;
    }

    struct UserInfo{
        uint256 amount;
        uint256 depositTime;
    }

    JunToken public immutable junToken;

    mapping(uint256 => BankInfo) public bankMap;
    mapping(address => UserInfo) private userMap;

    event CreateBank(address _caller);

    constructor(address _originator, uint256 _bankIndex, address _currency) {
        bankMap[_bankIndex].originator = _originator;
        bankMap[_bankIndex].createTime = block.timestamp;
        junToken = JunToken(_currency);
        emit CreateBank(msg.sender);
    }

    function deposit(address account, uint256 amount) external returns (bool) {
        bool result = false;

        return result;
    }
}
