// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './libraries/VaultStruct.sol';

import './libraries/supraOraclesStruct.sol';

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
//import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import './libraries/TransferHelper.sol';


contract Bag{

        // Tips by owner
        mapping(address => VaultStruct.Tip) Tips;
        ISupraSValueFeed internal sValueFeed;

        
        // make router inherit instead of a constructor parameter
        ISwapRouter public  swapRouter;

        string name;
        uint totalAmount;  
        uint id;
      
        address[] tipsOwnersList;
        
        // Tokens
        mapping(bytes32 => VaultStruct.Token) public tokens;
        bytes32[] public tokenList;

        struct Token {
            bytes32 ticker;
            address tokenAddress;
        }      

        address owner; 
        address BagMainAddr;             
          
        ////////// CONSTRUCTOR ////////////
        constructor(
            uint _id,
            string memory _name,
            address _from,
            address _bagMain,
            bytes32[] memory  _tokensTickers,
            address[] memory _tokensAddress,
            address _swapRouter, 
            address _supraOracle
             ){
            for(uint i=0;i<_tokensTickers.length;i++)
            {                
                 tokens[_tokensTickers[i]] = VaultStruct.Token(_tokensTickers[i], _tokensAddress[i]);
                 tokenList.push(_tokensTickers[i]);               
            }
            owner= _from; 
           
            name = _name; 
            id=_id;       
            BagMainAddr = _bagMain;  
            sValueFeed = ISupraSValueFeed(_supraOracle);
            swapRouter = _swapRouter;
             
        }
        
        function deposit(uint _amount) external payable onlyOwner {
           // TODO
           
           // Buy equal part of all tokens 
          uint256 part = _amount / tokenList.length;

          for (uint i = 0 ; i < tokenList.length;i++)
          {
            

          }

        }        

       

        // requesting s-values for multiple pairs
        function getPriceForMultiplePair(uint256[] memory _pairIndexes) 
            external 
            view 
            returns (ISupraSValueFeed.priceFeed[] memory) {
            return sValueFeed.getSvalues(_pairIndexes);
        }


        function getMarketCapsMultiplePair(address[] memory _tokensAdress)
            external 
            view
            returns (uint256[] memory){
            uint256[] memory returnArray = new uint256[](_tokensAdress.length);

            for(uint i=0;i<_tokensAdress.length;i++){
                returnArray[i] = IERC20(_tokensAdress[i]).totalSupply();
            }
            
            return returnArray;
        }

        function getBalance()external view returns (uint){
            return address(this).balance;

        }

        // TODO : faire une structure pour retourner les tokens et qtité possédée 
        function getBalances()external view returns (uint){
            return address(this).balance;

        }

        function retire() onlyOwner external  returns (bool)  {  
                    // TODO
                    // require Only Owner
                    // Sell all tokens and send to owner

                 //  (bool success, bytes memory data)=  owner.call{value:totalAmount}();
                                     
                    
                    return false;
         }               
    

        function getTokens() 
            external 
            view 
            returns(VaultStruct.Token[] memory) {
            VaultStruct.Token[] memory _tokens = new VaultStruct.Token[](tokenList.length);
            for (uint i = 0; i < tokenList.length; i++) {
                _tokens[i] = VaultStruct.Token(
                tokens[tokenList[i]].ticker,
                tokens[tokenList[i]].tokenAddress
                );
            }
            return _tokens;
        }
    
        function addToken (
            bytes32 ticker,
            address tokenAddress)           
            onlyBagMain
            external {
            tokens[ticker] = VaultStruct.Token(ticker, tokenAddress);
            tokenList.push(ticker);
        }

        
       
        
        fallback() external payable {
            require(msg.data.length == 0);
        }
        
        // TODO : retourner plus d'infos sur la composition du bag
        function getBag() external view returns(VaultStruct.Bag memory){
            return VaultStruct.Bag(id,address(this),  name, owner, totalAmount);

        }      
       
       

        modifier tokenExist(bytes32 ticker) {
            require(
                tokens[ticker].tokenAddress != address(0),
                'this token does not exist'
            );
        _;
        }
        
        function getOwner() external view returns (address )
        {
            return owner;

        }

        modifier onlyOwner {
            require(msg.sender == owner, 'only owner');
            _;
        }

         modifier onlyBagMain() {
            require(msg.sender == BagMainAddr, 'only BagMain');
            _;
        }


}