
pragma solidity 0.8.19;
pragma abicoder v2;
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
// depending on the requirement, you may build one or more data structures given below. 

contract SwapRouterMock {
   
        function exactInputSingle(ExactInputSingleParams  params)
        external payable returns (uint256 amountOut)
        {
            return 15;
            
        }
}