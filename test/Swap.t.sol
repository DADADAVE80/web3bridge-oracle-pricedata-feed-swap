// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import { Swap } from "../src/Swap.sol";
import { MockAggregatorV3 } from "../mocks/MockAggregatorV3.sol"; // Replace with your mock implementation

contract SwapTest is Vm {

  Swap public swap;
  MockAggregatorV3 public ethPriceFeed;
  MockAggregatorV3 public linkPriceFeed;
  MockAggregatorV3 public daiPriceFeed;

  address public user = address(0x1234567890123456789012345678901234567890);

  function setUp() public {
    ethPriceFeed = new MockAggregatorV3(0, 10**8, 3000 * 10**8); // Set ETH price to 3000 USD
    linkPriceFeed = new MockAggregatorV3(0, 10**18, 20 * 10**18); // Set LINK price to 20 USD
    daiPriceFeed = new MockAggregatorV3(0, 10**18, 1 * 10**18);   // Set DAI price to 1 USD
    swap = new Swap(
      address(ethPriceFeed),
      address(linkPriceFeed),
      address(daiPriceFeed)
    );
  }

  function testETHToLinkSwap() public {
    vm.deal(user, 1 ether);
    vm.expectEmit(true, swap, "Swapped(address,address,address,uint256)", user, address(0), address(1), 150 * 10**18); // Expect 150 LINK for 1 ETH
    swap.swap(address(0), address(1), 1 ether);
  }

  function testLinkToETHSwap() public {
    vm.deal(user, 3000 * 10**18); // Send 3000 LINK
    vm.expectEmit(true, swap, "Swapped(address,address,address,uint256)", user, address(1), address(0), 1 ether); // Expect 1 ETH for 3000 LINK
    swap.swap(address(1), address(0), 3000 * 10**18);
  }

  // Add similar tests for other swap combinations (ETH to DAI, DAI to ETH, LINK to DAI, DAI to LINK)

  function testUnsupportedToken() public {
    vm.expectRevert("From token not supported");
    swap.swap(address(2), address(1), 10); // Swap from an unsupported token
  }
}