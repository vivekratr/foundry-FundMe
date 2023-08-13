//SPDX-License-Identifier: MIT

//forge snapshot :it gives the gas that will be required for their deployment and for running

pragma solidity ^0.8.18;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundMeDeploy} from "../../script/FundMeScript.s.sol";
import {FundFundMe,WithdrawFundMe} from "../../script/Interaction.s.sol";

contract FundMeTestIntegration is Test {
      // uint256 num = 1; //it will not get execute at first
    FundMe fundMe;
    uint256 constant sendVal = 0.1 ether;
    uint256 constant startingBalance = 10 ether;

    address  USER = makeAddr("user");
    function setUp() external {
        FundMeDeploy deploy =new FundMeDeploy();
        fundMe = deploy.run();
        vm.deal(USER,startingBalance);
    }

    function testUserCanFundInteraction() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        
        assert(address(fundMe).balance ==0);
    }
}