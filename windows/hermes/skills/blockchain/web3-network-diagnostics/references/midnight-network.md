# Midnight Network Architecture & Diagnostics

## Environments & Endpoints
Midnight environments are named **preprod**, **preview**, and **devnet**. The domain `testnet.midnight.network` does not exist.

- **Preprod RPC**: `https://rpc.preprod.midnight.network`
- **Preprod Faucet**: `https://faucet.preprod.midnight.network`
- **Preview RPC**: `https://rpc.preview.midnight.network`
- **Preview Faucet**: `https://faucet.preview.midnight.network`
- **Devnet RPC**: `https://rpc.devnet.midnight.network`
- **Devnet Faucet**: `https://faucet.devnet.midnight.network`

## JSON-RPC Probing Commands
Test health and block production via JSON-RPC POST:
```bash
# Check node sync and peer count
curl -X POST https://rpc.preprod.midnight.network \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"system_health","params":[]}'

# Check latest block header
curl -X POST https://rpc.preprod.midnight.network \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"chain_getBlock","params":[]}'
```

## Gas Bootstrapping & DUST Conversion
1. **tNIGHT to DUST**: DUST is the gas token required to execute shielded/unshielded transactions and submit state transitions on Midnight.
2. **The Sponsorship Dependency (e.g., 1AM)**:
   - Converting tNIGHT to DUST or registering keys requires submitting an on-chain transaction.
   - If the user has 0 DUST, this initial transaction relies on an external sponsor service (such as 1AM).
   - If the sponsor service is down or unconfigured, the transaction fails to submit, creating a deadlock.
   - **Remedy**: Transfer DUST directly from an already-funded wallet, or wait for the sponsor service to recover.
3. **Faucets & Cloudflare Turnstile**:
   - The web faucet at `https://faucet.preprod.midnight.network` uses Cloudflare Turnstile anti-bot checks. Automated script requests are rejected; claims must be performed manually in the browser.
