// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/Swap.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract SwapContractTest is Test {
    Swap swapContract;
    IERC20 eth;
    IERC20 link;
    IERC20 dai;

    address AddrETH = 0x477b144FbB1cE15554927587f18a27b241126FBC;
    address AddrLINK = 0x6a37809BdFC0aC7b73355E82c1284333159bc5F0;
    address AddrDAI = 0xe902aC65D282829C7a0c42CAe165D3eE33482b9f;

    function setUp() public {
        dai = IERC20(0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357);
        link = IERC20(0xf8Fb3713D459D7C1018BD0A49D19b4C44290EBE5);
        eth = IERC20(0xb16F35c0Ae2912430DAc15764477E179D9B9EbEa);
        swapContract = Swap(0x9a88EAf73d8Cc01Dc4Ebb472A956098946301314);
    }

    function testSwapEthToDAI() public {
        switchSigner(AddrDAI);
        uint256 balance = dai.balanceOf(AddrDAI);
        dai.transfer(address(swapContract), balance);

        switchSigner(AddrETH);
        uint balanceOfDaiBeforeSwap = dai.balanceOf(AddrETH);
        eth.approve(address(swapContract), 1);

        swapContract.swap(AddrETH, AddrDAI, 1);

        uint balanceOfDaiAfterSwap = dai.balanceOf(AddrETH);

        assertGt(balanceOfDaiAfterSwap, balanceOfDaiBeforeSwap);
    }

    function testSwapEthToLINK() public {
        switchSigner(AddrLINK);
        uint256 balance = link.balanceOf(AddrLINK);
        link.transfer(address(swapContract), balance);

        switchSigner(AddrETH);
        uint balanceOfLinkBeforeSwap = link.balanceOf(AddrETH);
        eth.approve(address(swapContract), 1);
        swapContract.swap(AddrETH, AddrLINK, 1);

        uint balanceOflinkAfterSwap = link.balanceOf(AddrETH);

        assertGt(balanceOflinkAfterSwap, balanceOfLinkBeforeSwap);
    }

    function testSwapLinkToDAI() public {
        switchSigner(AddrDAI);
        uint256 balance = dai.balanceOf(AddrDAI);
        dai.transfer(address(swapContract), balance);

        switchSigner(AddrLINK);
        uint balanceOfDaiBeforeSwap = dai.balanceOf(AddrLINK);
        link.approve(address(swapContract), 1);

        swapContract.swap(AddrLINK, AddrDAI, 1);

        uint balanceOfDaiAfterSwap = dai.balanceOf(AddrLINK);

        assertGt(balanceOfDaiAfterSwap, balanceOfDaiBeforeSwap);
    }

    function testSwapLinkToETH() public {
        switchSigner(AddrETH);
        uint256 balance = eth.balanceOf(AddrETH);
        eth.transfer(address(swapContract), balance);

        switchSigner(AddrLINK);
        uint balanceOfLinkBeforeSwap = eth.balanceOf(AddrLINK);
        link.approve(address(swapContract), 1);

        swapContract.swap(AddrLINK, AddrETH, 1);

        uint balanceOfLinkAfterSwap = eth.balanceOf(AddrLINK);

        assertGt(balanceOfLinkAfterSwap, balanceOfLinkBeforeSwap);
    }

    function testSwapDaiToLINK() public {
        switchSigner(AddrLINK);
        uint256 balance = link.balanceOf(AddrLINK);
        link.transfer(address(swapContract), balance);

        switchSigner(AddrDAI);
        uint balanceOfLinkBeforeSwap = link.balanceOf(AddrDAI);
        dai.approve(address(swapContract), 1);

        swapContract.swap(AddrDAI, AddrLINK, 1);

        uint balanceOfLinkAfterSwap = link.balanceOf(AddrDAI);

        assertGt(balanceOfLinkAfterSwap, balanceOfLinkBeforeSwap);
    }

    function testSwapDaiToETH() public {
        switchSigner(AddrETH);
        uint256 balance = eth.balanceOf(AddrETH);
        eth.transfer(address(swapContract), balance);

        switchSigner(AddrDAI);
        uint balanceOfEthBeforeSwap = eth.balanceOf(AddrDAI);
        dai.approve(address(swapContract), 1);

        swapContract.swap(AddrDAI, AddrETH, 1);

        uint balanceOfEthAfterSwap = eth.balanceOf(AddrDAI);

        assertGt(balanceOfEthAfterSwap, balanceOfEthBeforeSwap);
    }

    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }

    function switchSigner(address _newSigner) public {
        address foundrySigner = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
        if (msg.sender == foundrySigner) {
            vm.startPrank(_newSigner);
        } else {
            vm.stopPrank();
            vm.startPrank(_newSigner);
        }
    }
}
