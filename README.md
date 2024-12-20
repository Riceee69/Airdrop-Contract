# Merkle-Based Airdrop

## Overview

This project implements a Merkle-based airdrop mechanism with features for whitelist management, efficient proof generation, and secure claim processing using cryptographic standards.

---

## Features

### 1. **Custom Input JSON Generator Script (GenerateInput.s.sol)**
- A custom-made tool to generate the input format required for the Merkle airdrop.
- Takes a list of wallet addresses in the whitelist and formats it into a compatible JSON structure.

### 2. **Merkle Tree and Proofs Generation**
- Utilizes the [dmfxyz/murky](https://github.com/dmfxyz/murky) library to:
  - Generate the Merkle tree using **MakeMerkle.s.sol**
  - Compute Merkle proofs for whitelisted addresses efficiently.

### 3. **EIP-712 Standard for Signatures**
- Implements the EIP-712 standard to create structured and secure signatures for claim verification.

---

## Smart Contract Interaction

### **Interact.s.sol**
- Contains the script to interact with the deployed Merkle airdrop contract.
- Uses `cast` to sign messages after deploying the contract locally using Anvil.
- The signature is split into `v`, `r`, and `s` components using inline assembly for claim validation.

---

## Steps to Interact(Personal Notes)

1. **Start Local Blockchain**
   ```bash
   anvil
   ```

2. **Deploy the Contract**
   ```bash
   forge script [deploy_script] --rpc-url localhost --private-key [key] --broadcast
   ```
   *(Use `--broadcast` to deploy, or omit it to run a simulation.)*

3. **Generate Message Hash**
   ```bash
   cast call [Address(MerkleAirdrop)] ["getMessageHash(address, uint256)"] [parameters]
   ```

4. **Sign the Message**
   ```bash
   cast wallet sign --no-hash [message_hash] --private-key
   ```
   *(Ensure the hash is provided without the `0x` prefix.)*

5. **Run Interaction Script**
   ```bash
   forge script [Interact_Script]
   ```

---

## Disclaimer

This implementation is a proof-of-concept. Please review the code thoroughly and adapt it as necessary for production environments.

---
