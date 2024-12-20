//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {
    error ClaimAirdropScript__InvalidSignatureLength();

    address user = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 amount = 1 ether;
    bytes32[] merkleProof = [
        bytes32(0xa0c6639590a64c5824dbf4e9f94a6ec10a9178f7d9114955e239190a4b432fa4),
        bytes32(0xf516ee26ae5c473c625d259707c10c04e3d727b52873d871b0434b0befde6dac)
    ];
    uint8 v;
    bytes32 r;
    bytes32 s;
    string private readSignature = vm.readFile(string.concat(vm.projectRoot(), "/script/results/signature.txt"));
    bytes private signature = vm.parseBytes(readSignature);

    function run() external {
        //To interact with the MerkleAirdrop contract
        console.log(readSignature);
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        MerkleAirdrop merkleAirdrop = MerkleAirdrop(mostRecentDeployment);

        vm.startBroadcast();
        //need to get the user signature 
        (v, r, s) = splitSignature(signature);

        merkleAirdrop.claim(user, amount, merkleProof, v, r, s);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory signature) public pure returns (uint8 v, bytes32 r, bytes32 s) {
           if(signature.length != 65) {
               revert ClaimAirdropScript__InvalidSignatureLength();
           }

           assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
           }
    }
}