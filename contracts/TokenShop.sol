// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

interface TokenInterface {
    function mint(address account, uint256 amount) external;
}

contract TokenShop{

    AggregatorV3Interface internal priceFeed;
    TokenInterface public minter;
    uint256 public tokenPrice = 200; //Token price is $2.00
    address public owner;

    constructor(address tokenAddress) {
        minter = TokenInterface(tokenAddress);
        /*
         *Network: Sepolia
         *Aggregator: ETH/USD
         *Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        */
        priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = msg.sender;  
    }

    function getChainlinkDataFeeds() public view returns(int) {
        (/*uint80 roundId*/,
        int price,
        /*uint startedAt*/,
        /*uint timeStamp*/,
        /*uint answeredInRound*/)= priceFeed.latestRoundData();
        return price;
    }

    function tokenAmount(uint amountETH) public view returns(uint256) {
        uint256 ethUsd = uint256(getChainlinkDataFeeds());
        uint256 amountUsd = amountETH * ethUsd / 10**(8/2);
        uint256 amountToken = amountUsd / tokenPrice / 10**(8/2);
        return amountToken;
    }

    receive() external payable { 
        uint256 amountToken = tokenAmount(msg.value);
        minter.mint(msg.sender, amountToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}