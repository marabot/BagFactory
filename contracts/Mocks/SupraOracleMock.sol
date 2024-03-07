pragma solidity 0.8.19;

import './../libraries/VaultStruct.sol';
import './../libraries/supraOraclesStruct.sol';

contract SupraOracleMock{

    
    function getSvalue(uint256 _pairIndex)
        external 
        view
        returns (priceFeed memory){
            if (_pairIndex == 7){
                return new pricefeed(2,5,10,11);
            }   
        }



    //Function to fetch the data for a multiple data pairs
    function getSvalues(uint256[] memory _pairIndexes)
        external
        view
        returns (priceFeed[] memory){

            priceFeed p1 =  new pricefeed(2,5,10,11);
            priceFeed p2 =  new pricefeed(1,6,10,12);
            priceFeed p3 =  new pricefeed(2,5,10,15);

            priceFeed[] pRet = new priceFeed[3];
            pRet[0] = p1;
            pRet[1] = p2;
            pRet[2] = p3;
            
            return pRet;
        }


    // Function to convert and derive new data pairs using two pair IDs and a mathematical operator multiplication(*) or division(/).
    //** Curreently only available in testnets
    function getDerivedSvalue(uint256 pair_id_1,uint256 pair_id_2,
        uint256 operation)
        external
        view
        returns (derivedData memory){


        }



    // Function to check  the latest Timestamp on which a data pair is updated. This will help you check the staleness of a data pair before performing an action. 
    function getTimestamp(uint256 _tradingPair) 
    external
    view
    returns (uint256){


    }

}


