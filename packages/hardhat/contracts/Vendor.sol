pragma solidity ^0.8.20; //Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    /////////////////
    /// Errors //////
    /////////////////

    // Errors go here...
    error InvalidEthAmount();
    error InsufficientVendorTokenBalance(uint256 available, uint256 required);
    error EthTransferFailed(address to, uint256 amount);
    error InvalidTokenAmount();
    error InsufficientVendorEthBalance(uint256 available, uint256 required);

    //////////////////////
    /// State Variables //
    //////////////////////

    YourToken public immutable yourToken;
    uint public constant tokensPerEth = 100;

    ////////////////
    /// Events /////
    ////////////////

    // Events go here...
    event BuyTokens(address indexed buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(address indexed seller, uint256 amountOfTokens, uint256 amountOfETH);

    ///////////////////
    /// Constructor ///
    ///////////////////

    constructor(address tokenAddress) Ownable(msg.sender) {
        yourToken = YourToken(tokenAddress);
    }

    ///////////////////
    /// Functions /////
    ///////////////////

    function buyTokens() external payable {
        if(msg.value == 0) revert InvalidEthAmount();

        uint amountOfTokens = msg.value * tokensPerEth;
        uint vendorBalance = yourToken.balanceOf(address(this));

        if(vendorBalance < amountOfTokens) revert InsufficientVendorTokenBalance(vendorBalance , amountOfTokens);
        
        yourToken.transfer(msg.sender , amountOfTokens);

        emit BuyTokens(msg.sender, msg.value, amountOfTokens);
    }

    function withdraw() public onlyOwner {
        (bool success,) = owner().call{value: address(this).balance}("");
        if(!success) revert EthTransferFailed(owner() , address(this).balance);
    }

    function sellTokens(uint256 amount) public {
        if(amount == 0) revert InvalidTokenAmount();

        uint amountOfEth = amount / tokensPerEth ; 
        if(address(this).balance < amountOfEth) revert InsufficientVendorEthBalance(address(this).balance , amountOfEth);

        yourToken.transferFrom(msg.sender , address(this) , amount);

        (bool success,) = msg.sender.call{value: amountOfEth}("");
        if(!success) revert EthTransferFailed(msg.sender , amountOfEth);
        
        emit SellTokens(msg.sender, amount, amountOfEth);
    }
}
