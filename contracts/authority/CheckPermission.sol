// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ChairMan.sol";
import "../interface/ICheckPermission.sol";

contract CheckPermission is ICheckPermission {
    ChairMan public immutable chairMan;

    event VoteChairMan(address indexed _chairMan);

    modifier CheckChairMan() {
        require(chairMan.chairMan() == msg.sender, "Isn't Chair Man!");
        _;
    }

    constructor(address _chairMan) {
        chairMan = ChairMan(_chairMan);
        emit VoteChairMan(_chairMan);
    }

    function checkChairMan(address _target) external override returns (uint256, uint256, uint256) {
        return chairMan.checkChairManInfo(_target);
    }
}
