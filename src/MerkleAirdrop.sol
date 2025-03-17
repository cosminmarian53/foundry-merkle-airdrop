// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;
    // some list of addresses
    // allow someone in the list to claim the airdrop

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__UserAlreadyClaimed();

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event Claim(address indexed account, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                             STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool hasClaimed) private s_claimed;

    /*//////////////////////////////////////////////////////////////
                             CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    /*//////////////////////////////////////////////////////////////
                                 EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        if (s_claimed[account]) {
            revert MerkleAirdrop__UserAlreadyClaimed();
        }
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encodePacked(account, amount)))
        );
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_claimed[account] = true;
        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    /*//////////////////////////////////////////////////////////////
                                 GETTERS
    //////////////////////////////////////////////////////////////*/
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }
    
    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
