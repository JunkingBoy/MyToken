// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ILocalBankFactory {
    function createBank() external returns (uint256, address);
}
