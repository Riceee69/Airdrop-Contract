//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712{
    ///////////////////////
    // Errors
    ///////////////////////   
    error MerkleAirdrop__InvalidMerkleProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    ///////////////////////
    // Types
    ///////////////////////
    using SafeERC20 for IERC20;

    ///////////////////////
    // State Variables
    ///////////////////////
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping (address claimer => bool claimed) public hasClaimed;

    struct ClaimAirdrop {
        address user;
        uint256 amount;
    }

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("ClaimAirdrop(address user,uint256 amount)");
    ///////////////////////
    // Events
    ///////////////////////
    event airdropTransfer(address indexed from, address indexed to, uint256 value);

    ///////////////////////
    // Functions
    ///////////////////////
    constructor(IERC20 airdropToken, bytes32 merkleRoot) EIP712('MerkleAirdrop', '1') {
        i_airdropToken = airdropToken;
        i_merkleRoot = merkleRoot; 
    }

    /////////////////////////////
    // Public/External Functions
    /////////////////////////////
    /**
     * @dev claim airdrop
     * @param recepient address of the airdrop recipient
     * @param amount amount of tokens to transfer
     * @param merkleProof proof that the recipient is in the merkle tree
     * @notice follows CEI, allows others to claim for the airdropped addresses using signature verification
     */
    function claim(address recepient, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s) public {
        if(hasClaimed[recepient]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        //check signature
        if(!_isValidSignatue(recepient, _getMessageHash(recepient, amount), v, r, s)){
            revert MerkleAirdrop__InvalidSignature();
        }

        //check recepient is in merkle tree
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(recepient, amount))));
        if(!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidMerkleProof();
        }

        //transfer tokens
        hasClaimed[recepient] = true;
        emit airdropTransfer(address(i_airdropToken), recepient, amount);
        //the tokens will be airdropped from this contract
        i_airdropToken.safeTransfer(recepient, amount);
    }

    ///////////////////////
    // Private Functions
    ///////////////////////    
    function _isValidSignatue(address recepient, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) private pure returns (bool) {
        (address signer,, ) = ECDSA.tryRecover(messageHash, v, r, s);
        if(signer != recepient) {
            return false;
        }
        return true;
    }

    //message digest getting signed
    function _getMessageHash(address recepient, uint256 amount) private view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, ClaimAirdrop({user: recepient, amount: amount}))));
    }
    
    ///////////////////////
    // Getter Functions
    ///////////////////////    
    function getAirdropToken() public view returns (address) {
        return address(i_airdropToken);
    }

    function getMerkleRoot() public view returns (bytes32) {
        return i_merkleRoot;
    }

    function getMessageHash(address recepient, uint256 amount) public view returns (bytes32) {
        return _getMessageHash(recepient, amount);
    }
}