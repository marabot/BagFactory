// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './libraries/BagStruct.sol';
import './libraries/TokenLib.sol';
import "@openzeppelin/contracts-upgradeable-4.7.3/proxy/utils/Initializable.sol";

import {AggregatorV3Interface} from  "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';

import "hardhat/console.sol";

contract Bag is Initializable{

        // make router inherit instead of a constructor parameter
        address public swapRouter;        
        address public weth;
        string name;
        uint totalAmount;  
      
        address[] tipsOwnersList;
        
        // Tokens
        mapping(bytes32 => BagStruct.Token) public tokensByTick;
        mapping(address => BagStruct.Token) public tokensByAddress;
        mapping(bytes32 => AggregatorV3Interface) internal dataFeeds;

        bytes32[] public tokenList;        
        
        uint256[] public tokenHolding;
        uint256[] public tokenHoldingUSDC;          
        uint256[] prices;
        uint256 wethPrice;
        uint256 balWETH;
        uint256 totalAmountUSDC;
        uint256 averageUSDC; 
        uint8 treshold;  

        address owner; 
        address BagMainAddr;  
                    
       
        function initialize(string memory _name,
                    address _from,
                    address _bagMain,
                    bytes32[] memory _tokensTickers,
                    address[] memory _tokensAddress,
                    address[] memory _chainlinkAddr,
                    address _swapRouter, 
                    address _weth,     // weth address 
                    uint8 _treshold   // treshold in % of avrage Holding Value to rebalance
                    )
                public initializer{
                    for(uint i=0;i<_tokensTickers.length;i++)
                    {                
                        tokensByTick[_tokensTickers[i]] = BagStruct.Token(_tokensTickers[i], _tokensAddress[i],_chainlinkAddr[i]);
                        tokensByAddress[_tokensAddress[i]] = BagStruct.Token(_tokensTickers[i], _tokensAddress[i],_chainlinkAddr[i]);
                        tokenList.push(_tokensTickers[i]);     
                        dataFeeds[_tokensTickers[i]] = AggregatorV3Interface(_chainlinkAddr[i]);                         
                    }
                    owner= _from;            
                    name = _name; 
                    BagMainAddr = _bagMain; 
                    tokenHolding = new uint256[](tokenList.length);
                    tokenHoldingUSDC = new uint256[](tokenList.length);  
                    swapRouter = _swapRouter;   
                    weth = _weth;
                    treshold = _treshold;
          }             
        
        function deposit(uint256 _amount) external  onlyOwner {
          /* console.log("sender",msg.sender);
           console.log("weth", weth);*/
           require(IERC20(weth).balanceOf(msg.sender) >= _amount,"not enough minerals !");          
        
           TransferHelper.safeTransferFrom(weth, msg.sender, address(this), _amount);        
          
           applyStrategie();          
        }        

        function retire() external  onlyOwner {           
          // sell all tokens        
          for (uint i = 0 ; i < tokenList.length;i++)
          {
            uint amount = IERC20(tokensByTick[tokenList[i]].tokenAddress).balanceOf(address(this));
            swapExactInputSingle(amount, tokensByTick[tokenList[i]].tokenAddress,weth,0);
          }
          TransferHelper.safeTransferFrom(weth, address(this), owner,  IERC20(weth).balanceOf(address(this)));
        }          
   
        function rebalanceIfNeeded() external returns (bool){
            applyStrategie();
            return true;
        }

        function applyStrategie() internal  {
            
            prices = getPrices();
            wethPrice = TokenLib.getWethPrice(); 
            console.log("weth price :"); 
            console.log(wethPrice); 
            bool[] memory soldTokens = new bool[](tokenList.length);
            uint256 part;       
            totalAmountUSDC = 0;
             
           

            updateHoldingtokensValue();
 
            averageUSDC = totalAmountUSDC / tokenList.length;   
            

            sellOverweightTokens(soldTokens);           

            balWETH = IERC20(weth).balanceOf(address(this));
            console.log("weth balance after sell :");       
            console.log(balWETH); 

            uint256 soldTokensCount = 0;
             for (uint i = 0 ; i < soldTokens.length;i++)
            {
                if (soldTokens[i])soldTokensCount++;
            }

            part = balWETH / (tokenList.length - soldTokensCount);
            console.log("test3"); 
            console.log(balWETH); 
            console.log(part); 

            if (IERC20(weth).balanceOf(address(this))>1000) BuytokensWithWeth(soldTokens, part);   

            console.log("test3"); 

            updateHoldingtokensValue();        

           // logTokens();
        }        

        //  get amount and amount in USDC for each tokens
        function updateHoldingtokensValue() internal {
            for (uint i = 0 ; i < tokenList.length;i++)
            {                  
               tokenHolding[i] = IERC20(tokensByTick[tokenList[i]].tokenAddress).balanceOf(address(this));   
               tokenHoldingUSDC[i] = tokenHolding[i] * prices[i] / (10**8); 
               totalAmountUSDC+= tokenHoldingUSDC[i];              
            }
         //   console.log("update");          
        }

        function sellOverweightTokens( bool[] memory _soldTokens) internal {
          
            for (uint i = 0 ; i < tokenList.length;i++)
            {   
              //  if (tokenHoldingUSDC[i]>averageUSDC){
                    if (tokenHoldingUSDC[i] > averageUSDC + (averageUSDC * treshold /100)){                   
                        uint256 amountUSD = (averageUSDC * treshold /100);                     
                        uint256 amountOut = (amountUSD /  wethPrice * (10**8))*98/100;      

                        swapExactInputSingle((tokenHolding[i] * treshold / 100),tokensByTick[tokenList[i]].tokenAddress,weth, amountOut);
                        _soldTokens[i] = true;                        
                    }
              //  }            
            }          
        }          

        function BuytokensWithWeth(bool[] memory _soldTokens, uint256 _part) internal {
            
            for (uint i = 0 ; i < tokenList.length;i++)
            {   
               if (!_soldTokens[i]){
                    uint256 amountOut = _part *98/100;
                   
                    swapExactInputSingle((_part -1), weth, tokensByTick[tokenList[i]].tokenAddress,  amountOut);
               }
            }
        }          

        function getPrices() public view returns (uint256[] memory _prices){                       
            _prices= new uint256[](tokenList.length);
            for (uint8 i =0;i<tokenList.length;i++){              
                _prices[i] = TokenLib.getChainlinkDataFeedLatestAnswer(tokenList[i], dataFeeds[tokenList[i]]);               
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

        function getTokens() 
            external 
            view 
            returns(BagStruct.Token[] memory) {
            BagStruct.Token[] memory _tokens = new BagStruct.Token[](tokenList.length);
            for (uint i = 0; i < tokenList.length; i++) {
                _tokens[i] = BagStruct.Token(
                tokensByTick[tokenList[i]].ticker,
                tokensByTick[tokenList[i]].tokenAddress,
                tokensByTick[tokenList[i]].chainLinkAddress
                );
            }
            return _tokens;
        }
    
        function addToken (
            bytes32 _ticker,
            address _tokenAddress,
            address _chainLinkAddress)           
            onlyOwner
            external {   

            tokensByTick[_ticker] = BagStruct.Token(_ticker, _tokenAddress,_chainLinkAddress);
            tokensByAddress[_tokenAddress] = tokensByTick[_ticker];      
            tokenList.push(_ticker);

            tokenHolding = new uint256[](tokenList.length);
            tokenHoldingUSDC = new uint256[](tokenList.length);  

            dataFeeds[_ticker] = AggregatorV3Interface(_chainLinkAddress);

            if (IERC20(weth).balanceOf(address(this))>1)applyStrategie(); 
        }  


        function removeToken (
            bytes32 _ticker)           
            onlyOwner
            external {                 
            
            prices = getPrices();
            for(uint256  i ; i < tokenList.length ; i++){

                if (tokenList[i] == _ticker ){
                    if (tokenHolding[i]!=0){
                        uint256 amountOut = (tokenHolding[i] /  prices[i] * (10**8))*98/100; 
                       
                    swapExactInputSingle(tokenHolding[i], tokensByTick[tokenList[i]].tokenAddress, weth,  amountOut);
                    }
                    
                    tokenList[i] =  tokenList[tokenList.length -1];                    
                    tokenList.pop();
                }                
            }      

            tokenHolding = new uint256[](tokenList.length);
            tokenHoldingUSDC = new uint256[](tokenList.length);  
            // console.log("bal weth to buy :", IERC20(weth).balanceOf(address(this)));
            tokensByAddress[tokensByTick[_ticker].tokenAddress] = BagStruct.Token(0x0, address(0), address(0));
            tokensByTick[_ticker] = BagStruct.Token(0x0, address(0), address(0));
            if (IERC20(weth).balanceOf(address(this))>0)applyStrategie();    
        }  
       
        // TODO : retourner plus d'infos sur la composition du bag
        function getBag() external view returns(BagStruct.Bag memory){
            return BagStruct.Bag(address(this),  name, owner, totalAmount);
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