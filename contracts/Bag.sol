// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './libraries/VaultStruct.sol';

import './libraries/ISupraSValueFeed.sol';

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import "hardhat/console.sol";

contract Bag{

        // Tips by owner
        mapping(address => VaultStruct.Tip) Tips;
        ISupraSValueFeed internal sValueFeed;


        // make router inherit instead of a constructor parameter
        address public swapRouter;
        address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        string name;
        uint totalAmount;  
        uint id;
      
        address[] tipsOwnersList;
        
        // Tokens
        mapping(bytes32 => VaultStruct.Token) public tokensByTick;
        mapping(address => VaultStruct.Token) public tokensByAddress;

        bytes32[] public tokenList;
        uint256[] public tokenSupraOracleIndex;

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
            uint[] memory _tokenSupraIndex,
            address _swapRouter, 
            address _supraOracle
             ){
            for(uint i=0;i<_tokensTickers.length;i++)
            {                
                 tokensByTick[_tokensTickers[i]] = VaultStruct.Token(_tokensTickers[i], _tokensAddress[i],_tokenSupraIndex[i]);
                 tokensByAddress[_tokensAddress[i]] = VaultStruct.Token(_tokensTickers[i], _tokensAddress[i],_tokenSupraIndex[i]);
                 tokenList.push(_tokensTickers[i]);     
                 tokenSupraOracleIndex.push(_tokenSupraIndex[i]);          
            }
            owner= _from;            
            name = _name; 
            id=_id;       
            BagMainAddr = _bagMain;  
            sValueFeed = ISupraSValueFeed(_supraOracle);
            swapRouter = _swapRouter;       
          }
             
        
        
        function deposit(uint _amount) external payable onlyOwner {
           require(IERC20(weth).balanceOf(msg.sender) >= _amount,"not enough minerals !");          
         
           TransferHelper.safeTransferFrom(weth, msg.sender, address(this), _amount);        
          
           applyStrategie();
          
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

        function applyStrategie() internal  {

           // ISupraSValueFeed.priceFeed[] memory supraOraclePrices = getPriceForMultiplePair(tokenSupraOracleIndex);
           // console.log("oracle");
            //console.log(supraOraclePrices);


            // compute total amount tokens holding + USDC
            uint256[] memory tokenHoldingUSDC = new uint256[](tokenList.length);
            uint256 _totalAmountUSDC = IERC20(weth).balanceOf(address(this));

            for (uint i = 0 ; i < tokenList.length;i++)
            {   
                 
                tokenHoldingUSDC[i] = IERC20(tokensByTick[tokenList[i]].tokenAddress).balanceOf(address(this));
                _totalAmountUSDC += tokenHoldingUSDC[i];
            }       

            // calcul part
            uint256  part = _totalAmountUSDC / (tokenList.length);   
          

            for (uint i = 0 ; i < tokenList.length;i++)
            {                           
                if (tokenHoldingUSDC[i] > part)
                {
                  //  swapExactInputSingle(part, _token,tokensByTick[tokenList[i]].tokenAddress);
                }   
            }   

              for (uint i = 0 ; i < tokenList.length;i++)
            {      
               
                if (tokenHoldingUSDC[i] < part)
                {   
                  //  swapExactInputSingle(part, _token,tokensByTick[tokenList[i]].tokenAddress);
                }
              
            }   
        }           
            
        


        function swapExactInputSingle(uint256 _amountIn, address _tokenToSell, address _tokenToBuy) internal returns (uint256 amountOut) {
                  
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
                    amountOutMinimum: 0,
                    sqrtPriceLimitX96: 0
                });

            // The call to `exactInputSingle` executes the swap.
            amountOut = ISwapRouter(swapRouter).exactInputSingle(params);

            console.log(
                "amount out  %s  %s from %s",
                amountOut,
                _tokenToBuy,
                _tokenToSell
            );
        }

        // requesting s-values for multiple pairs
        function getPriceForMultiplePair (uint256[] memory _pairIndexes) 
            internal 
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
                tokensByTick[tokenList[i]].tokenAddress,
                tokensByTick[tokenList[i]].supraIndex
                );
            }
            return _tokens;
        }
    
        function addToken (
            bytes32 _ticker,
            address _tokenAddress,
            uint _supraIndex)           
            onlyOwner
            external {                 
            tokensByTick[_ticker] = VaultStruct.Token(_ticker, _tokenAddress,_supraIndex);
            tokensByAddress[_tokenAddress] = tokensByTick[_ticker];      
            tokenList.push(_ticker);
            tokenSupraOracleIndex.push(_supraIndex);
        }      

        function removeToken (
            bytes32 ticker)           
            onlyOwner
            external {                 
            tokensByAddress[tokensByTick[ticker].tokenAddress] = VaultStruct.Token(0x0, address(0), 0);
            tokensByTick[ticker] = VaultStruct.Token(0x0, address(0),0);

            for(uint256  i ; i < tokenList.length ; i++){

                if (tokenList[i] == ticker){
                    tokenList[i] =  tokenList[tokenList.length -1];                    
                    tokenList.pop();

                    tokenSupraOracleIndex[i] = tokenSupraOracleIndex[tokenSupraOracleIndex.length-1];
                    tokenSupraOracleIndex.pop();
                }                
            }         
        }      
       
        function updateSupraSvalueFeed(ISupraSValueFeed _newSValueFeed) 
            external 
            onlyOwner {
            sValueFeed = _newSValueFeed;
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