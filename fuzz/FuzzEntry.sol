pragma solidity ^0.8.20;

import "./FuzzSwap.sol";
import {FuzzLDF} from "./FuzzLDF.sol";

contract FuzzEntry is FuzzSwap, FuzzLDF {}
