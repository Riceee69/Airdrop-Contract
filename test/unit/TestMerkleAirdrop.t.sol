//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {RiceToken} from "../../src/RiceToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployMerkleAirdrop} from "../../script/DeployMerkleAirdrop.s.sol";

contract TestMerkleAirdrop is Test {
    DeployMerkleAirdrop deployMerkleAirdrop;
    RiceToken riceToken;
    MerkleAirdrop merkleAirdrop;

    bytes32 constant MERKLE_ROOT = 0x691d3ba9b6910005ff0dda5ebf8779a29625193d941dba8488c731c7dd72a67d;
    bytes32[] private merkleProof = [bytes32(0xd8b413ffc6023e4aea407df01bac0abcfac6b349db16bb6b2d49e6fa9f834040), bytes32(0xf516ee26ae5c473c625d259707c10c04e3d727b52873d871b0434b0befde6dac)];
    uint256 private claimAmount = 1 ether;
    uint256 private amountToSend = 5 ether;
    address private eligibleUser;
    uint256 private eligibleUserPrivateKey;
    address private ineligibleUser;
    uint256 private ineligibleUserPrivateKey;
    address private gasPayer = makeAddr("gasPayer");
    uint8 v;
    bytes32 r;
    bytes32 s;

    event airdropTransfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        deployMerkleAirdrop = new DeployMerkleAirdrop();
        (merkleAirdrop, riceToken) = deployMerkleAirdrop.run();

        vm.prank(address(deployMerkleAirdrop));
        riceToken.mint(address(merkleAirdrop), amountToSend);
        //console.log("Tokens minted to merkleAirdrop", riceToken.balanceOf(address(merkleAirdrop)));
        (eligibleUser, eligibleUserPrivateKey) = makeAddrAndKey("eligibleUser");
        console.log(eligibleUser);//this address is then used to generate the merkle tree 
        bytes32 messageHash = merkleAirdrop.getMessageHash(eligibleUser, claimAmount);
        (v, r, s) = vm.sign(eligibleUserPrivateKey, messageHash);
        console.log(v);
        console.log(uint256(r));
        console.log(uint256(s));
    }


    /////////////////////////
    // Claim Function Tests
    /////////////////////////
    modifier claimedAirdrop {
        vm.prank(gasPayer);//prank gasPayer to test signature verification
        merkleAirdrop.claim(eligibleUser, claimAmount, merkleProof, v, r, s);
        _;
    }

    function testTransferEmittedAndAirdropped() public {
        vm.expectEmit(true, true, false, true);
        emit airdropTransfer(address(riceToken), eligibleUser, claimAmount);
        vm.prank(eligibleUser);
        merkleAirdrop.claim(eligibleUser, claimAmount, merkleProof, v, r, s);
        assertEq(riceToken.balanceOf(eligibleUser), claimAmount);
    }

    function testRevertIfAlreadyClaimed() public claimedAirdrop {
        vm.prank(eligibleUser);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__AlreadyClaimed.selector);
        merkleAirdrop.claim(eligibleUser, claimAmount, merkleProof, v, r, s);
    } 

    function testRevertIfInvalidMerkleProof() public {
        bytes32 proof1 = 0xbedfc32ba1f1fd8e2cda1ad3844ff65789da610c3ffdd4566ce304f0ef133fe3;
        bytes32 proof2 = 0xccbb6ada37e8f599b97c1d229c336c49f6344a9c6e4b4c40f8398e24dd2d8a3a;
        bytes32[] memory invalidMerkleProof = new bytes32[](2);
        invalidMerkleProof[0] = proof1;
        invalidMerkleProof[1] = proof2;
        vm.prank(eligibleUser);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__InvalidMerkleProof.selector);
        merkleAirdrop.claim(eligibleUser, claimAmount, invalidMerkleProof, v, r, s);
    }

    function testRevertIfInvalidSignature() public {
        (ineligibleUser, ineligibleUserPrivateKey) = makeAddrAndKey("ineligibleUser");
        bytes32 messageHash = merkleAirdrop.getMessageHash(ineligibleUser, claimAmount);
        (v, r, s) = vm.sign(ineligibleUserPrivateKey, messageHash);
        vm.prank(gasPayer);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__InvalidSignature.selector);
        merkleAirdrop.claim(eligibleUser, claimAmount, merkleProof, v, r, s);
    }

    //////////////////////////
    // Helper Function Tests
    //////////////////////////
    function testConstructorParameters() view public {
        assertEq(merkleAirdrop.getAirdropToken(), address(riceToken));
        assertEq(merkleAirdrop.getMerkleRoot(), MERKLE_ROOT);
    }
}