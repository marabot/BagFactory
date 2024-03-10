// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './libraries/VaultStruct.sol';

import './libraries/ISupraSValueFeed.sol';

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
//import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import './libraries/TransferHelper.sol';


contract Bag{

        // Tips by owner
        mapping(address => VaultStruct.Tip) Tips;
        ISupraSValueFeed internal sValueFeed;

        address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        
        // make router inherit instead of a constructor parameter
        address public swapRouter;

        string name;
        uint totalAmount;  
        uint id;
      
        address[] tipsOwnersList;
        
        // Tokens
        mapping(bytes32 => VaultStruct.Token) public tokensByTick;
        mapping(address => VaultStruct.Token) public tokensByAddress;

        bytes32[] public tokenList;

        uint[] public TokenPartsInUSDC;



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
                 tokensByTick[_tokensTickers[i]] = VaultStruct.Token(_tokensTickers[i], _tokensAddress[i]);
                 tokensByAddress[_tokensAddress[i]] = VaultStruct.Token(_tokensTickers[i], _tokensAddress[i]);
                 tokenList.push(_tokensTickers[i]);               
            }
            owner= _from; 
           
            name = _name; 
            id=_id;       
            BagMainAddr = _bagMain;  
            sValueFeed = ISupraSValueFeed(_supraOracle);
            swapRouter = _swapRouter;
             
        }
        
        function deposit(uint _amount, address _token) external payable onlyOwner {
           // TODO
          
           require(tokensByAddress[_token].tokenAddress != address(0x0) , "Token not available");

           // Buy equal part of all tokens 
          uint256 part = _amount / tokenList.length;

          for (uint i = 0 ; i < tokenList.length;i++)
          {            
            swapExactInputSingle(part, _token,tokensByTick[tokenList[i]].tokenAddress);
          }
        }        

        function retire(address _token) external payable onlyOwner {
           // TODO
           require(tokensByAddress[_token].tokenAddress !=address(0x0), "Token not available");
           // sell all tokens        
          for (uint i = 0 ; i < tokenList.length;i++)
          {
            uint amount = IERC20(tokensByTick[tokenList[i]].tokenAddress).balanceOf(address(this));
            swapExactInputSingle(amount, tokensByTick[tokenList[i]].tokenAddress,_token);
          }
        }   

        function computeParts() internal returns (uint[] memory) {
            // get all price
            // get all amounts
            uint[] memory ret;
            // add all values / total values
           
            return ret;
        }


        function swapExactInputSingle(uint256 _amountIn, address _tokenToSell, address _tokenToBuy) internal returns (uint256 amountOut) {
            // msg.sender must approve this contract

            // Transfer the specified amount of USDC to this contract.
            TransferHelper.safeTransferFrom(USDC, msg.sender, address(this), _amountIn);

            // Approve the router to spend USDC.
            TransferHelper.safeApprove(USDC, address(swapRouter), _amountIn);

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

            // The call to `exactInputSingle` executes the swap.
            amountOut = ISwapRouter(swapRouter).exactInputSingle(params);
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

       
   
        function getTokens() 
            external 
            view 
            returns(VaultStruct.Token[] memory) {
            VaultStruct.Token[] memory _tokens = new VaultStruct.Token[](tokenList.length);
            for (uint i = 0; i < tokenList.length; i++) {
                _tokens[i] = VaultStruct.Token(
                tokensByTick[tokenList[i]].ticker,
                tokensByTick[tokenList[i]].tokenAddress
                );
            }
            return _tokens;
        }
    
        function addToken (
            bytes32 ticker,
            address tokenAddress)           
            onlyBagMain
            external {
            tokensByTick[ticker] = VaultStruct.Token(ticker, tokenAddress);
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
                tokensByTick[ticker].tokenAddress != address(0),
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