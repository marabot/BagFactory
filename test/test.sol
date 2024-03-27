// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import 'forge-std/Test.sol';
import {BagMain} from'../contracts/BagMain.sol';
import '../contracts/libraries/VaultStruct.sol';

contract HelperContract{
    address constant IMPORTANT_ADRESS = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;
    BagMain bagmain;
    constructor(){
    }
}

contract BagmainTest is Test, HelperContract{
    address alice = makeAddr("Alice");
    address bob = makeAddr("Bob");
    address constant swaprouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    function setUp() public {
        bagmain = new BagMain( new VaultStruct.Token[](0),swaprouter);
    }

    function test_first() public {
        VaultStruct.Token[] memory tokens = bagmain.getTokens();
        uint256 tokensL = tokens.length;
        assertEq(tokensL,1);
    }
}