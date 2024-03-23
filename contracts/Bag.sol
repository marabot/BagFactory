// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './libraries/VaultStruct.sol';

import {AggregatorV3Interface} from  "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import "hardhat/console.sol";

contract Bag{

        // make router inherit instead of a constructor parameter
        address public swapRouter;
        address public weth = 0x4200000000000000000000000000000000000006;
        string name;
        uint totalAmount;  
        uint id;
      
        address[] tipsOwnersList;
        
        // Tokens
        mapping(bytes32 => VaultStruct.Token) public tokensByTick;
        mapping(address => VaultStruct.Token) public tokensByAddress;
        mapping(bytes32 => AggregatorV3Interface) internal dataFeeds;

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
            bytes32[] memory _tokensTickers,
            address[] memory _tokensAddress,
            address[] memory _chainlinkAddr,
            address _swapRouter
            
             ){
            for(uint i=0;i<_tokensTickers.length;i++)
            {                
                tokensByTick[_tokensTickers[i]] = VaultStruct.Token(_tokensTickers[i], _tokensAddress[i],_chainlinkAddr[i]);
                tokensByAddress[_tokensAddress[i]] = VaultStruct.Token(_tokensTickers[i], _tokensAddress[i],_chainlinkAddr[i]);
                tokenList.push(_tokensTickers[i]);     
                dataFeeds[_tokensTickers[i]] = AggregatorV3Interface(_chainlinkAddr[i]);                         
            }
            owner= _from;            
            name = _name; 
            id=_id;       
            BagMainAddr = _bagMain;  
           
            swapRouter = _swapRouter;       
          }             
        
        
        function deposit(uint256 _amount) external payable onlyOwner {
           require(IERC20(weth).balanceOf(msg.sender) >= _amount,"not enough minerals !");          
        
           TransferHelper.safeTransferFrom(weth, msg.sender, address(this), _amount);        
          
           applyStrategie();
          
        }        

        function retire() external payable onlyOwner {           
          // sell all tokens        
          for (uint i = 0 ; i < tokenList.length;i++)
          {
            uint amount = IERC20(tokensByTick[tokenList[i]].tokenAddress).balanceOf(address(this));
            swapExactInputSingle(amount, tokensByTick[tokenList[i]].tokenAddress,weth,0);
          }
        }          

        function getWethPrice() internal returns (uint256 wethPrice){                   
            AggregatorV3Interface wethOracle = AggregatorV3Interface(0x13e3Ee699D1909E989722E753853AE30b17e08c5);
            (
                /*uint80 roundID */,
                int answer,
                /*uint startedAt*/,
                /*uint timeStamp*/,
                /*uint80 answeredInRound*/
            ) = wethOracle.latestRoundData();
            wethPrice = uint256(answer) ;      
        }

        function applyStrategie() internal  {

            
            uint256[] memory tokenHolding = new uint256[](tokenList.length);
            uint256[] memory tokenHoldingUSDC = new uint256[](tokenList.length);           
            uint256[] memory prices = getPrices();
            uint256 wethPrice = getWethPrice();
            console.log("weth price %s",wethPrice);
            uint256 totalAmountUSDC = 0;
            uint256 average;
            uint256 balWETH; 
            bytes32[] memory soldTokens;
            uint8 soldtokensindex = 0;
            uint256 part;
       

            // get amount and amount in USDC for each tokens
            for (uint i = 0 ; i < tokenList.length;i++)
            {   
               tokenHolding[i] = IERC20(tokensByTick[tokenList[i]].tokenAddress).balanceOf(address(this));   
               tokenHoldingUSDC[i] = tokenHolding[i] * prices[i] / (10**8); 
               totalAmountUSDC+= tokenHoldingUSDC[i];              
            }

            average = totalAmountUSDC / tokenList.length;

          
            for (uint i = 0 ; i < tokenList.length;i++)
            {   
                if (tokenHoldingUSDC[i]>average){
                    if (tokenHoldingUSDC[i]- average > (average/10)){
                        uint256 amountUSD = average/20;
                        uint256 amountInWETH = amountUSD / wethPrice;

                        uint256 amountOut = (amountUSD /  prices[i] * (10**8))*98/100;
                        console.log("Min amountOut  %s",  amountOut);                      

                        swapExactInputSingle(amountInWETH,tokensByTick[tokenList[i]].tokenAddress,weth, amountOut);
                        soldTokens[soldtokensindex] = tokenList[i];
                        soldtokensindex++;
                    }
                }            
            }

            balWETH = IERC20(weth).balanceOf(address(this));
            part = balWETH / (tokenList.length - soldTokens.length);
            
            for (uint i = 0 ; i < tokenList.length;i++)
            {   
               if (!isSoldtoken(tokenList[i], soldTokens)){
                    uint256 amountOut = part *98/100;
                    swapExactInputSingle(part, weth, tokensByTick[tokenList[i]].tokenAddress,  amountOut);
               }
            }
        }        

        function getPrices() internal returns (uint256[] memory prices){
            console.log("nombre de tokens %s", tokenList.length);
            
            prices= new uint256[](tokenList.length);
            for (uint8 i =0;i<tokenList.length;i++){
              
                prices[i] = getChainlinkDataFeedLatestAnswer(tokenList[i]);
                console.log("price %s",  prices[i]*(10**10)); 
            }
        }

        function isSoldtoken(bytes32 _ticker, bytes32[] memory _soldTokens) internal view returns (bool resp){
              for (uint i = 0 ; i < _soldTokens.length;i++){
                    if (_soldTokens[i]== _ticker) resp = true;
              }
        }   

        function swapExactInputSingle(uint256 _amountIn, address _tokenToSell, address _tokenToBuy, uint256 _minAmountOut) internal returns (uint256 amountOut) {
                  
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
                    recipient: address(this),
                    deadline: block.timestamp,
                    amountIn: _amountIn,
                    amountOutMinimum: _minAmountOut,
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
                tokensByTick[tokenList[i]].tokenAddress,
                tokensByTick[tokenList[i]].chainLinkAddress
                );
            }
            return _tokens;
        }
    
        function getChainlinkDataFeedLatestAnswer(bytes32 _ticker) public view returns (uint256) {
          
          
           // prettier-ignore
            (
                /*uint80 roundID */,
                int answer,
                /*uint startedAt*/,
                /*uint timeStamp*/,
                /*uint80 answeredInRound*/
            ) = dataFeeds[_ticker].latestRoundData();

            uint256 ret = uint256 (answer);
           //uint256 ret = 8;
            return ret;
        }

        function addToken (
            bytes32 _ticker,
            address _tokenAddress,
            address _chainLinkAddress)           
            onlyOwner
            external {                 
            tokensByTick[_ticker] = VaultStruct.Token(_ticker, _tokenAddress,_chainLinkAddress);
            tokensByAddress[_tokenAddress] = tokensByTick[_ticker];      
            tokenList.push(_ticker);           
        }      

        function removeToken (
            bytes32 ticker)           
            onlyOwner
            external {                 
            tokensByAddress[tokensByTick[ticker].tokenAddress] = VaultStruct.Token(0x0, address(0), address(0));
            tokensByTick[ticker] = VaultStruct.Token(0x0, address(0), address(0));

            for(uint256  i ; i < tokenList.length ; i++){

                if (tokenList[i] == ticker){
                    tokenList[i] =  tokenList[tokenList.length -1];                    
                    tokenList.pop();
                }                
            }         
        }  
               
        fallback() external payable {
            //require(msg.data.length == 0);
        }

        receive() external payable {}
        
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