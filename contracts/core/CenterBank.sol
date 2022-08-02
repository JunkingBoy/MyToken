// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../bank/LocalBankFactory.sol";
import "../interface/ILocalBankFactory.sol";

contract CenterBank is Ownable, ILocalBankFactory {
    LocalBankFactory public localBankFactory;

    address private _chairMan;
    address private _centerBank;
    address private immutable localBankFactoryAddress;
    address public latestLocalBank;

    mapping(uint256 => address) private localBankMap;

    event Bank(address indexed _target);
    event ChangeBank(address indexed oldChairMan, address indexed newBank);
    event Kill(address indexed killer);

    error UnAuthority(address caller);

    modifier CheckChairMan() {
        if (_chairMan != msg.sender) {
            revert UnAuthority(msg.sender);
        }
        _;
    }

    constructor() {
        localBankFactory = LocalBankFactory(address(this));
        localBankFactoryAddress = address(localBankFactory);
        _chairMan = msg.sender;
        _centerBank = address(this);
        emit Bank(_chairMan);
    }

    function translateChairMan(address _newChairMan) CheckChairMan external {
        require(address(0) != _newChairMan, "Invalid Address!");
        address oldChairMan;
        if (!isContract(_newChairMan)) {
            oldChairMan = _chairMan;
            _chairMan = _newChairMan;
            emit ChangeBank(oldChairMan, _newChairMan);
        }
    }

    // File: @openzeppelin/contracts/utils/Address.sol
    function isContract(address account) public view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function createBank() CheckChairMan external returns (uint256, address) {
        address _tempBank;
        uint256 _tempIndex;
        (_tempIndex, _tempBank) = ILocalBankFactory(localBankFactoryAddress).createBank();
        latestLocalBank = _tempBank;
        localBankMap[_tempIndex] = _tempBank;
        return (_tempIndex, _tempBank);
    }

    function getChairMan() external view returns (address) {
        return _chairMan;
    }

    function getCenterBank() external view returns (address) {
        return _centerBank;
    }

    function getLocalBankAddress() external view returns (address) {
        return localBankFactoryAddress;
    }
}
