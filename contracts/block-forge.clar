;; Title: BlockForge: Bitcoin-Native Gaming Protocol
;; 
;; Summary:
;; A Stacks-powered protocol for on-chain gaming assets, leaderboard management, and 
;; Bitcoin reward distribution. BlockForge integrates NFT functionality with competitive 
;; gaming mechanics to create verifiable and economically incentivized gameplay.
;;
;; Description:
;; This contract enables the creation, management, and transfer of in-game NFT assets
;; with defined attributes and rarity levels. It includes a secure leaderboard system
;; with player registration, score tracking, and automated Bitcoin reward distribution.
;; The protocol's administrative functions ensure proper governance while maintaining
;; player security and asset integrity across the Bitcoin ecosystem.

;; Error Constants
(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-INVALID-GAME-ASSET (err u2))
(define-constant ERR-INSUFFICIENT-FUNDS (err u3))
(define-constant ERR-TRANSFER-FAILED (err u4))
(define-constant ERR-LEADERBOARD-FULL (err u5))
(define-constant ERR-ALREADY-REGISTERED (err u6))
(define-constant ERR-INVALID-REWARD (err u7))
(define-constant ERR-INVALID-INPUT (err u8))
(define-constant ERR-INVALID-SCORE (err u9))
(define-constant ERR-INVALID-FEE (err u10))
(define-constant ERR-INVALID-ENTRIES (err u11))
(define-constant ERR-PLAYER-NOT-FOUND (err u12))

;; Game Configuration and State Variables
(define-data-var game-fee uint u10)
(define-data-var max-leaderboard-entries uint u50)
(define-data-var total-prize-pool uint u0)
(define-data-var total-game-assets uint u0)

;; NFT Definitions and Metadata
(define-non-fungible-token game-asset uint)

(define-map game-asset-metadata 
  { token-id: uint }
  { 
    name: (string-ascii 50),
    description: (string-ascii 200),
    rarity: (string-ascii 20),
    power-level: uint
  }
)

;; Leaderboard and Administrative Controls
(define-map leaderboard 
  { player: principal }
  { 
    score: uint, 
    games-played: uint,
    total-rewards: uint 
  }
)
