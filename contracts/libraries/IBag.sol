// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma abicoder v2;
import './BagStruct.sol';



interface IBag{

                         
        
        function deposit(uint256 _amount) external payable  ;

        function retire() external payable  ;
      
     
        function getBalance()external view returns (uint);

        // TODO : faire une structure pour retourner les tokens et qtité possédée 
        function getBalances()external view returns (uint);
   
        function getTokens() 
            external 
            view 
            returns(BagStruct.Token[] memory) ;
    
       

        function addToken (
            bytes32 _ticker,
            address _tokenAddress,
            address _chainLinkAddress)           
            
            external ;

        function removeToken (
            bytes32 ticker)           
            
            external ;
               


        
        function getOwner() external view returns (address );

}