// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract JunToken is ERC20 {
    uint256 public lastAwardBlock;

    address private _soleIssuer;

    event Sender(address indexed to, uint256 amount);
    event Burn(uint256 amount);
    event Award(uint256 awardAmount);
    event AddWhiteList(address licensor, address grantee);
    event RemoveWhiteList(address licensor, address grantee);
    event TranslateToLicensor(address newLicensor);

    error UnAuthority(address caller);
    error NotSufficientFunds(address caller);

    mapping(address => uint256) public userBalance;
    mapping(address => address[]) public granteeByLicensor;
    address[] public indexOfLicensor;

    modifier onlyIssuer() {
        if (_soleIssuer != msg.sender) {
            revert UnAuthority(msg.sender);
        }
        _;
    }

    modifier checkBalance(uint256 amount, address caller) {
        require(caller != address(0), "Invalid address!");
        require(amount > 0, "Invalid amount!");
        if (amount <= ERC20(this).balanceOf(caller)) {
            userBalance[caller] = ERC20(this).balanceOf(caller);
            _;
            userBalance[caller] = ERC20(this).balanceOf(caller);
        }else {
            revert NotSufficientFunds(caller);
        }
    }

    modifier prime(address caller) {
        require(caller != address(0), "Invalid user address!");
        address tempAllow = address(0);
        for (uint256 i = 0; i < indexOfLicensor.length; i++) {
            if (caller == indexOfLicensor[i]) {
                tempAllow = caller;
                _;
                break;
            }
        }
        if (tempAllow == address(0)) {
            revert UnAuthority(caller);
        }
    }

    modifier minister(address caller, address officer) {
        require(caller != address(0), "Invalid caller address!");
        bool result = false;
        if (officer == address(0)) {
            result = true;
        }else {
            for (uint256 i = 0; i < indexOfLicensor.length; i++) {
                if (caller == indexOfLicensor[i]) {
                    break;
                }
            }
            for (uint256 i = 0; i < granteeByLicensor[caller].length; i++) {
                if (officer == granteeByLicensor[caller][i]) {
                    result = true;
                    break;
                }
            }
        }
        if (result == true) {
            _;
        }else {
            revert UnAuthority(officer);
        }
    }

    constructor(string memory _tokenName, string memory _tokenSymbol, uint256 initAmount) ERC20(_tokenName, _tokenSymbol) {
        require(initAmount > 0, "Invalid number!");
        _soleIssuer = msg.sender;
        userBalance[_soleIssuer] = initAmount;
        _mint(_soleIssuer, initAmount);
        indexOfLicensor.push(_soleIssuer);
        lastAwardBlock = block.number;
    }

    function tokenTransfer(address from, address to, uint256 amount) external prime(msg.sender) minister(from, to) checkBalance(amount, from) {
        if (to == address(0)) {
            _burn(from, amount);
            userBalance[from] = ERC20(this).balanceOf(from);
            emit Burn(amount);
        }else {
            _transfer(from, to, amount);
            userBalance[from] = ERC20(this).balanceOf(from);
            userBalance[to] = ERC20(this).balanceOf(to);
            emit Transfer(from, to, amount);
        }
    }

    function sendToken(address to, uint256 amount) external minister(msg.sender, to) checkBalance(amount, msg.sender) {
        if (to == address(0)) {
            _burn(msg.sender, amount);
            userBalance[msg.sender] = ERC20(this).balanceOf(msg.sender);
            emit Burn(amount);
        }else {
            transfer(to, amount);
            userBalance[msg.sender] = ERC20(this).balanceOf(msg.sender);
            userBalance[to] = ERC20(this).balanceOf(to);
            emit Sender(to, amount);
        }
    }

    function checkUserBalance(address _target) external view returns (uint256) {
        address tempUser;
        if (_target == address(0)) {
            tempUser = msg.sender;
        }else {
            tempUser = _target;
        }
        return userBalance[tempUser];
    }

    function award(address awardUser) external onlyIssuer {
        address tempAwardUser;
        uint256 currentBlock = block.number;

        if (awardUser == address(0)) {
            tempAwardUser = msg.sender;
        }else {
            tempAwardUser = awardUser;
        }

        if (currentBlock > lastAwardBlock) {
            uint256 awardAmount = currentBlock - lastAwardBlock;
            _mint(tempAwardUser, awardAmount);
            lastAwardBlock = block.number;
            userBalance[tempAwardUser] = ERC20(this).balanceOf(tempAwardUser);
            emit Award(awardAmount);
        }
    }

    function addWhiteList(address _target) external prime(msg.sender) {
        require(_target != address(0), "Invalid white list user!");
        require(_target != msg.sender, "Can not do that!");
        for (uint256 i = 0; i < indexOfLicensor.length; i++) {
            if (msg.sender == indexOfLicensor[i]) {
                granteeByLicensor[msg.sender].push(_target);
                emit AddWhiteList(msg.sender, _target);
                break;
            }
        }
    }

    function removeWhiteList(address _licensor, address _target) external onlyIssuer {
        require(_licensor != address(0), "Invalid licensor address!");
        require(_target != address(0), "Invalid grantee address!");
        for (uint256 i = 0; i < indexOfLicensor.length; i++) {
            if (_target == indexOfLicensor[i]) {
                indexOfLicensor[i] = address(0);
                break;
            }
        }
        for (uint256 i = 0; i < granteeByLicensor[_soleIssuer].length; i++) {
            if (_licensor == granteeByLicensor[_soleIssuer][i]) {
                break;
            }
        }
        require(0 < granteeByLicensor[_licensor].length, "Not exist value!");
        for (uint256 i = 0; i < granteeByLicensor[_licensor].length; i++) {
            if (_target == granteeByLicensor[_licensor][i]) {
                granteeByLicensor[_licensor][i] = address(0);
                emit RemoveWhiteList(_licensor, _target);
            }
        }
    }

    function translateToLicensor(address _target) external onlyIssuer {
        require(_target != address(0), "Invalid address!");
        for (uint256 i = 0; i < granteeByLicensor[_soleIssuer].length; i++) {
            if (_target == granteeByLicensor[_soleIssuer][i]) {
                indexOfLicensor.push(_target);
                emit TranslateToLicensor(_target);
            }
        }
    }

    function transferIssuer(address newIssuer) external onlyIssuer {
        require(newIssuer != address(0), "Invalid new issuer!");
        _soleIssuer = newIssuer;
    }

    function checkIssuer() external view returns (address) {
        return _soleIssuer;
    }

    function checkLicensor() external view returns (uint256) {
        return indexOfLicensor.length;
    }

    function checkGranteeLength(address _licensor) external view returns (uint256) {
        return granteeByLicensor[_licensor].length;
    }
}
