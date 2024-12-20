//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract RiceToken is ERC20, Ownable {
    ////////////////// 
    // Errors
    //////////////////
    error RiceToken__ZeroAmount();
    error RiceToken__AmountMoreThanBalance();

    ////////////////// 
    // Modifiers
    //////////////////
    modifier moreThanZero(uint256 amount) {
        if(amount <= 0) {
            revert RiceToken__ZeroAmount();
        }
        _;
    }
 
    ////////////////// 
    // Functions
    //////////////////
    constructor() ERC20("RiceToken", "RICE") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) public onlyOwner moreThanZero(amount) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public moreThanZero(amount) {
        if(amount > balanceOf(from)) revert RiceToken__AmountMoreThanBalance();
        _burn(from, amount);
    }
}