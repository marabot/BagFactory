// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';

import "hardhat/console.sol";

contract SwapForTest {


    address swapRouter;
    constructor(address _swapRouter){      
        swapRouter = _swapRouter;  
    }

    

    function swapTokens(uint256 _amountIn, address _tokenToSell, address _tokenToBuy) external returns (uint256 amountOut) {
            
            require(IERC20(_tokenToSell).balanceOf(msg.sender) >= _amountIn,"not enough minerals !");          
        
           TransferHelper.safeTransferFrom(_tokenToSell, msg.sender, address(this), _amountIn);   

            // Approve the router to spend USDC.
            TransferHelper.safeApprove(_tokenToSell, address(swapRouter), _amountIn);

            // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
            // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
            uint24 poolFee = 3000;

            ISwapRouter.ExactInputSingleParams memory params =
                ISwapRouter.ExactInputSingleParams({
                    tokenIn: _tokenToSell,
                    tokenOut: _tokenToBuy,
                    fee: poolFee,
                    recipient: msg.sender,
                    deadline: block.timestamp,
                    amountIn: _amountIn,
                    amountOutMinimum: 0,
                    sqrtPriceLimitX96: 0
                });

             console.log(
                            "amount in  %s  %s from  %s",
                            _amountIn,
                            _tokenToBuy,
                            _tokenToSell
                        );

            
            // The call to `exactInputSingle` executes the swap.
            amountOut = ISwapRouter(swapRouter).exactInputSingle(params);   
          //  TransferHelper.safeTransferFrom(_tokenToBuy, address(this), msg.sender , IERC20(_tokenToBuy).balanceOf(address(this)));         
        }       
}