//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {RiceToken} from "../src/RiceToken.sol";

contract DeployMerkleAirdrop is Script {

    function run() public returns (MerkleAirdrop, RiceToken) {
        bytes32 merkleRoot = 0x691d3ba9b6910005ff0dda5ebf8779a29625193d941dba8488c731c7dd72a67d;

        vm.startBroadcast();

        RiceToken riceToken = new RiceToken();
        MerkleAirdrop merkleAirdrop = new MerkleAirdrop(riceToken, merkleRoot);
        //riceToken.transferOwnership(address(this));//for unit testing purposes
        //riceToken.mint(address(merkleAirdrop), 5 ether);//when deploying on local network for interaction

        vm.stopBroadcast();

        return (merkleAirdrop, riceToken);

    }
}