// SPDX-LICENSE-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {DeployRaffle} from "./DeployRaffle.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "@foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function CreateSubscriptionUsingConfig() public returns (uint64) {
        HelperConfig helperconfig = new HelperConfig();
        (, , address vrfCoord, , , , , uint256 deployerKey) = helperconfig
            .activeNetworkConfig();
        return CreateSubscriptionn(vrfCoord, deployerKey);
    }

    function CreateSubscriptionn(
        address vrfCoord,
        uint256 deployerKey
    ) public returns (uint64) {
        console.log("Creating subscription on chainID: ", block.chainid);
        vm.startBroadcast(deployerKey);
        uint64 subId = VRFCoordinatorV2Mock(vrfCoord).createSubscription();
        vm.stopBroadcast();
        console.log("Your subscription ID is: ", subId);
        return subId;
    }

    function run() external returns (uint64) {
        return CreateSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function FundSubscriptionUsingConfig() public {
        HelperConfig helperconfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoord,
            ,
            uint64 subId,
            ,
            address link,
            uint256 deployerKey
        ) = helperconfig.activeNetworkConfig();
        fundSubscription(vrfCoord, subId, link, deployerKey);
    }

    function fundSubscription(
        address vrfCoord,
        uint64 subId,
        address link,
        uint256 deployerKey
    ) public {
        console.log("Funding subscription on chainID: ", subId);
        console.log("Using vrfCoord: ", vrfCoord);
        console.log("ON chainID: ", block.chainid);
        if (block.chainid == 31337) {
            vm.startBroadcast();
            VRFCoordinatorV2Mock(vrfCoord).fundSubscription(subId, FUND_AMOUNT);
            vm.stopBroadcast();
        } else {
            vm.startBroadcast(deployerKey);
            LinkToken(link).transferAndCall(
                vrfCoord,
                FUND_AMOUNT,
                abi.encode(subId)
            );
            vm.stopBroadcast();
        }
    }

    function run() external {
        FundSubscriptionUsingConfig();
    }
}

contract Addconsumer is Script {
    function addConsumer(
        address raffle,
        address vrfCoord,
        uint64 subId,
        uint256 deployerKey
    ) public {
        console.log("Adding consumer on contract: ", raffle);
        console.log("Using vrfCoord: ", vrfCoord);
        console.log("ON chainID: ", block.chainid);
        vm.startBroadcast(deployerKey);
        VRFCoordinatorV2Mock(vrfCoord).addConsumer(subId, raffle);
        vm.stopBroadcast();
    }

    function AddconsumerUsingCOnfig(address raffle) public {
        HelperConfig helperconfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoord,
            ,
            uint64 subId,
            ,
            ,
            uint256 deployerKey
        ) = helperconfig.activeNetworkConfig();
        addConsumer(raffle, vrfCoord, subId, deployerKey);
    }

    function run() external {
        address raffle = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        AddconsumerUsingCOnfig(raffle);
    }
}
