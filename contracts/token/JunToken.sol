pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract JunToken is ERC20 {
    uint256 public lastAwardBlock;

    address private _soleIssuer;

    event Sender(address indexed to, uint256 amount);
    event Burn(uint256 amount);
    event Award(uint256 awardAmount);

    error UnAuthority(address caller);
    error BlackListUser(address caller);

    mapping(address => uint256) public userBalance;

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
        }
        userBalance[caller] = ERC20(this).balanceOf(caller);
    }

    constructor(string memory _tokenName, string memory _tokenSymbol, uint256 initAmount) ERC20(_tokenName, _tokenSymbol) {
        require(initAmount > 0, "Invalid number!");
        _soleIssuer = msg.sender;
        userBalance[_soleIssuer] = initAmount;
        _mint(_soleIssuer, initAmount);
        lastAwardBlock = block.number;
    }

    function tokenTransfer(address from, address to, uint256 amount) external onlyIssuer checkBalance(amount, from) {
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

    function sendToken(address to, uint256 amount) external onlyIssuer checkBalance(amount, msg.sender) {
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
        return userBalance[_target];
    }

    function transferIssuer(address newIssuer) external onlyIssuer {
        require(newIssuer != address(0), "Invalid new issuer!");
        _soleIssuer = newIssuer;
    }

    function checkIssuer() external view returns (address) {
        return _soleIssuer;
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
}
