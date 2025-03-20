// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {
    address public constant CLAIMING_ADDRESS =
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 public constant CLAIMING_AMOUNT = 25 * 10 ** 18;
    bytes32 proofOne=0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 proofTwo=0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public constant CLAIMING_PROOF = [proofOne, proofTwo];
    function claimAirdrop(address _merkleAirdrop) public {
        vm.startBroadcast();
        MerkleAirdrop merkleAirdrop = MerkleAirdrop(_merkleAirdrop);
        merkleAirdrop.claim(
            CLAIMING_ADDRESS,
            CLAIMING_AMOUNT,
            CLAIMING_PROOF,
            v,
            r,
            s
        );
        vm.stopBroadcast();
    }
    function run() external {
        address mostRecentDeployedContract = DevOpsTools
            .get_most_recent_deployed_contract("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentDeployedContract);
    }
}
