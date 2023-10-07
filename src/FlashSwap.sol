// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "../interfaces/IERC20.sol";

import {console2} from "forge-std/Test.sol";

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external;
}

interface IUniswapV2Pair {
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract FlashSwap is IUniswapV2Callee {
    uint256 public number;
    // DAI token0, WETH token1
    address public constant PAIR = 0xA478c2975Ab1Ea89e8196811F51A7B7Ade33eB11;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // uniswap use fee 0.3%
    // 30/10000 -> 0.003 in decimals which is 0.3%
    uint256 public BPS = 10000;
    uint256 public fee = 30;

    //deltay = FF* y * deltax / x + FFdeltaX
    function getAmount0Out(uint256 amountIn) internal returns (uint256 amountOut) {
        (uint256 reserveOut, uint256 reserveIn,) = IUniswapV2Pair(PAIR).getReserves();
        uint256 feeFactor = BPS - fee;
        uint256 numerator = feeFactor * reserveOut * amountIn;
        uint256 denominator = BPS * reserveIn + amountIn * feeFactor;
        amountOut = numerator / denominator;
    }

    function swapExactToken1In(uint256 amountIn) public {
        uint256 amountOut = getAmount0Out(amountIn);
        bytes memory data = abi.encode(PAIR, amountIn);
        IUniswapV2Pair(PAIR).swap(amountOut, 0, address(this), data);
    }

    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external {
        (address pairAddress, uint256 amountIn) = abi.decode(data, (address, uint256));
        IERC20(WETH).transfer(pairAddress, amountIn);
    }
}
