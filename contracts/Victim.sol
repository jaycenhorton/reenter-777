// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import "hardhat/console.sol";
import "./Share.sol";

contract Victim {
    mapping(address => uint256) private userShares;
    mapping(address => uint256) private wrappedUserShares;

    IERC20 private _token;
    Share private _share;
    IERC1820Registry private _erc1820 =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    constructor(address tokenAddress, address shareAddres) {
        _token = IERC20(tokenAddress);
        _share = Share(shareAddres);
    }

    function shares(address user) public view returns (uint256) {
        return userShares[user];
    }

    function wrappedShares(address user) public view returns (uint256) {
        return _share.balanceOf(user);
    }

    function wrapShares(uint256 amount) public {
        if (userShares[msg.sender] >= amount) {
            _share.mint(msg.sender, amount, "", "");
        }
    }

    function createSharesForUser(address user, uint256 amount) public {
        userShares[user] += amount;
        _token.transferFrom(msg.sender, user, amount);
    }

    function buyShareFromUser(address user, uint256 amount) public {
        require(userShares[user] >= amount);
        userShares[user] -= amount;
        userShares[msg.sender] += amount;
        _token.transferFrom(msg.sender, user, amount); // <--- by putting this line first instead, the problem would be solved but this breaks the checks-effects-interactions security pattern :(
    }

    function __buyShareFromUser_workaround(address user, uint256 amount)
        public
    {
        _token.transferFrom(msg.sender, user, amount); // <--- by putting this line first instead, the problem would be solved but this breaks the checks-effects-interactions security pattern :(
        require(userShares[user] >= amount);
        userShares[user] -= amount;
        userShares[msg.sender] += amount;
    }
}
