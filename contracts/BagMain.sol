// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './Bag.sol';
import './libraries/VaultStruct.sol';

contract BagMain{
        
        //Splits & Vaults par owner
      
        mapping(address=> address[]) bagsByOwner;     
    
        mapping(address =>Bag) bagByAddr;
 
        Bag[] allBags;
                                   
        address admin;       
        address swapRouter;
        uint nextBagId;  

        // Tokens
        mapping(bytes32 => VaultStruct.Token) public tokens;
        bytes32[] public tokenList;

        event TipVaultCreated(address indexed _from, address _addr);
        event TipVaultDeposit(address indexed _from, address _addr, uint _value);
        event TipVaultClosed(address indexed _from, address _addr);
        event TipVaultWithdraw(address indexed _from);

        
        constructor(VaultStruct.Token[] memory _tokens,
                    address _swapRouter){
            admin= msg.sender;     
            swapRouter = _swapRouter;

             for(uint i=0;i<_tokens.length;i++)
            {                
                 tokens[_tokens[i].ticker] = _tokens[i];                
                 tokenList.push(_tokens[i].ticker);               
            }
        }

        // TODO prendre en paramètres une liste de token et TOP combien avoir pour composition du bag  
        function createBag(string memory _name) payable external returns(address){      
         
            bytes32[] memory tokensTickers = new bytes32[](tokenList.length);
            address[] memory tokensAddress = new address[](tokenList.length);
            address[] memory tokenChainLinkAddress = new address[](tokenList.length);

            for (uint i = 0; i < tokenList.length; i++) {
                tokensTickers[i] = tokenList[i];
                tokensAddress[i] = tokens[tokenList[i]].tokenAddress;   
                tokenChainLinkAddress[i] = tokens[tokenList[i]].chainLinkAddress;                        
            }

            nextBagId++;
            Bag newbag = new Bag(nextBagId,_name,msg.sender, address(this), tokensTickers,tokensAddress,tokenChainLinkAddress, swapRouter);

            address[] storage tp = bagsByOwner[msg.sender];
            tp.push(address(newbag));

            bagByAddr[address(newbag)] = newbag;
            allBags.push(newbag);
            emit TipVaultCreated(msg.sender, address(newbag));
            return address(newbag);
        }

            

        function getBagsFromOwner(address _owner) external view returns (address[] memory){                      
           return bagsByOwner[_owner];     
        }

        

        function getAllBags() external view returns (VaultStruct.Bag[] memory){
           VaultStruct.Bag[] memory  ret = new VaultStruct.Bag[](allBags.length);

           for(uint i =0 ;i<allBags.length;i++)
           {               
               ret[i] = allBags[i].getBag();
           }           
            return ret;
        }

      
         function getTokens() 
            external 
            view 
            returns(VaultStruct.Token[] memory) {  

            VaultStruct.Token[] memory _tokens = new VaultStruct.Token[](tokenList.length);
            for (uint i = 0; i < tokenList.length; i++) {
                _tokens[i] = VaultStruct.Token(
                tokens[tokenList[i]].ticker,
                tokens[tokenList[i]].tokenAddress,
                tokens[tokenList[i]].chainLinkAddress
                );
            }
        }

        function getBalance() external view returns(uint){
            return address(this).balance;

        }
    
        function addToken(
            bytes32 _ticker,
            address _tokenAddress, 
            address _chainlinkAddress)
            onlyAdmin()
            external {
            tokens[_ticker] = VaultStruct.Token(_ticker, _tokenAddress,_chainlinkAddress);                
            tokenList.push(_ticker);     
        }

        function string_tobytes( string memory s) internal pure  returns (bytes memory ){
            bytes memory b3 = bytes(s);
            return b3;
        }

        
        modifier onlyAdmin() {
            require(msg.sender == admin, 'only admin');
            _;
        }
}
