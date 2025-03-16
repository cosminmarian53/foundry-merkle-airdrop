// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
contract MerkleAirdrop {
    using SafeERC20 for IERC20;
    // some list of addresses
    // allow someone in the list to claim the airdrop

    error MerkleAirdrop__InvalidProof();

    event Claim(address indexed account, uint256 amount);
    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encodePacked(account, amount)))
        );
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }
}
