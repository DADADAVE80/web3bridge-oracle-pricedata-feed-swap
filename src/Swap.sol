// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "../lib/chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract Swap {
    address public constant ethAddress =
        0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9; // Address of Ether (ETH)
    address public constant linkAddress =
        0x779877A7B0D9E8603169DdbD7836e478b4624789; // Address of Chainlink token (LINK)
    address public constant daiAddress =
        0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6; // Address of Dai stablecoin (DAI)

    mapping(address => bool) public supportedTokens;

    address public constant ethPriceFeed =
        0x694AA1769357215DE4FAC081bf1f309aDC325306; // Address of ETH/USD price feed
    address public constant linkPriceFeed =
        0xc59E3633BAAC79493d908e63626716e204A45EdF; // Address of LINK/USD price feed
    address public constant daiPriceFeed =
        0x14866185B1962B63C3Ea9E03Bc1da838bab34C19; // Address of DAI/USD price feed

    event Swapped(
        address indexed user,
        address indexed fromToken,
        address indexed toToken,
        uint256 amount
    );

    function swap(
        address _fromToken,
        address _toToken,
        uint256 _amount
    ) external {
        supportedTokens[ethAddress] = true;
        supportedTokens[linkAddress] = true;
        supportedTokens[daiAddress] = true;
        require(supportedTokens[_fromToken], "From token not supported");
        require(supportedTokens[_toToken], "To token not supported");
        require(_fromToken != _toToken, "Cannot swap the same token");

        if (_fromToken == ethAddress && _toToken == linkAddress) {
            // ETH to LINK swap
            require(
                IERC20(ethAddress).transferFrom(
                    msg.sender,
                    address(this),
                    _amount
                ),
                "Failed to transfer WETH tokens"
            );
            uint256 amountOut = getLatestPrice(ethPriceFeed, linkPriceFeed);
            require(
                IERC20(linkAddress).transfer(msg.sender, amountOut),
                "Failed to transfer LINK tokens"
            );
            emit Swapped(msg.sender, _fromToken, _toToken, amountOut);
        } else if (_fromToken == linkAddress && _toToken == ethAddress) {
            // LINK to ETH swap
            require(
                IERC20(linkAddress).transferFrom(
                    msg.sender,
                    address(this),
                    _amount
                ),
                "Failed to transfer LINK tokens"
            );
            uint256 amountOut = getLatestPrice(linkPriceFeed, ethPriceFeed);
            require(
                IERC20(ethAddress).transfer(msg.sender, amountOut),
                "Failed to transfer WETH tokens"
            );
            emit Swapped(msg.sender, _fromToken, _toToken, amountOut);
        } else if (_fromToken == ethAddress && _toToken == daiAddress) {
            // ETH to DAI swap
            require(
                IERC20(ethAddress).transferFrom(
                    msg.sender,
                    address(this),
                    _amount
                ),
                "Failed to transfer WETH tokens"
            );
            uint256 amountOut = getLatestPrice(ethPriceFeed, daiPriceFeed);
            require(
                IERC20(daiAddress).transfer(msg.sender, amountOut),
                "Failed to transfer DAI tokens"
            );
            emit Swapped(msg.sender, _fromToken, _toToken, amountOut);
        } else if (_fromToken == daiAddress && _toToken == ethAddress) {
            // DAI to ETH swap
            require(
                IERC20(daiAddress).transferFrom(
                    msg.sender,
                    address(this),
                    _amount
                ),
                "Failed to transfer DAI tokens"
            );
            uint256 amountOut = getLatestPrice(daiPriceFeed, ethPriceFeed);
            require(
                IERC20(ethAddress).transfer(msg.sender, amountOut),
                "Failed to transfer WETH tokens"
            );
            emit Swapped(msg.sender, _fromToken, _toToken, amountOut);
        } else if (_fromToken == linkAddress && _toToken == daiAddress) {
            // LINK to DAI swap
            require(
                IERC20(linkAddress).transferFrom(
                    msg.sender,
                    address(this),
                    _amount
                ),
                "Failed to transfer LINK tokens"
            );
            uint256 amountOut = getLatestPrice(linkPriceFeed, daiPriceFeed);
            require(
                IERC20(daiAddress).transfer(msg.sender, amountOut),
                "Failed to transfer DAI tokens"
            );
            emit Swapped(msg.sender, _fromToken, _toToken, amountOut);
        } else if (_fromToken == daiAddress && _toToken == linkAddress) {
            // DAI to LINK swap
            require(
                IERC20(daiAddress).transferFrom(
                    msg.sender,
                    address(this),
                    _amount
                ),
                "Failed to transfer DAI tokens"
            );
            uint256 amountOut = getLatestPrice(daiPriceFeed, linkPriceFeed);
            require(
                IERC20(linkAddress).transfer(msg.sender, amountOut),
                "Failed to transfer LINK tokens"
            );
            emit Swapped(msg.sender, _fromToken, _toToken, amountOut);
        } else {
            revert("Invalid swap");
        }
    }

    receive() external payable {
        // Fallback function to receive ETH
    }

    function getLatestPrice(
        address _base,
        address _quote
    ) public view returns (uint256 l) {
        l = uint256(getDerivedPrice(_base, _quote, 8));
    }

    function getDerivedPrice(
        address _base,
        address _quote,
        uint8 _decimals
    ) public view returns (int256) {
        require(
            _decimals > uint8(0) && _decimals <= uint8(18),
            "Invalid _decimals"
        );
        int256 decimals = int256(10 ** uint256(_decimals));
        (, int256 basePrice, , , ) = AggregatorV3Interface(_base)
            .latestRoundData();
        uint8 baseDecimals = AggregatorV3Interface(_base).decimals();
        basePrice = scalePrice(basePrice, baseDecimals, _decimals);

        (, int256 quotePrice, , , ) = AggregatorV3Interface(_quote)
            .latestRoundData();
        uint8 quoteDecimals = AggregatorV3Interface(_quote).decimals();
        quotePrice = scalePrice(quotePrice, quoteDecimals, _decimals);

        return (basePrice * decimals) / quotePrice;
    }

    function scalePrice(
        int256 _price,
        uint8 _priceDecimals,
        uint8 _decimals
    ) internal pure returns (int256) {
        if (_priceDecimals < _decimals) {
            return _price * int256(10 ** uint256(_decimals - _priceDecimals));
        } else if (_priceDecimals > _decimals) {
            return _price / int256(10 ** uint256(_priceDecimals - _decimals));
        }
        return _price;
    }
}
