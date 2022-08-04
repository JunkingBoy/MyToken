// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../authority/CenterBank.sol";
import "../authority/CheckPermission.sol";
import "../authority/CheckBankPermission.sol";
import "../interface/IJunToken.sol";

contract JunToken is ERC20, CheckPermission, CheckBankPermission, IJunToken {
    using SafeMath for uint256;

    struct LocalBankInfo {
        uint256 amount;
        uint256 time;
    }

    struct LocalBankTransferInfo {
        address toBank;
        uint256 transferAmount;
    }

    mapping(address => LocalBankInfo) localBankAmountBook; // 这是一个账本,记录所有银行的代币总数量
    mapping(address => LocalBankTransferInfo) interBankTransfer; // 通过fromBank查询

    event Mint(address indexed toObject, uint256 amount);
    event Burn(address indexed toObject, uint256 amount);
    event TransferFrom(address indexed fromObject, address indexed toObject, uint256 amount);
    event Warring(address indexed localBank, uint256 amount);

    constructor(address _chairMan, string memory _name, string memory _symbol, uint256 _initTotalCirculation)
    ERC20(_name, _symbol) CheckPermission(_chairMan) CheckBankPermission(_chairMan) {
        _mint(msg.sender, _initTotalCirculation);
        emit Mint(msg.sender, _initTotalCirculation);
    }

    function ActionMint(address _localBank, uint256 _mintAmount) CheckCenterBank external {
        require(_mintAmount > 0, "Zero Number!");
        _mint(_localBank, _mintAmount);
        // 存款准备金,每次都需要上缴20% -> 所以该方法仅限于央行下令给地方银行铸币
        uint256 reserveFund = _mintAmount.mul(20).div(100);
        transferFrom(_localBank, address(centerBank), reserveFund);
        localBankAmountBook[_localBank].amount = ERC20(this).balanceOf(_localBank);
        localBankAmountBook[_localBank].time = block.timestamp;
        emit Mint(_localBank, _mintAmount);
        emit TransferFrom(_localBank, address(centerBank), reserveFund);
    }

    function ActionBurn(address _localBank, uint256 _burnAmount) CheckCenterBank external {
        require(_burnAmount > 0, "Zero Number!");
        uint256 _tempAmount = ERC20(this).balanceOf(_localBank);
        if (_burnAmount < _tempAmount) {
            _burn(_localBank, _burnAmount);
        }else {
            _burn(_localBank, _tempAmount);
        }
        localBankAmountBook[_localBank].amount = ERC20(this).balanceOf(_localBank);
        localBankAmountBook[_localBank].time = block.timestamp;
        emit Burn(_localBank, _burnAmount);
    }

    // 仅跨行
    function ActionTransfer(address from, address to, uint256 amount) CheckLocalBank external {
        require(0 < amount, "Can't transfer!");
        uint256 localBankLength = centerBank.getLocalBankLength();
        address actionA = address(0);
        address actionB = address(0);
        if (chairMan.isContract(from) && chairMan.isContract(to)) {
            for (uint256 i = 0; i < localBankLength; i++) {
                if (from == centerBank.indexOfLocalBank(i)) {
                    actionA = from;
                }
                if (to == centerBank.indexOfLocalBank(i)) {
                    actionB = to;
                }
            }
            if (address(0) != actionA && address(0) != actionB) {
                transferFrom(from, to, amount);
                interBankTransfer[from].toBank = to;
                interBankTransfer[from].transferAmount = interBankTransfer[from].transferAmount + amount;
                emit TransferFrom(from, to, amount);
            }
        }
    }

    function ActionUserTransfer(address _from, address _to, uint256 _amount) CheckLocalBank external {
        if (chairMan.isContract(_from) && !chairMan.isContract(_to)) {
            uint256 currentLocalBankCurrency = ERC20(this).balanceOf(_from);
            if (currentLocalBankCurrency >= localBankAmountBook[_from].amount) {
                localBankAmountBook[_from].amount = currentLocalBankCurrency;
            }
            if (currentLocalBankCurrency < localBankAmountBook[_from].amount) {
                uint256 temp = localBankAmountBook[_from].amount - currentLocalBankCurrency;
                emit Warring(_from, temp);
            }
            localBankAmountBook[_from].amount = localBankAmountBook[_from].amount - _amount;
            localBankAmountBook[_from].time = block.timestamp;
        }else if (!chairMan.isContract(_from) && chairMan.isContract(_to)) {
            uint256 currentLocalBankCurrency = ERC20(this).balanceOf(_to);
            localBankAmountBook[_to].amount = currentLocalBankCurrency;
            localBankAmountBook[_to].amount = localBankAmountBook[_to].amount + _amount;
            localBankAmountBook[_to].time = block.timestamp;
        }
        transferFrom(_from, _to, _amount);
        emit TransferFrom(_from, _to, _amount);
    }
}
