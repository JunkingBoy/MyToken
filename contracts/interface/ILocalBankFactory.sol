// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ILocalBankFactory {
    function createBank() external returns (uint256, address);
    function mintCoin(address _localBank, uint256 _mintAmount) external;
    function burnCoin(address _localBank, uint256 _burnAmount) external;
}
