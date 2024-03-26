// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {AggregatorV3Interface} from "lib/chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract CounterTest is Test {
    function setUp() public {
        address constant ethAddress =
        0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9; // Address of Ether (ETH)
    address constant linkAddress =
        0x779877A7B0D9E8603169DdbD7836e478b4624789; // Address of Chainlink token (LINK)
    address constant daiAddress =
        0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6; // Address of Dai stablecoin (DAI)

    address constant ethPriceFeed =
        0x694AA1769357215DE4FAC081bf1f309aDC325306; // Address of ETH/USD price feed
    address constant linkPriceFeed =
        0xc59E3633BAAC79493d908e63626716e204A45EdF; // Address of LINK/USD price feed
    address constant daiPriceFeed =
        0x14866185B1962B63C3Ea9E03Bc1da838bab34C19; // Address of DAI/USD price feed
    }

    function testSwapEthToDai() external {
        swap(ethAddress, daiAddress, 1 ether);

        
    }
}
