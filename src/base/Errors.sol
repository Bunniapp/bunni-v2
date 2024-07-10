// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;
pragma abicoder v2;

error BunniHub__ZeroInput();
error BunniHub__PastDeadline();
error BunniHub__Unauthorized();
error BunniHub__InvalidReferrer();
error BunniHub__LDFCannotBeZero();
error BunniHub__MaxNonceReached();
error BunniHub__SlippageTooHigh();
error BunniHub__HookCannotBeZero();
error BunniHub__ZeroSharesMinted();
error BunniHub__InvalidLDFParams();
error BunniHub__InvalidHookParams();
error BunniHub__VaultFeeIncorrect();
error BunniHub__VaultAssetMismatch();
error BunniHub__GracePeriodExpired();
error BunniHub__MsgValueInsufficient();
error BunniHub__QueuedWithdrawalNotReady();
error BunniHub__BunniTokenNotInitialized();
error BunniHub__NeedToUseQueuedWithdrawal();
error BunniHub__InvalidRawTokenRatioBounds();
error BunniHub__QueuedWithdrawalNonexistent();

error BunniToken__NotBunniHub();
error BunniToken__NotPoolManager();
error BunniToken__ReferrerAddressIsZero();

error BunniHook__InvalidSwap();
error BunniHook__Unauthorized();
error BunniHook__InvalidModifier();
error BunniHook__PrehookPostConditionFailed();
error BunniHook__InvalidRebalanceOrderHookArgs();
