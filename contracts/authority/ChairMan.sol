// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ChairMan is Ownable {
    struct chairManInfo{
        address _chairMan;
        uint256 _startWorkingTime;
        uint256 _endWorkingTime;
    }

    address public initChairMan;
    address public chairMan;
    address public theLastChairMan = address(0);

    address[] public chairManIndex;
    mapping(uint256 => chairManInfo) public chairManMap;

    event TranslateChairMan(address indexed _oldchairMan, address indexed _newchairMan);

    modifier MustChairMan() {
        require(chairMan == msg.sender, "Isn't chair man!");
        _;
    }

    constructor() {
        initChairMan = msg.sender;
        chairMan = initChairMan;
        chairManIndex.push(initChairMan);
        chairManMap[0]._chairMan = initChairMan;
        chairManMap[0]._startWorkingTime = block.timestamp;
        chairManMap[0]._endWorkingTime = 0;
        emit TranslateChairMan(address(0), msg.sender);
    }

    function translateChairMan(address _newChairMan) MustChairMan external {
        require(address(0) != _newChairMan, "Can't Zero Address!");
        if (!isContract(_newChairMan)) {
            uint256 latestMapKey = chairManIndex.length;
            theLastChairMan = chairMan;
            chairManMap[latestMapKey - 1]._endWorkingTime = block.timestamp;
            chairManMap[latestMapKey]._chairMan = _newChairMan;
            chairManMap[latestMapKey]._startWorkingTime = block.timestamp;
            chairManMap[latestMapKey]._endWorkingTime = 0;
            chairMan = _newChairMan;
            emit TranslateChairMan(theLastChairMan, chairMan);
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

    // 未能解决出现隔断以后重复任职的查询
    function checkChairManInfo(address _targetChairMan) external returns (uint256, uint256, uint256) {
        if (initChairMan == _targetChairMan) {
            return (0, chairManMap[0]._startWorkingTime, chairManMap[0]._endWorkingTime);
        }
        uint256 mapKey;
        for (uint256 i = 0; i < chairManIndex.length; i++) {
            if (chairManIndex[i] == _targetChairMan) {
                mapKey = i;
            }
        }
        if (0 == mapKey) {
            return (0, 0, 0);
        }else {
            return (mapKey, chairManMap[mapKey]._startWorkingTime, chairManMap[mapKey]._endWorkingTime);
        }
    }
}
