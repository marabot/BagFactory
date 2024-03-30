// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;


library VaultStruct{
     struct Token {
            bytes32 ticker;
            address tokenAddress; 
            address chainLinkAddress;
        }

        struct Bag {
            address addr;
            string name;
            address from;                      
            uint totalAmount;
        }


          struct Tip{    
            address from; 
            address vaultFor;               
            uint amount;                              
        }           
}