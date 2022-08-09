// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ChairMan is Ownable {
    struct chairManInfo {
        address _chairMan;
        uint256 _startWorkingTime;
        uint256 _endWorkingTime;
    }

    struct chairManTimeInfo {
        uint256 _manIndex;
        uint256 _startTime;
        uint256 _endTime;
    }

    address public initChairMan;
    address public chairMan;
    address public theLastChairMan = address(0);

    address[] public chairManIndex; // 最后一位始终是当前的主席
    chairManTimeInfo[] public cmti; // 主席信息的结构体数组
    mapping(uint256 => chairManInfo) public chairManMap;
    mapping(address => uint256[]) public chairManRepetition; // 记录重复任职的主席的任职周期 -> 记录历史

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
            for (uint256 i = 0; i < chairManIndex.length; i++) {
                if (chairMan == chairManIndex[i]) {
                    chairManRepetition[chairMan].push(i);
                }
            }
            chairManIndex.push(chairMan);
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

    // 解决出现隔断以后重复任职的查询
    function checkChairManInfo(address _targetChairMan) external returns (uint256, uint256, uint256) {
        // 校验是否是当前主席
        uint256 _tempLength = chairManIndex.length - 1;
        if (_targetChairMan == chairManIndex[_tempLength]) {
            return (_tempLength, chairManMap[_tempLength]._startWorkingTime, 0);
        }
        // 校验历史的任职周期 -> 注意类型以及数据持久性问题
        uint256[] memory _tempArray = chairManRepetition[_targetChairMan];
        if (0 == _tempArray.length) {
            return (0, 0, 0);
        }
        uint256 _temp = 0;
        for (uint256 i = 0; i < _tempArray.length; i++) {
            cmti.push(chairManTimeInfo({
                _manIndex: i,
                _startTime: chairManMap[i]._startWorkingTime,
                _endTime: chairManMap[i]._endWorkingTime
            }));
            _temp += 1;
        }
        // 返回任职次数以及最后一次任职的开始时间和退休时间
        return (_temp, cmti[_temp]._startTime, cmti[_temp]._endTime);
    }
}
