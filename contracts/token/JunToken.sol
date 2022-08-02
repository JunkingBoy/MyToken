// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../core/CenterBank.sol";
import "../authority/Licensor.sol";

contract JunToken is ERC20, Licensor {
    using SafeMath for uint256;

    struct LocalBankInfo {
        uint256 account;
        uint256 time;
    }

    mapping(address => LocalBankInfo) localBankAccountBook; // 这是一个账本,记录所有银行的代币总数量

    event Mint(address indexed toObject, uint256 amount);
    event Burn(address indexed toObject, uint256 amount);
    event TransferFrom(address indexed fromObject, address indexed toObject, uint256 amount);

    constructor(string memory _name, string memory _symbol, uint256 _initTotalCirculation) ERC20(_name, _symbol) Licensor() {
        _mint(msg.sender, _initTotalCirculation);
        Licensor.currency = address(this);
        emit Mint(msg.sender, _initTotalCirculation);
    }

    function ActionMint(address _localBank, uint256 _mintAmount) CheckCenterBank external {
        require(_mintAmount > 0, "Zero Number!");
        _mint(_localBank, _mintAmount);
        // 存款准备金,每次都需要上缴20% -> 所以该方法仅限于央行下令给地方银行铸币
        uint256 reserveFund = _mintAmount.mul(20).div(100);
        transfer(msg.sender, reserveFund);
        localBankAccountBook[_localBank].account = ERC20(this).balanceOf(_localBank);
        localBankAccountBook[_localBank].time = block.timestamp;
        emit Mint(_localBank, _mintAmount);
    }

    function ActionBurn(address _localBank, uint256 _burnAmount) CheckCenterBank external {
        require(_burnAmount > 0, "Zero Number!");
        _burn(_localBank, _burnAmount);
        localBankAccountBook[_localBank].account = ERC20(this).balanceOf(_localBank);
        localBankAccountBook[_localBank].time = block.timestamp;
        emit Burn(_localBank, _burnAmount);
    }

    function ActionTransfer(address from, address to, uint256 amount) CheckLocalBank external {
        require(address(0) != from, "JunToken: Invalid Address!");
        require(0 < amount, "JunToken: Invalid Amount!");
        if (address(0) == to) {
            _burn(from, amount);
            emit Burn(from, amount);
        }
        transferFrom(from, to, amount);
        emit TransferFrom(from, to, amount);
    }
}
