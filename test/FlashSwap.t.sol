// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {FlashSwap} from "../src/FlashSwap.sol";

import {IERC20} from "../interfaces/IERC20.sol";

contract FlashSwapTest is Test {
    FlashSwap public flashSwap;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function setUp() public {
        uint256 mainnetFork = vm.createFork("https://eth.llamarpc.com");
        vm.selectFork(mainnetFork);
        flashSwap = new FlashSwap();
        deal(WETH, address(flashSwap), 1 ether);
    }

    function testFlash() public {
        flashSwap.flash();
    }
}
