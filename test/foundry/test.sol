// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import 'forge-std/Test.sol';
import {BagMain} from'../../contracts/BagMain.sol';
import {Bag} from '../../contracts/Bag.sol';
import {IBag} from'../../contracts/libraries/IBag.sol';
import '../../contracts/libraries/BagStruct.sol';
import {IWETH} from'../../contracts/libraries/IWETH.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';


contract HelperContract{
    address constant IMPORTANT_ADRESS = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;
    BagMain bagmain;
    constructor(){
    }
}

contract BagmainTest is Test, HelperContract{
    address  wethAddr = 0x4200000000000000000000000000000000000006;
    address alice = makeAddr("Alice");
    address bob = makeAddr("Bob");
    address constant swaprouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    function setUp() public {
        bagmain = new BagMain(new BagStruct.Token[](0),swaprouter, wethAddr);
        //vm.prank(bob);
        vm.deal(bob, 100);
        IWETH(wethAddr).deposit(10);

    }

    function test_first() public view {
        BagStruct.Token[] memory tokens = bagmain.getTokens();
        uint256 tokensL = tokens.length;
        assertEq(tokensL,0);
    }

    function test_createabagWithAccount1() public {
        vm.prank(bob);
        address payable bagAddr = payable(bagmain.createBag("test bag", 10));  
        console.log("bag address : " ,bagAddr);
        Bag  bag = Bag(bagAddr);
        bag.deposit(10);
/*
        BagStruct.Token[] memory tokens = bag.getTokens();
        uint256 tokensL = tokens.length;
        assertEq(tokensL,0);
        address owner = bag.getOwner();
        assertEq(owner,bob);

        vm.prank(bob);
        bag.deposit(100);*/

    }
}