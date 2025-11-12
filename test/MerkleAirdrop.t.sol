// SPDX-License-Identifer: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {FPToken} from "src/FPToken.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {Deployment} from "script/Deploy.s.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    FPToken public fpToken;
    MerkleAirdrop public mAirdrop;

    // console.log("Parent of CD - ", parentHash);

    bytes32 public mRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4; // use your own
    uint256 public constant CLAIM_AMOUNT = 25e18;
    uint256 public constant MA_CONTRACT_AMOUNT = CLAIM_AMOUNT * 4;
    bytes32 proof1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a; // use your own
    bytes32 proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public mProof = [proof1, proof2];

    address user;
    address gasFeePayerForUser;
    uint256 userPrivateKey;

    function setUp() public {
        if (!isZkSyncChain()) {
            Deployment deployer = new Deployment();
            (fpToken, mAirdrop) = deployer.run();
        } else {
            fpToken = new FPToken();
            mAirdrop = new MerkleAirdrop(mRoot, fpToken);
            fpToken.mint(fpToken.owner(), MA_CONTRACT_AMOUNT);
            fpToken.transfer(address(mAirdrop), MA_CONTRACT_AMOUNT);
        }
        (user, userPrivateKey) = makeAddrAndKey("user");
        // console.log("user Address -> ", user); //Comment out After getting and address and adding it to the GenerateInput script.Can keep it too but decided to comment it out!
        gasFeePayerForUser = makeAddr("gasFeePayerForUser");
    }

    function testUsersCanClaim() public {
        uint256 balanceBeforeClaim = fpToken.balanceOf(user);
        console.log("User balance before Claim is %d tokens", balanceBeforeClaim);
        bytes32 digest = mAirdrop.getMessageHash(user, CLAIM_AMOUNT);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);
        vm.prank(user);
        mAirdrop.claim(user, CLAIM_AMOUNT, mProof, v, r, s);

        uint256 balanceAfterClaim = fpToken.balanceOf(user);
        console.log("User balance after Claiming is %d tokens", balanceAfterClaim);

        assertEq(balanceBeforeClaim, 0);
        assertEq(balanceAfterClaim, CLAIM_AMOUNT);
    }

    function testUserCanSignForGasPyerToClaimForUser() public {
        bytes32 digest = mAirdrop.getMessageHash(user, CLAIM_AMOUNT);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);

        vm.prank(gasFeePayerForUser);
        uint256 userBalanceBefore = fpToken.balanceOf(user);
        mAirdrop.claim(user, CLAIM_AMOUNT, mProof, v, r, s);
        uint256 userBalanceNow = fpToken.balanceOf(user);

        assertEq(userBalanceBefore, 0);
        assertEq(userBalanceNow, CLAIM_AMOUNT);
    }
}
