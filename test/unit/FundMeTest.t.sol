//SPDX-License-Identifier: MIT

//forge snapshot :it gives the gas that will be required for their deployment and for running

pragma solidity ^0.8.18;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundMeDeploy} from "../../script/FundMeScript.s.sol";

contract FundMeTest is Test {
    // uint256 num = 1; //it will not get execute at first
    FundMe fundMe;
    uint256 constant sendVal = 0.1 ether;
    uint256 constant startingBalance = 10 ether;

    address  USER = makeAddr("user"); // it will generate new address
    function setUp() external {
        //it will get execute first then  other functions
        // num =2;


        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        FundMeDeploy deploy = new FundMeDeploy();
        fundMe = deploy.run();
        vm.deal(USER,startingBalance);
    }

    function testMinimumDollarIsFive() public {
        // console.log(num);
        // assertEq(num,2);
        assertEq(fundMe.MINIMUM_USD(), 5e18 );
    }

    function testOwner() public{
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        console.log(address(this));

        //supposed to fail, as the instance of Fundme contract have different owner here
        //us -> FundMeTest -> FundMe, us = msg.sender , FundMeTest -> address(this)
        assertEq(fundMe.getOwner(), msg.sender); 

        // assertEq(fundMe.i_owner(), address(this)); 
        
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version =fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // next line should revert
        fundMe.fund(); // sending 0 ETH and should revert/fail

    }

   function testFundUpdatesFundedDataStructure() public {
    vm.prank(USER); //the next transaction will be sent by USER
    
        fundMe.fund{value:sendVal}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, sendVal);
    }
    modifier funder(){
        vm.prank(USER);
        fundMe.fund{value:sendVal}();
        _;
    }
    
    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value:sendVal}();
        assertEq(USER, fundMe.getFunder(0));
    }

    function testOnlyOwnerCanWithdraw() public funder{
        

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funder{
        //Arrangge
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingContractBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 afterContractBalance = address(fundMe).balance ;
        uint256 afterOwnerBalance =fundMe.getOwner().balance;


        //Assert        
        assertEq(startingContractBalance, sendVal);
        assertEq(afterContractBalance, 0);
        assertEq(afterOwnerBalance,startingOwnerBalance+ sendVal);

    }

    function testWithdrawWithMultipleFunder() public {

        //Arrange
        uint160 numberOfFunders = 10; //we are initializing var with uint160 for address generating purpose
        uint160 startingFunderIndex = 1; //do not initialize it with 0 as it does not support and recommended
        for(uint160 i =startingFunderIndex;i<=numberOfFunders;i++){
            hoax(address(i),sendVal); //this does -> vm.prank(new address) + vm.deal(new address)
            //fund the fundMe
            fundMe.fund{value:sendVal}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingContractBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 afterContractBalance = address(fundMe).balance ;
        uint256 afterOwnerBalance =fundMe.getOwner().balance;

        //Assert
        assertEq(startingContractBalance, sendVal*10);
        assertEq(afterContractBalance, 0);
        assertEq(afterOwnerBalance,startingOwnerBalance+ sendVal*10);
    

    
}

 function testWithdrawWithMultipleFunderCheaper() public {

        //Arrange
        uint160 numberOfFunders = 10; //we are initializing var with uint160 for address generating purpose
        uint160 startingFunderIndex = 1; //do not initialize it with 0 as it does not support and recommended
        for(uint160 i =startingFunderIndex;i<=numberOfFunders;i++){
            hoax(address(i),sendVal); //this does -> vm.prank(new address) + vm.deal(new address)
            //fund the fundMe
            fundMe.fund{value:sendVal}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingContractBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        uint256 afterContractBalance = address(fundMe).balance ;
        uint256 afterOwnerBalance =fundMe.getOwner().balance;

        //Assert
        assertEq(startingContractBalance, sendVal*10);
        assertEq(afterContractBalance, 0);
        assertEq(afterOwnerBalance,startingOwnerBalance+ sendVal*10);
    }

    
}
//test is done through - forge test --match-test testPriceFeedVersionIsAccurate -vvv --fork-url $SAPOLIA_RPC
//in order to see how much of our code is actually tested we could use : forge coverage --fork-url $SAPOLIA_RPC