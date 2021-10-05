// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;
pragma experimental ABIEncoderV2;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract PowerTONSwapper {
    IERC20 wton;
    IERC20 tos;
    ISwapRouter uniswapRouter;

    event Swapped(
        uint256 amount
    );

    constructor(
        address _wton,
        address _tos,
        address _uniswapRouter
    )
    {
        wton = IERC20(_wton);
        tos = IERC20(_tos);
        uniswapRouter = ISwapRouter(_uniswapRouter);
    }

    function approveToUniswap() external {
        wton.approve(
            address(uniswapRouter),
            type(uint256).max
        );
    }

    function swap() external {
        uint256 wtonBalance = getWTONBalance();

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: address(wton),
                tokenOut: address(tos),
                fee: 3000,
                recipient: address(this),
                deadline: block.timestamp + 1000,
                amountIn: wtonBalance,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        ISwapRouter(uniswapRouter).exactInputSingle(params);

        uint256 burnAmount = tos.balanceOf(address(this));
        tos.transfer(address(1), burnAmount);

        emit Swapped(burnAmount);
    }

    function getWTONBalance() public view returns(uint256) {
        return wton.balanceOf(address(this));
    }
}
