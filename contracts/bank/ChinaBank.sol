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
        uint256 changeTime;
    }

    JunToken public immutable junToken;

    mapping(uint256 => BankInfo) public bankMap;
    mapping(address => UserInfo) private userMap;

    event CreateBank(address indexed _caller);
    event UserTransfer(address indexed _from, address indexed _to, uint256 _amount);

    constructor(address _originator, uint256 _bankIndex, address _currency) {
        bankMap[_bankIndex].originator = _originator;
        bankMap[_bankIndex].createTime = block.timestamp;
        junToken = JunToken(_currency);
        emit CreateBank(msg.sender);
    }

    function deposit(uint256 amount) external returns (bool) {
        require(0 < amount, "Can't do that!");
        bool result = false;
        uint256 tempAmount = ERC20(junToken).balanceOf(msg.sender);
        if (tempAmount > amount) {
            userMap[msg.sender].amount = userMap[msg.sender].amount + amount;
            userMap[msg.sender].changeTime = block.timestamp;
        }
        result = true;
        return result;
    }

    function fetch(uint256 _amount) external returns (bool) {
        require(0 < _amount, "Can't do that!");
        uint256 tempAmount = userMap[msg.sender].amount;
        uint256 bankAmount = ERC20(junToken).balanceOf(address(this));
        if (bankAmount < _amount || tempAmount < _amount) {
            return false;
        }
        userMap[msg.sender].amount = tempAmount - _amount;
        userMap[msg.sender].changeTime = block.timestamp;
        IJunToken(junToken).ActionUserTransfer(address(this), msg.sender, _amount);
        return true;
    }

    function userTransfer(address _target, uint256 _amount) external returns (bool) {
        require(address(0) != _target, "Invalid Address!");
        IJunToken(junToken).ActionUserTransfer(msg.sender, _target, _amount);
        emit UserTransfer(msg.sender, _target, _amount);
        return true;
    }

    function checkUserInfo(address _user) external view returns (uint256) {
        return userMap[_user].amount;
    }
}
