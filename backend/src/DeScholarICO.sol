// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract DeScholarICO is ReentrancyGuard {
    IERC20 public token;
    address public owner;
    uint256 public tokenPrice = 10000000000000 wei; // 0.00001 ETH in wei
    uint256 public tokensAvailableForSale;
    uint256 public totalTokensSold;
    bool public icoActive = false;

    mapping(address => uint256) public investments;

    event TokensPurchased(address indexed buyer, uint256 amount, uint256 cost);
    event ICOStatusChanged(bool newStatus);
    event TokenPriceChanged(uint256 newPrice);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(address _tokenAddress, uint256 _tokensForSale) {
        require(_tokenAddress != address(0), "Token address cannot be zero");
        token = IERC20(_tokenAddress);
        owner = msg.sender;
        tokensAvailableForSale = _tokensForSale;
    }

    function startICO() external onlyOwner {
        icoActive = true;
        emit ICOStatusChanged(true);
    }

    function stopICO() external onlyOwner {
        icoActive = false;
        emit ICOStatusChanged(false);
    }

    function setTokenPrice(uint256 _newPrice) external onlyOwner {
        require(_newPrice > 0, "Price must be greater than 0");
        tokenPrice = _newPrice;
        emit TokenPriceChanged(_newPrice);
    }

    function buyTokens() external payable nonReentrant {
        require(icoActive, "ICO is not active");
        require(msg.value > 0, "Must send ETH to buy tokens");

        uint256 tokensToBuy = (msg.value * (10 ** 18)) / tokenPrice;
        require(
            tokensToBuy <= tokensAvailableForSale,
            "Not enough tokens available"
        );

        tokensAvailableForSale -= tokensToBuy;
        totalTokensSold += tokensToBuy;
        investments[msg.sender] += msg.value;

        require(
            token.transfer(msg.sender, tokensToBuy),
            "Token transfer failed"
        );

        emit TokensPurchased(msg.sender, tokensToBuy, msg.value);
    }

    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");

        (bool sent, ) = payable(owner).call{value: balance}("");
        require(sent, "Failed to withdraw ETH");
    }

    function withdrawUnsoldTokens() external onlyOwner {
        require(!icoActive, "ICO must be stopped first");
        uint256 remainingTokens = token.balanceOf(address(this));
        require(remainingTokens > 0, "No tokens to withdraw");

        require(
            token.transfer(owner, remainingTokens),
            "Token transfer failed"
        );
    }

    function getAvailableTokens() external view returns (uint256) {
        return tokensAvailableForSale;
    }

    function getInvestmentAmount(
        address investor
    ) external view returns (uint256) {
        return investments[investor];
    }

    function getTotalTokensSold() external view returns (uint256) {
        return totalTokensSold;
    }
}
