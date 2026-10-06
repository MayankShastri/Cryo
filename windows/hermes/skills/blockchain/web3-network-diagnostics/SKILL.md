---
name: web3-network-diagnostics
description: Diagnostic procedures for Web3 RPCs, indexers, faucets, and gas-sponsorship mechanisms during DApp testing.
category: blockchain
---

# Web3 Network Diagnostics & Troubleshooting

This skill provides a systematic approach to diagnosing Web3 network issues, RPC node health, faucet blockers, and transaction submission failures (such as the gas bootstrapping Catch-22).

## Trigger Conditions
- The user reports transaction failures or wallet sync issues in a development/testnet environment.
- Faucet requests fail, or the user cannot obtain test tokens.
- Transaction sponsors (relayers, paymasters, or gas fee delegators) are suspected to be offline.
- Standard API or indexer queries return HTTP errors.

## Systematic Diagnostic Workflow

### 1. DNS and Network Verification
- **Validate Environment Names**: Ensure the client is targeting the correct environment name (e.g., in Midnight, environments are named `preprod`, `preview`, and `devnet`; using a generic `testnet` prefix may cause DNS NXDOMAIN errors).
- **Probing RPC Endpoints**:
  - Do not rely solely on simple `GET` requests to RPC endpoints; they often return `HTTP 405 Method Not Allowed`.
  - Use exact `POST` JSON-RPC payloads to check network status, block heights, or system health (e.g., querying block number or peer count).

### 2. Indexer and Faucet Validation
- **Indexer Probing**: Indexers often expose GraphQL or REST APIs. Probe paths like `/graphql`, `/api/v1/graphql`, or health check endpoints.
- **Faucet Verification**:
  - Check the faucet homepage for interactive protections (e.g., Cloudflare Turnstile, CAPTCHAs).
  - If a faucet uses interactive front-end challenges, direct API script calls (e.g., `POST /api/v1/request`) will be blocked by Cloudflare. Guide the user to use the official web interface.

### 3. Transaction Gas Bootstrapping & Sponsorship Failures
- **The Catch-22**: Many chains and sidechains allow transactions without native gas via *sponsorship services* or *paymasters*. If a user cannot convert a base utility token because they lack gas, they rely on a sponsor.
- **Sponsor Outages**: If the sponsor service is down, rate-limited, or misconfigured, the transaction will fail to build or submit.
- **Workarounds**:
  - Verify if the sponsor service is reachable or reporting errors.
  - Suggest pre-seeding the testing wallet directly with gas tokens from an already funded master/admin wallet instead of relying on self-conversion/sponsorship.

## Linked References
- See `references/midnight-network.md` for environment-specific details, RPC URLs, and Midnight "1AM" sponsor diagnostic findings.
