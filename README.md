# BlockForge: Bitcoin-Native Gaming Protocol

BlockForge is a **Stacks-based Clarity smart contract protocol** that brings verifiable, on-chain asset creation and competitive gaming to the Bitcoin ecosystem. It fuses **non-fungible tokens (NFTs)**, **leaderboard mechanics**, and **Bitcoin reward distribution** into a trust-minimized, decentralized gaming framework.

## Overview

BlockForge enables game developers to:

- **Mint and manage game NFTs** with customizable metadata (name, rarity, power level).
- **Run a competitive leaderboard** with tamper-resistant score tracking and reward mechanisms.
- **Distribute Bitcoin-denominated rewards** based on verified in-game performance.
- Enforce **robust administrative controls** and secure game state transitions.

Built entirely in Clarity, BlockForge leverages Bitcoin finality through Stacks' proof-of-transfer (PoX) model.

## Features

### Game Asset (NFT) Management

- Create game NFTs with attributes: `name`, `description`, `rarity`, and `power-level`.
- Secure NFT ownership using Clarity’s native `nft-mint?` and `nft-transfer?` functions.
- Ensure asset integrity using error-checking and strict input validation.

### Player Onboarding

- Players register by paying a configurable entry fee in STX.
- Duplicate registration is prevented; each wallet can only register once.
- Player profiles are tracked with metadata: `score`, `games_played`, `total_rewards`.

### Leaderboard System

- Track and update player scores.
- Only whitelisted game administrators can modify player stats.
- Configurable leaderboard limits (max entries).
- Players gain rankings through fair, transparent score accumulation.

### Bitcoin Reward Distribution

- Rewards are automatically calculated and distributed based on score.
- Players must exceed a minimum score to qualify.
- Uses a filtering mechanism to select valid reward candidates.
- Rewards scale linearly based on player performance (`score * 10`).

### Administrative Governance

- Admin-only functions for:
  - Adding new administrators.
  - Initializing game parameters.
  - Managing scores and distributing rewards.
- Initial admin is the contract deployer (via `tx-sender`).
- All administrative functions use access control via a `game-admin-whitelist`.

## Contract Structure

### Key Components

| Section                | Description                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| `game-asset`           | NFT type representing in-game assets.                                      |
| `game-asset-metadata`  | Map holding metadata for each NFT.                                          |
| `leaderboard`          | Map tracking player scores and stats.                                      |
| `game-admin-whitelist` | Map of authorized admins with control privileges.                          |
| `game-fee`             | STX fee required for player registration.                                   |
| `total-prize-pool`     | Tracks prize pool (can be extended for off-chain integrations).             |
| `get-top-players()`    | Placeholder for leaderboard logic (to be expanded for ranked lists).        |

## Function Reference

### Public Functions

- `add-game-admin(new-admin)`  
  Add a new administrator if `tx-sender` is already an admin.

- `initialize-game(entry-fee, max-entries)`  
  Set the entry fee and leaderboard size.

- `mint-game-asset(name, description, rarity, power-level)`  
  Create a new NFT and store metadata.

- `transfer-game-asset(token-id, recipient)`  
  Transfer an NFT to another player if sender is the owner.

- `register-player()`  
  Register a new player by paying the entry fee.

- `update-player-score(player, new-score)`  
  Update a player's score and increment games played.

- `distribute-bitcoin-rewards()`  
  Reward eligible players based on their leaderboard score.

### Read-only Functions

- `is-game-admin(sender)`  
  Checks if the sender is in the admin whitelist.

- `is-valid-string(input)`  
  Checks if the input string is non-empty.

- `is-safe-principal(input)`  
  Confirms the principal is valid and not a contract.

- `get-top-players()`  
  Returns a list of top players (placeholder).

## Security Design

- Access-controlled administrative functions.
- Input validation guards all user and admin input.
- Game score tampering prevented via admin-only update.
- Player identity is protected by `principal` validation to avoid contracts posing as players.

## Configuration

To initialize a game:

```clarity
(initialize-game u10 u100) ;; 10 STX entry fee, 100 leaderboard slots
```

To register a player:

```clarity
(register-player)
```

To mint a game asset:

```clarity
(mint-game-asset "Sword of Satoshi" "Legendary blade" "Legendary" u500)
```

To update score:

```clarity
(update-player-score 'ST12...ABC u450)
```

To distribute rewards:

```clarity
(distribute-bitcoin-rewards)
```

## Limitations & Future Work

- `get-top-players()` is currently a placeholder — should be implemented using dynamic sorting or an off-chain indexer.
- Bitcoin reward distribution uses a calculated model, but off-chain STX-to-BTC bridging (e.g., via Hiro wallets or Layer 2 bridges) is assumed for actual Bitcoin payouts.
- No NFT trading marketplace included (yet).
- Consider integrating with Oracles for trustless reward distribution using BTC bridges.

## Use Cases

- **Esports tournaments** with on-chain prize verification.
- **Collectible RPGs** where rarity and power-level drive gameplay.
- **Play-to-earn arcades** powered by Bitcoin.
- **Decentralized gaming guilds** that track and reward performance transparently.
