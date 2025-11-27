
<div align="center">

# 🪂 Merkle Airdrop — EIP-191 & EIP-712 Verified Token Distribution System

**A secure, Meta-Transaction-Ready ERC-20 Airdrop Protocol powered by Merkle Proofs and EIP-712 Signatures for Verified Token Distribution — with zkSync-compatible Foundry scripts.**  
Built with **Foundry**, verified with **OpenZeppelin**, and designed for **relayer-based claiming** across EVM and **zkSync** networks.

[![Solidity](https://img.shields.io/badge/Solidity-^0.8.20-blue.svg?logo=ethereum)](https://soliditylang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Powered by Foundry](https://img.shields.io/badge/Powered%20By-Foundry-orange.svg)](https://book.getfoundry.sh/)
[![EIP-712](https://img.shields.io/badge/EIP--712-Structured%20Data%20Signing-green.svg)](https://eips.ethereum.org/EIPS/eip-712)
[![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-SafeERC20-blue.svg)](https://openzeppelin.com/contracts/)
[![zkSync Compatible](https://img.shields.io/badge/Compatible%20With-zkSync-purple.svg?logo=zkSync)](https://zksync.io)

[![X (Twitter)](https://img.shields.io/badge/X-@i___wasim-black?logo=x)](https://x.com/i___wasim)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Wasim%20Choudhary-blue?logo=linkedin)](https://www.linkedin.com/in/wasim-007-choudhary/)

</div>

---

A fully on-chain **Merkle Airdrop System** that enables eligible users to claim ERC-20 tokens using **Merkle proofs** and **EIP-712 typed-data signatures**, combining **on-chain verification** with **off-chain authorization**.

Built with **Foundry**, this project demonstrates how to create a **secure, efficient, and relayer-compatible** airdrop system — where users can claim tokens without directly paying gas, thanks to signature verification and off-chain authorization.

---

## ⚙️ Overview

This project provides:

- ✅ **Merkle Tree Verification** — Ensures only whitelisted addresses can claim.  
- ✅ **EIP-712 Signature Verification** — Confirms that claims are approved off-chain by the rightful account holder.  
- ✅ **Relayer-Compatible Claims** — Anyone can pay gas on behalf of the claimer.  
- ✅ **Double-Claim Protection** — Prevents multiple claims from the same address.  
- ✅ **Complete Foundry Automation** — Includes scripts for Merkle generation, deployment, and claim execution.

---

## 📁 Project Structure

```text
Merkle-AirDrop/
 ┣ 📂 script/
 ┃ ┣ 📜 Deploy.s.sol           -> Deploys FPToken + MerkleAirdrop
 ┃ ┣ 📜 GenerateInput.s.sol    -> Generates whitelist input.json
 ┃ ┣ 📜 MakeMerkle.s.sol       -> Builds Merkle tree and outputs proofs + root
 ┃ ┣ 📂 Interaction/
 ┃ ┃ ┗ 📜 ClaimingScript.s.sol -> Demonstrates token claim using proof + signature
 ┃ ┗ 📂 target/
 ┃    ┣ 📜 input.json          -> Generated whitelist addresses + claim amounts
 ┃    ┗ 📜 output.json         -> Generated proofs and Merkle root
 ┣ 📂 src/
 ┃ ┣ 📜 MerkleAirdrop.sol      -> Core airdrop contract with EIP-712 + Merkle logic
 ┃ ┗ 📜 FPToken.sol            -> ERC-20 token used for distribution
 ┣ 📂 test/
 ┃ ┗ 📜 MerkleAirdrop.t.sol
 ┗ 📜 foundry.toml
```


---



## 🧠 How It Works
### 1️⃣ Off-chain Merkle Tree Generation

GenerateInput.s.sol  
Creates /script/target/input.json, listing all eligible addresses with their claimable token amounts.

MakeMerkle.s.sol  
Builds the Merkle tree using Murky.  
Outputs /script/target/output.json with:  
- Merkle root  
- Each user’s Merkle proof  
- Each leaf (address + amount)

The Merkle root is stored on-chain in the MerkleAirdrop contract during deployment.  
Only the Merkle root is on-chain — it cryptographically represents the entire dataset of eligible claimers.

---

### 2️⃣ On-chain Claim Flow

The user signs an EIP-712 typed message off-chain:

ClaimAirdrop(accountAddress, claimAmount)

MetaMask shows a “Sign Message” popup — no gas is used here.  

Anyone (claimer or relayer) then calls the on-chain function:

claim(accountAddress, amount, merkleProof, v, r, s)

The contract:  
✅ Verifies the EIP-712 signature → confirms it’s authorized by the claimer.  
✅ Verifies the Merkle proof → confirms eligibility.  
✅ Transfers tokens to accountAddress.  

Once the claim is processed, the user’s address is permanently marked as claimed, preventing replay or double-claims.

---

### 3️⃣ Gasless / Relayer Support

Your claim() function does not depend on msg.sender.  
That means:  
- Any address can pay gas (relayer, sponsor, friend).  
- Tokens will always go to the intended claimer’s address.  
- Valid EIP-712 signatures are required — ensuring security and authenticity.  

This design makes the system compatible with future meta-transaction standards such as EIP-2771 or Biconomy relayers.

---

## 🧩 Deployment

Set your own Merkle root in Deploy.s.sol:  

bytes32 private s_mRoot = 0x<YOUR_MERKLE_ROOT>;

Deploy using Foundry:  

forge script script/Deploy.s.sol --rpc-url <RPC_URL> --broadcast --private-key <PRIVATE_KEY>

This script:  
- Deploys FPToken (ERC-20 for airdrop)  
- Deploys MerkleAirdrop with your Merkle root  
- Mints and transfers the total airdrop supply to the contract

---

## 🧾 Claiming Example

Update ClaimingScript.s.sol with your proof and signature from /script/target/output.json:  

bytes32[] mProof = [bytes32(0x...), bytes32(0x...)];  
bytes private SIGNATURE = hex"...";

Then execute:  

forge script script/Interaction/ClaimingScript.s.sol --rpc-url <RPC_URL> --broadcast --private-key <PRIVATE_KEY>

This script:  
- Extracts (v, r, s) from the signature  
- Calls the contract’s claim() function  
- Transfers tokens to the rightful claimer


---

## 🧰 Customization Notes

| Parameter | File | Description |
|------------|------|-------------|
| Merkle Root | Deploy.s.sol | Root of your generated Merkle tree |
| Whitelist Addresses | GenerateInput.s.sol | Addresses eligible for claiming |
| Claim Signature | ClaimingScript.s.sol | Off-chain EIP-712 signature |
| Proof Array | ClaimingScript.s.sol | Proof data from output.json |

Each deployment should use its own Merkle root, proof, and signature data matching the intended whitelist.

---

## 🧠 Deep Dive: Merkle + EIP-712 Interaction

| Layer | Mechanism | Purpose |
|--------|------------|----------|
| Merkle Proof | MerkleProof.verify() | Proves (address, amount) exists in the original dataset |
| EIP-712 Signature | ECDSA.tryRecover() | Confirms the claimer authorized the transaction |
| Claim Tracking | s_hasClaimed[address] | Prevents double claims |
| Safe Transfer | SafeERC20.safeTransfer() | Secure ERC-20 token delivery |

Together, they form a two-step cryptographic verification system:  
✅ Eligibility proven by Merkle root  
✅ Authorization proven by EIP-712 signature

---

## 📘 Learnings

- The Merkle root compresses the full whitelist into a single on-chain hash.  
- Signatures (v, r, s) serve as cryptographic authorization — no wallet gas required.  
- Relayer support enables fully gasless claiming experiences.  
- This system blends security, efficiency, and user-friendliness, ideal for token launches or reward programs.

---

## 🧾⚙️ Notice 
- Removed the target folder for security reasons. One can create and in GenerateInput.s.sol use the address
you would like to keep for the airdrop and then use the MakeMerkle.s.sol to generate the root and pass the root in the Deploy.s.sol as constructor arg for the MerkleAirdrop contract. Best of luck!

# 🧾 License

This project is licensed under the MIT License.  
By Wasim Choudhary 🧠
