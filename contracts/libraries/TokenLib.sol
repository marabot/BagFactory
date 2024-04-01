pragma solidity 0.8.19;
import {AggregatorV3Interface} from  "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library TokenLib{
    
    
    function getWethPrice() public view returns (uint256 _wethPrice){                   
            AggregatorV3Interface wethOracle = AggregatorV3Interface(0x13e3Ee699D1909E989722E753853AE30b17e08c5);
            

            (
                /*uint80 roundID */,
                int answer,
                /*uint startedAt*/,
                /*uint timeStamp*/,
                /*uint80 answeredInRound*/
            ) = wethOracle.latestRoundData();
            _wethPrice = uint256(answer) ;      
        }

        function getChainlinkDataFeedLatestAnswer(bytes32 _ticker, AggregatorV3Interface datafeed) public view returns (uint256) {
                    
           // prettier-ignore
            (
                /*uint80 roundID */,
                int answer,
                /*uint startedAt*/,
                /*uint timeStamp*/,
                /*uint80 answeredInRound*/
            ) = datafeed.latestRoundData();

            uint256 ret = uint256 (answer);
           //uint256 ret = 8;
            return ret;
        }
}
