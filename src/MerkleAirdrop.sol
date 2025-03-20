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
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;
    // some list of addresses
    // allow someone in the list to claim the airdrop
    struct AirdropClaim {
        address account;
        uint256 amount;
    }
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__UserAlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();
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
    bytes32 private constant MESSAGE_TYPEHASH =
        keccak256("AirdropClaim(address account,uint256 amount)");
    mapping(address claimer => bool hasClaimed) private s_claimed;

    /*//////////////////////////////////////////////////////////////
                             CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(
        bytes32 merkleRoot,
        IERC20 airdropToken
    ) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    /*//////////////////////////////////////////////////////////////
                                 EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (s_claimed[account]) {
            revert MerkleAirdrop__UserAlreadyClaimed();
        }
        if (!_isValidSignature(account, getMessage(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
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
    //*//////////////////////////////////////////////////////////////
    //                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _isValidSignature(
        address account,
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (bool) {
        (address actualSigner, , ) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }
    /*//////////////////////////////////////////////////////////////
                                 GETTERS
    //////////////////////////////////////////////////////////////*/
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }
    function getMessage(
        address account,
        uint256 amount
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(abi.encode(MESSAGE_TYPEHASH, account, amount))
            );
    }
    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
