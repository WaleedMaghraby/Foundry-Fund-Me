
// SPDX-License-Identifier: MIT
// 1. Deploy mock when we are on a local anvil chain
// 2. keep track of contract address across different chains
// Sepolia Eth/USD
// Mainnet Eth/USD

pragma solidity ^0.8.19;

import {MockV3Aggregator} from "./../test/Mock/MockV3Aggregator.sol";
import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    event HelperConfig__CreatedMockPriceFeed(address priceFeed);

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMinnetEthConfig();
        }
       else (
            activeNetworkConfig = getOrCreateAnvilEthConfig()
        );
    }
    

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory sepoliaNetworkConfig) {
        sepoliaNetworkConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // ETH / USD
        });
    }

    function getMinnetEthConfig() public pure returns (NetworkConfig memory ethConfig) {
      
        ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 // ETH / USD
        });
    } 

     function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory anvilNetworkConfig) {
      if (activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS,INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig ({
            priceFeed: address(mockPriceFeed)
            }); 
        return anvilConfig;
       // emit HelperConfig__CreatedMockPriceFeed(address(mockPriceFeed));

        //anvilNetworkConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
    }
}

  