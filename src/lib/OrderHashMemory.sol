// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {IFloodPlain} from "flood-contracts/src/interfaces/IFloodPlain.sol";
import {ISignatureTransfer, PermitHash} from "permit2/src/libraries/PermitHash.sol";

library OrderHashMemory {
    string internal constant _HOOK_STRING = "Hook(address target,bytes data)";
    string internal constant _ITEM_STRING = "Item(address token,uint256 amount)";
    string internal constant _ORDER_STRING =
        "Order(address offerer,address zone,address recipient,Item[] offer,Item consideration,uint256 deadline,uint256 nonce,Hook[] preHooks,Hook[] postHooks)";
    string internal constant _PERMIT_STRING =
        "PermitBatchWitnessTransferFrom(TokenPermissions[] permitted,address spender,uint256 nonce,uint256 deadline,Order witness)";
    string internal constant _TOKEN_PERMISSIONS_STRING = "TokenPermissions(address token,uint256 amount)";

    string internal constant _PERMIT_STRING_VARIABLE_END = "Order witness)";

    bytes32 public constant _ITEM_TYPEHASH = keccak256(bytes(_ITEM_STRING));
    bytes32 public constant _HOOK_TYPEHASH = keccak256(bytes(_HOOK_STRING));
    bytes32 public constant _ORDER_TYPEHASH = keccak256(abi.encodePacked(_ORDER_STRING, _HOOK_STRING, _ITEM_STRING));
    bytes32 public constant _PERMIT_TYPEHASH = keccak256(
        abi.encodePacked(_PERMIT_STRING, _HOOK_STRING, _ITEM_STRING, _ORDER_STRING, _TOKEN_PERMISSIONS_STRING)
    );
    string public constant _WITNESS_TYPESTRING = string(
        abi.encodePacked(
            _PERMIT_STRING_VARIABLE_END, _HOOK_STRING, _ITEM_STRING, _ORDER_STRING, _TOKEN_PERMISSIONS_STRING
        )
    );

    function hash(IFloodPlain.Hook memory hook) internal pure returns (bytes32) {
        return keccak256(abi.encode(_HOOK_TYPEHASH, hook.target, keccak256(hook.data)));
    }

    function hash(IFloodPlain.Item memory item) internal pure returns (bytes32) {
        return keccak256(abi.encode(_ITEM_TYPEHASH, item.token, item.amount));
    }

    function hash(IFloodPlain.Order memory order) internal pure returns (bytes32) {
        // Hash offer array.
        uint256 length = order.offer.length;
        bytes32[] memory offerHashes = new bytes32[](length);
        for (uint256 i; i < length; ++i) {
            offerHashes[i] = hash(order.offer[i]);
        }

        // Hash preHooks array.
        length = order.preHooks.length;
        bytes32[] memory preHooksHashes = new bytes32[](length);
        for (uint256 i; i < length; ++i) {
            preHooksHashes[i] = hash(order.preHooks[i]);
        }

        // Hash postHooks array.
        length = order.postHooks.length;
        bytes32[] memory postHooksHashes = new bytes32[](length);
        for (uint256 i; i < length; ++i) {
            postHooksHashes[i] = hash(order.postHooks[i]);
        }

        // Derive and return the order hash as specified by EIP-712.
        return keccak256(
            abi.encode(
                _ORDER_TYPEHASH,
                order.offerer,
                order.zone,
                order.recipient,
                keccak256(abi.encodePacked(offerHashes)),
                hash(order.consideration),
                order.deadline,
                order.nonce,
                keccak256(abi.encodePacked(preHooksHashes)),
                keccak256(abi.encodePacked(postHooksHashes))
            )
        );
    }

    function hashAsWitness(IFloodPlain.Order memory order, address spender) internal pure returns (bytes32) {
        IFloodPlain.Item[] memory offer = order.offer;
        bytes32[] memory tokenPermissionHashes = new bytes32[](offer.length);
        bytes32[] memory offerHashes = new bytes32[](offer.length);
        for (uint256 i; i < offer.length; ++i) {
            IFloodPlain.Item memory item = offer[i];

            offerHashes[i] = hash(item);

            tokenPermissionHashes[i] = keccak256(
                abi.encode(
                    PermitHash._TOKEN_PERMISSIONS_TYPEHASH, ISignatureTransfer.TokenPermissions(item.token, item.amount)
                )
            );
        }

        return keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                keccak256(abi.encodePacked(tokenPermissionHashes)),
                spender,
                order.nonce,
                order.deadline,
                hash(order)
            )
        );
    }
}
