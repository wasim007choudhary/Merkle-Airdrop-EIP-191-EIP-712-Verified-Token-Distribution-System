// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";

contract ClaimScript is ZkSyncChainChecker, Script {
    error ClaimScript____signatureSplitting__Invalid_Signature_Length_To_Get_v_r_s();

    address public constant CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // use your own
    uint256 public constant CLAIM_AMOUNT = 25 ether;
    bytes32 mProof1 = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad; // use your own
    bytes32 mProof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576; // use your own
    bytes32[] mProof = [mProof1, mProof2];
    bytes private SIGNATURE =
        hex"b7f0cb19e8529a36e12cfc9308d0fa832129c93ae16381b542daed67142f441b78a087a18b0e4d950ec23cdcaaa3663bca3a966d1975548604f050e88aa761e51b"; // use your own

    function run() external {
        address merkleAirdrop;
        if (!isZkSyncChain()) {
            merkleAirdrop = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        } else {
            //  Hardcode the latest known zkSync local deployment
            merkleAirdrop = 0x094499Df5ee555fFc33aF07862e43c90E6FEe501;
            console.log("Running on zkSync chain. Using manual address:", merkleAirdrop);
        }
        airdropClaim(merkleAirdrop);
    }

    function airdropClaim(address contractAddress) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = signatureSplitting(SIGNATURE);
        MerkleAirdrop(contractAddress).claim(CLAIMING_ADDRESS, CLAIM_AMOUNT, mProof, v, r, s);
        vm.stopBroadcast();
    }

    function signatureSplitting(bytes memory sig) public returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert ClaimScript____signatureSplitting__Invalid_Signature_Length_To_Get_v_r_s();
        }

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
