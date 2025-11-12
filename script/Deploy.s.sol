// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {FPToken} from "src/FPToken.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Deployment is Script {
    bytes32 private s_mRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private s_airdropAmountToTransfer = 25 ether * 4;

    function deploy() public returns (FPToken, MerkleAirdrop) {
        vm.startBroadcast();
        FPToken fpToken = new FPToken();
        MerkleAirdrop mAirdrop = new MerkleAirdrop(s_mRoot, IERC20(address(fpToken)));

        fpToken.mint(fpToken.owner(), s_airdropAmountToTransfer);
        fpToken.transfer(address(mAirdrop), s_airdropAmountToTransfer);

        vm.stopBroadcast();
        return (fpToken, mAirdrop);
    }

    function run() external returns (FPToken, MerkleAirdrop) {
        return deploy();
    }
}
