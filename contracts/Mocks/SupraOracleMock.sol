pragma solidity 0.8.19;

import './../libraries/VaultStruct.sol';
import './../libraries/ISupraSValueFeed.sol';

contract SupraOracleMock{

    
    function getSvalue(uint256 _pairIndex)
        external 
        view
        returns (ISupraSValueFeed.priceFeed memory){
            if (_pairIndex == 7){

               /* ISupraSValueFeed.priceFeed pfRet = ISupraSValueFeed.priceFeed({
                    round : 2,
                    decimals : 18,
                    time : 10,
                    price : 11
                    
                    });      */   

                return ISupraSValueFeed.priceFeed({
                    round : 2,
                    decimals : 18,
                    time : 10,
                    price : 11
                    
                    });               
            }   
        }

 struct Tip{    
            address from; 
            address vaultFor;               
            uint amount;                              
        }           

    //Function to fetch the data for a multiple data pairs
    function getSvalues(uint256[] memory _pairIndexes)
        external
        view
        returns (ISupraSValueFeed.priceFeed[] memory){

           // ISupraSValueFeed.priceFeed memory p1 =  ISupraSValueFeed.priceFeed(2,5,10,11);
           // ISupraSValueFeed.priceFeed memory p2 =  ISupraSValueFeed.priceFeed(1,6,10,12);
           // ISupraSValueFeed.priceFeed memory p3 =  ISupraSValueFeed.priceFeed(2,5,10,15);

            ISupraSValueFeed.priceFeed[] memory pRet;
            //pRet.push(p1);
            //pRet.push(p2);
            //pRet.push(p3);
            
            return pRet;
        }


    // Function to convert and derive new data pairs using two pair IDs and a mathematical operator multiplication(*) or division(/).
    //** Curreently only available in testnets
    function getDerivedSvalue(uint256 pair_id_1,uint256 pair_id_2,
        uint256 operation)
        external
        view
        returns (ISupraSValueFeed.derivedData memory){


        }



    // Function to check  the latest Timestamp on which a data pair is updated. This will help you check the staleness of a data pair before performing an action. 
    function getTimestamp(uint256 _tradingPair) 
    external
    view
    returns (uint256){


    }

}


