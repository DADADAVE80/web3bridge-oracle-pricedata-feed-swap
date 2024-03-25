// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenSwap {
    address public ethAddress; // Address of Ethereum
    address public linkAddress; // Address of Chainlink token (LINK)
    address public daiAddress; // Address of Dai stablecoin (DAI)
    mapping(address => bool) public supportedTokens;

    event Swapped(
        address indexed user,
        address indexed fromToken,
        address indexed toToken,
        uint256 amount
    );

    constructor(
        address _ethAddress,
        address _linkAddress,
        address _daiAddress
    ) {
        ethAddress = _ethAddress;
        linkAddress = _linkAddress;
        daiAddress = _daiAddress;
        supportedTokens[_ethAddress] = true;
        supportedTokens[_linkAddress] = true;
        supportedTokens[_daiAddress] = true;
    }

    function swap(
        address _fromToken,
        address _toToken,
        uint256 _amount
    ) external payable {
        require(supportedTokens[_fromToken], "From token not supported");
        require(supportedTokens[_toToken], "To token not supported");
        require(_fromToken != _toToken, "Cannot swap the same token");

        if (_fromToken == ethAddress && _toToken == linkAddress) {
            // ETH to LINK swap
            require(msg.value == _amount, "Incorrect ETH amount sent");
            require(
                IERC20(linkAddress).transfer(msg.sender, _amount),
                "Failed to transfer LINK tokens"
            );
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
            payable(msg.sender).transfer(_amount);
        } else if (_fromToken == ethAddress && _toToken == daiAddress) {
            // ETH to DAI swap
            require(msg.value == _amount, "Incorrect ETH amount sent");
            require(
                IERC20(daiAddress).transfer(msg.sender, _amount),
                "Failed to transfer DAI tokens"
            );
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
            payable(msg.sender).transfer(_amount);
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
            require(
                IERC20(daiAddress).transfer(msg.sender, _amount),
                "Failed to transfer DAI tokens"
            );
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
            require(
                IERC20(linkAddress).transfer(msg.sender, _amount),
                "Failed to transfer LINK tokens"
            );
        } else {
            revert("Invalid swap");
        }

        emit Swapped(msg.sender, _fromToken, _toToken, _amount);
    }

    receive() external payable {
        // Fallback function to receive ETH
    }
}
