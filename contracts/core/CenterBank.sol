// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract CenterBank is Ownable {
    address private _chairMan;
    address public localBankFactory;
    address public latestLocalBank;

    mapping(address => address) public localBankAndFactory;

    mapping(uint256 => address) private centerBankMap;

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
        _chairMan = msg.sender;
        centerBankMap[0] = _chairMan;
        emit Bank(_chairMan);
    }

    function translateChairMan(address _newChairMan) CheckChairMan external {
        require(address(0) != _newChairMan, "Invalid Address!");
        address oldChairMan;
        if (!isContract(_newChairMan)) {
            oldChairMan = _chairMan;
            _chairMan = _newChairMan;
            centerBankMap[0] = _chairMan;
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

    function getCenterBank() external view returns (address) {
        return _chairMan;
    }
}
