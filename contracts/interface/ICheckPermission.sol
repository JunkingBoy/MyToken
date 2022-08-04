// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICheckPermission {
    function checkChairMan(address _target) external returns (uint256, uint256, uint256);
}
