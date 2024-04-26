// SPDX-LICENSE-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoord;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
        address link;
        uint256 deployerKey;
    }

    uint256 public constant DEAFULT_ANVIL_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 111551111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                vrfCoord: 0x271682DEB8C4E0901D1a1550aD2e64D568E69909,
                gasLane: 0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef,
                subscriptionId: 1893,
                callbackGasLimit: 500000,
                link: 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0,
                deployerKey: vm.envUint("PRIVATE_KEY")
            });
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.vrfCoord != address(0)) {
            return activeNetworkConfig;
        }

        uint96 baseFee = 0.25 ether;
        uint96 gasPriceLink = 1e9;

        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinatorMock = new VRFCoordinatorV2Mock(
            baseFee,
            gasPriceLink
        );
        LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();

        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                vrfCoord: address(vrfCoordinatorMock),
                gasLane: 0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef,
                subscriptionId: 0,
                callbackGasLimit: 500000,
                link: address(linkToken),
                deployerKey: DEAFULT_ANVIL_KEY
            });
    }
}
