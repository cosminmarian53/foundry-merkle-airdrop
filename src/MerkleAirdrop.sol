// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract MerkleAirdrop{
    // some list of addresses
    // allow someone in the list to claim the airdrop
    constructor(bytes32 merkleRoot,IERC20 airdropToken){
    }
}