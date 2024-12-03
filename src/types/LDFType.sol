// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

enum LDFType {
    STATIC, // LDF does not change ever
    DYNAMIC_NOT_STATEFUL, // LDF can change, does not use ldfState
    DYNAMIC_AND_STATEFUL // LDF can change, uses ldfState

}
