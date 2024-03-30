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
      
        address[] tipsOwnersList;
        
        // Tokens
        mapping(bytes32 => VaultStruct.Token) public tokensByTick;
        mapping(address => VaultStruct.Token) public tokensByAddress;
        mapping(bytes32 => AggregatorV3Interface) internal dataFeeds;

        bytes32[] public tokenList;        
        
        uint256[] public tokenHolding;
        uint256[] public tokenHoldingUSDC;          
        uint256[] prices;
        uint256 wethPrice ;
        uint256 balWETH;
        uint256 totalAmountUSDC;
        uint256 averageUSDC;   

        struct Token {
            bytes32 ticker;
            address tokenAddress; 
        }      

        address owner; 
        address BagMainAddr;             
          
        ////////// CONSTRUCTOR ////////////
        constructor( 
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
            BagMainAddr = _bagMain; 
            tokenHolding = new uint256[](tokenList.length);
            tokenHoldingUSDC = new uint256[](tokenList.length);  
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

        function getWethPrice() internal view returns (uint256 _wethPrice){                   
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

        function applyStrategie() internal  {
            
            prices = getPrices();
            wethPrice = getWethPrice(); 
            bytes32[] memory soldTokens;
            uint256 part;       
            totalAmountUSDC = 0;

            updateHoldingtokensValue();
 
            averageUSDC = totalAmountUSDC / tokenList.length;

            sellOverweightTokens(soldTokens);           

            balWETH = IERC20(weth).balanceOf(address(this));
            part = balWETH / (tokenList.length - soldTokens.length);
            
            BuytokensWithWeth(soldTokens, part);   

            updateHoldingtokensValue();        
            logTokens();
        }        

        //  get amount and amount in USDC for each tokens
        function updateHoldingtokensValue() internal {
            for (uint i = 0 ; i < tokenList.length;i++)
            {                  
               tokenHolding[i] = IERC20(tokensByTick[tokenList[i]].tokenAddress).balanceOf(address(this));   
               tokenHoldingUSDC[i] = tokenHolding[i] * prices[i] / (10**8); 
               totalAmountUSDC+= tokenHoldingUSDC[i];              
            }
            console.log("update");
           
        }

        function sellOverweightTokens( bytes32[] memory _soldTokens) internal {
            uint8 soldtokensindex = 0;

            for (uint i = 0 ; i < tokenList.length;i++)
            {   
                if (tokenHoldingUSDC[i]>averageUSDC){
                    if (tokenHoldingUSDC[i]- averageUSDC > (averageUSDC/10)){
                        uint256 amountUSD = averageUSDC/20;
                        uint256 amountInWETH = amountUSD / wethPrice;
                        uint256 amountOut = (amountUSD /  prices[i] * (10**8))*98/100;                                              

                        swapExactInputSingle(amountInWETH,tokensByTick[tokenList[i]].tokenAddress,weth, amountOut);
                        _soldTokens[soldtokensindex] = tokenList[i];
                        soldtokensindex++;
                    }
                }            
            }
            console.log("sell");
            logTokens();
        }          

        function BuytokensWithWeth(bytes32[] memory _soldTokens, uint256 _part) internal {
            for (uint i = 0 ; i < tokenList.length;i++)
            {   
               if (!isSoldtoken(tokenList[i], _soldTokens)){
                    uint256 amountOut = _part *98/100;
                    console.log();
                    swapExactInputSingle(_part, weth, tokensByTick[tokenList[i]].tokenAddress,  amountOut);
               }
            }
            console.log("buy");
            logTokens();
        }          

        function getPrices() internal view returns (uint256[] memory _prices){
                       
            _prices= new uint256[](tokenList.length);
            for (uint8 i =0;i<tokenList.length;i++){
              
                _prices[i] = getChainlinkDataFeedLatestAnswer(tokenList[i]);               
            }
        }

        function isSoldtoken(bytes32 _ticker, bytes32[] memory _soldTokens) internal pure returns (bool resp){
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

           /* console.log(
                            "amount in  %s  %s from  %s",
                            _amountIn,
                            _tokenToBuy,
                            _tokenToSell
                        );

*/
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

            tokenHolding = new uint256[](tokenList.length);
            tokenHoldingUSDC = new uint256[](tokenList.length);  

            dataFeeds[_ticker] = AggregatorV3Interface(_chainLinkAddress);

            //applyStrategie();  
        }  

        function logTokens() internal {
           /* console.log("token list count", tokenList.length);
            console.log("token 1 : %s", tokensByTick[tokenList[0]].tokenAddress);
            console.log("token 2 : %s", tokensByTick[tokenList[1]].tokenAddress);
            console.log("token 3 : %s", tokensByTick[tokenList[2]].tokenAddress);*/

            console.log("tokenHolding 1:", tokenHoldingUSDC[0]);
             console.log("tokenHolding 2:", tokenHolding[1]);
              console.log("tokenHolding 3:", prices[0]);
        }    

        function removeToken (
            bytes32 ticker)           
            onlyOwner
            external {                 
            
            prices = getPrices();
            logTokens();
            for(uint256  i ; i < tokenList.length ; i++){

                if (tokenList[i] == ticker ){
                    if (tokenHolding[i]!=0){
                        uint256 amountOut = (tokenHolding[i] /  prices[i] * (10**8))*98/100; 
                       
                    swapExactInputSingle(tokenHolding[i], tokensByTick[tokenList[i]].tokenAddress, weth,  amountOut);
                    }
                    
                    tokenList[i] =  tokenList[tokenList.length -1];                    
                    tokenList.pop();
                }                
            }       
            tokensByAddress[tokensByTick[ticker].tokenAddress] = VaultStruct.Token(0x0, address(0), address(0));
            tokensByTick[ticker] = VaultStruct.Token(0x0, address(0), address(0));
           // applyStrategie();    
        }  
               
        fallback() external payable {
            //require(msg.data.length == 0);
        }

        receive() external payable {}
        
        // TODO : retourner plus d'infos sur la composition du bag
        function getBag() external view returns(VaultStruct.Bag memory){
            return VaultStruct.Bag(address(this),  name, owner, totalAmount);
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