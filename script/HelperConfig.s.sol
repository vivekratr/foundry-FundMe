//SPDX-License-Identifier: MIT

//1. Deploy mocks when we are on a local anvil chain. 
//2. Keep track of contract address across different chains. 
// Sapolia ETH/USD 
// Mainnet ETH/USD 

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    // If we are on a local anvil, we deploy mock contracts.
    //Otherwise , grab the existing address from the live network.
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig{
        address priceFeed;
    }

    constructor(){
        if(block.chainid ==11155111){
            activeNetworkConfig= getSapoliaEthConfig();
        }
        else{
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSapoliaEthConfig() public pure returns (NetworkConfig memory){
        //price feed address
        NetworkConfig memory sapoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sapoliaConfig;
    }
    function getOrCreateAnvilEthConfig() public  returns (NetworkConfig memory){
        if(activeNetworkConfig.priceFeed != address(0)){  // here we are checking whether we have already created the anvil configuration or not by equating it to adress(0)
            return activeNetworkConfig; 
        }
        //price feed address
        
        // 1. Deploy the mocks
        // 2. Return the mock address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS,INITIAL_PRICE);


        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed:address(mockPriceFeed)});
        return anvilConfig;
    }
}
