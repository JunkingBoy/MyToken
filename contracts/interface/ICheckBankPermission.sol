// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICheckBankPermission {
    function checkCenterBank() external view returns (address);
}
