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


(define-map game-admin-whitelist principal bool)

;; Read-only Validation Functions

;; Check if sender is a game admin
(define-read-only (is-game-admin (sender principal))
  (default-to false (map-get? game-admin-whitelist sender))
)

;; Validate input string
(define-read-only (is-valid-string (input (string-ascii 200)))
  (> (len input) u0)
)

;; Validate principal
(define-read-only (is-valid-principal (input principal))
  (and 
    (not (is-eq input tx-sender))
    (not (is-eq input (as-contract tx-sender)))
  )
)

;; Enhanced principal validation for security
(define-read-only (is-safe-principal (input principal))
  (and 
    (is-valid-principal input)
    (or 
      (is-game-admin input)
      (is-some (map-get? leaderboard { player: input }))
    )
  )
)

;; Administrative Functions

;; Add game administrator with access controls
(define-public (add-game-admin (new-admin principal))
  (begin
    (asserts! (is-game-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-safe-principal new-admin) ERR-INVALID-INPUT)
    (map-set game-admin-whitelist new-admin true)
    (ok true)
  )
)

;; Initialize game configuration
(define-public (initialize-game 
  (entry-fee uint) 
  (max-entries uint)
)
  (begin
    (asserts! (is-game-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= entry-fee u1) (<= entry-fee u1000)) ERR-INVALID-FEE)
    (asserts! (and (>= max-entries u1) (<= max-entries u500)) ERR-INVALID-ENTRIES)
    
    (var-set game-fee entry-fee)
    (var-set max-leaderboard-entries max-entries)
    
    (ok true)
  )
)

;; NFT Management Functions

;; Mint new game asset NFT with metadata
(define-public (mint-game-asset 
  (name (string-ascii 50))
  (description (string-ascii 200))
  (rarity (string-ascii 20))
  (power-level uint)
)
  (let 
    (
      (token-id (+ (var-get total-game-assets) u1))
    )
    (asserts! (is-game-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-string name) ERR-INVALID-INPUT)
    (asserts! (is-valid-string description) ERR-INVALID-INPUT)
    (asserts! (is-valid-string rarity) ERR-INVALID-INPUT)
    (asserts! (and (>= power-level u0) (<= power-level u1000)) ERR-INVALID-INPUT)
    
    (try! (nft-mint? game-asset token-id tx-sender))
    
    (map-set game-asset-metadata 
      { token-id: token-id }
      {
        name: name,
        description: description, 
        rarity: rarity,
        power-level: power-level
      }
    )
    
    (var-set total-game-assets token-id)
    
    (ok token-id)
  )
)

;; Transfer game asset between players
(define-public (transfer-game-asset 
  (token-id uint) 
  (recipient principal)
)
  (begin
    (asserts! 
      (is-eq tx-sender (unwrap! (nft-get-owner? game-asset token-id) ERR-INVALID-GAME-ASSET))
      ERR-NOT-AUTHORIZED
    )
    
    (asserts! (is-safe-principal recipient) ERR-INVALID-INPUT)
    
    (nft-transfer? game-asset token-id tx-sender recipient)
  )
)

;; Player Management Functions

;; Player registration with entry fee
(define-public (register-player)
  (let 
    (
      (registration-fee (var-get game-fee))
    )
    (asserts! 
      (>= (stx-get-balance tx-sender) registration-fee) 
      ERR-INSUFFICIENT-FUNDS
    )
    
    (asserts! 
      (is-none (map-get? leaderboard { player: tx-sender }))
      ERR-ALREADY-REGISTERED
    )
    
    (try! (stx-transfer? registration-fee tx-sender (as-contract tx-sender)))
    
    (map-set leaderboard 
      { player: tx-sender }
      {
        score: u0,
        games-played: u0,
        total-rewards: u0
      }
    )
    
    (ok true)
  )
)

;; Update player score by authorized admins
(define-public (update-player-score 
  (player principal) 
  (new-score uint)
)
  (let 
    (
      (current-stats (unwrap! 
        (map-get? leaderboard { player: player }) 
        ERR-PLAYER-NOT-FOUND
      ))
    )
    (asserts! (is-game-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-safe-principal player) ERR-INVALID-INPUT)
    (asserts! (and (>= new-score u0) (<= new-score u10000)) ERR-INVALID-SCORE)
    
    (map-set leaderboard 
      { player: player }
      (merge current-stats 
        {
          score: new-score,
          games-played: (+ (get games-played current-stats) u1)
        }
      )
    )
    
    (ok true)
  )
)