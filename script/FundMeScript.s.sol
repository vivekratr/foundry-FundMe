//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract FundMeDeploy is Script {

    function run() external returns(FundMe) {
        //before startBroadcast -> does not require gas as it is not executing while transaction
        HelperConfig helperConfig = new HelperConfig();
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();
        //after startBroadcast -> Real transaction starts
        vm.startBroadcast();
        //Mock
        FundMe fundMe =  new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }

}