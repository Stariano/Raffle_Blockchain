// SPDX-LICENSE-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, Addconsumer} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig) {
        HelperConfig helperconfig = new HelperConfig();
        (
            uint256 entranceFee,
            uint256 interval,
            address vrfCoord,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit,
            address link,
            uint256 deployerKey
        ) = helperconfig.activeNetworkConfig();

        if (subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.CreateSubscriptionn(
                vrfCoord,
                deployerKey
            );

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                vrfCoord,
                subscriptionId,
                link,
                deployerKey
            );
        }
        vm.startBroadcast();
        Raffle raffle = new Raffle(
            entranceFee,
            interval,
            vrfCoord,
            gasLane,
            subscriptionId,
            callbackGasLimit
        );
        vm.stopBroadcast();

        Addconsumer addConsumer = new Addconsumer();
        addConsumer.addConsumer(
            address(raffle),
            vrfCoord,
            subscriptionId,
            deployerKey
        );
        return (raffle, helperconfig);
    }
}
