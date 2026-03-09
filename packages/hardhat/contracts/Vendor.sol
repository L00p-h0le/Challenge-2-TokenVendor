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
    error InsufficientVendorTokenBalance(uint available , uint required);
    error EthTransferFailed(address to , uint amount);
    error InvalidTokenAmount();
    error InsufficientVendorEthBalance(uint available , uint required);



    //////////////////////
    /// State Variables //
    //////////////////////

    uint public constant tokensPerEth = 100;

    YourToken public immutable yourToken;

    ////////////////
    /// Events /////
    ////////////////

    // Events go here...

    event BuyTokens(address indexed buyer , uint amountOfEth , uint amountOfTokens);
    event SellTokens(address indexed seller , uint amountOfTokens , uint amountOfEth);

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

        if(! (msg.value > 0) ) revert InvalidEthAmount();

        uint amountOfTokens = msg.value * tokensPerEth;
        uint VendorBalance = yourToken.balanceOf(address(this));

         
        if(VendorBalance < amountOfTokens){
            revert InsufficientVendorTokenBalance( VendorBalance, amountOfTokens);
        }
        
        yourToken.transfer(msg.sender , amountOfTokens);

        emit BuyTokens(msg.sender, msg.value, amountOfTokens);
    }

    function withdraw() public onlyOwner {
        
        uint amount = address(this).balance;

        (bool success,) = owner().call{value: amount}("");
        if(!success) revert EthTransferFailed(msg.sender , amount);

    }

    function sellTokens(uint256 amount) public {

        if(amount == 0) revert InvalidTokenAmount();

        uint requiredEth = amount / tokensPerEth;
        uint VendorBalance = address(this).balance;

        if(VendorBalance < requiredEth) revert InsufficientVendorEthBalance(VendorBalance , requiredEth);

        yourToken.transferFrom(msg.sender , address(this) , amount);
        
        (bool success, ) = msg.sender.call{value: requiredEth}("");
        if(!success) revert EthTransferFailed(msg.sender , requiredEth);

        emit SellTokens(msg.sender , amount , requiredEth);

    }
}
