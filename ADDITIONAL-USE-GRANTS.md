# Additional Use Grants

## LDF Grant

The Licensor hereby grants you the right to make production use of the Licensed Work, limited to the following conditions and scope:

1. Scope of Grant
   This grant applies exclusively to the smart contract code contained within the `src/ldf/` and `test/mocks` directories of the Licensed Work.

2. Permitted Uses
   You may modify, compile, deploy, and make production use of the covered smart contracts, provided that any such deployed smart contract:

   a) Implements access control protections equivalent to or more restrictive than those defined in `src/base/Guarded.sol`; AND

   b) Restricts all external calls to the smart contract exclusively to canonical Bunni v2 deployments as listed and defined at v2-deployments.bunni.eth

3. Technical Requirements
   The access control implementation must prevent any unauthorized smart contract from directly or indirectly calling the deployed smart contract's functions through the following opcodes of the Ethereum Virtual Machine (EVM):

   - The `CALL` opcode
   - The `CALLCODE` opcode
   - The `STATICCALL` opcode
   - The `DELEGATECALL` opcode
   - Any future EVM opcodes that enable similar external calling mechanisms

4. Exclusions
   This grant explicitly does not extend to:

   a) Uses that enable unauthorized smart contracts to execute the logic of the part of the Licensed Work within the scope of this Additional Use Grant

   b) Implementations that include mechanisms to bypass or disable the required access controls

   c) Any uses outside the specific scope defined in Section 1

5. Compliance
   Failure to comply with these requirements voids this Additional Use Grant and reverts the usage rights to those defined in the base Business Source License 1.1.

All other terms and conditions of the Business Source License 1.1 remain in full force and effect.
