// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IJunToken {
    function ActionMint(address _localBank, uint256 _mintAmount) external;
    function ActionBurn(address _localBank, uint256 _burnAmount) external;
    function ActionTransfer(address from, address to, uint256 amount) external;
}
