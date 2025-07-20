;; Equipment Rental Contract
;; Provides disc rental services for new players

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u200))
(define-constant ERR-RENTAL-NOT-FOUND (err u404))
(define-constant ERR-INVALID-INPUT (err u400))
(define-constant ERR-INSUFFICIENT-INVENTORY (err u401))
(define-constant ERR-INSUFFICIENT-FUNDS (err u402))
(define-constant ERR-ALREADY-RENTED (err u409))
(define-constant ERR-NOT-RENTED (err u410))

;; Data Variables
(define-data-var next-rental-id uint u1)
(define-data-var available-discs uint u100)
(define-data-var rental-rate-per-disc uint u100000) ;; 0.1 STX per disc
(define-data-var deposit-per-disc uint u500000) ;; 0.5 STX deposit per disc

;; Data Maps
(define-map disc-inventory
  { disc-type: (string-ascii 20) }
  {
    available-count: uint,
    total-count: uint,
    condition: (string-ascii 20),
    rental-rate: uint
  }
)

(define-map active-rentals
  { rental-id: uint }
  {
    renter: principal,
    disc-count: uint,
    disc-type: (string-ascii 20),
    rental-date: uint,
    deposit-paid: uint,
    rental-fee-paid: uint,
    returned: bool,
    return-date: (optional uint)
  }
)

(define-map renter-history
  { renter: principal }
  {
    total-rentals: uint,
    current-rental: (optional uint),
    reputation-score: uint
  }
)

;; Private Functions
(define-private (calculate-rental-cost (disc-count uint))
  (* disc-count (var-get rental-rate-per-disc))
)

(define-private (calculate-deposit (disc-count uint))
  (* disc-count (var-get deposit-per-disc))
)

;; Public Functions

;; Initialize disc inventory
(define-public (add-disc-inventory (disc-type (string-ascii 20)) (count uint) (condition (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> count u0) ERR-INVALID-INPUT)

    (map-set disc-inventory
      { disc-type: disc-type }
      {
        available-count: count,
        total-count: count,
        condition: condition,
        rental-rate: (var-get rental-rate-per-disc)
      }
    )
    (ok true)
  )
)

;; Rent discs
(define-public (rent-discs (disc-count uint) (disc-type (string-ascii 20)))
  (let (
    (rental-id (var-get next-rental-id))
    (inventory-data (unwrap! (map-get? disc-inventory { disc-type: disc-type }) ERR-RENTAL-NOT-FOUND))
    (rental-cost (calculate-rental-cost disc-count))
    (deposit-amount (calculate-deposit disc-count))
    (total-cost (+ rental-cost deposit-amount))
    (renter-data (default-to { total-rentals: u0, current-rental: none, reputation-score: u100 }
                             (map-get? renter-history { renter: tx-sender })))
  )
    (asserts! (> disc-count u0) ERR-INVALID-INPUT)
    (asserts! (>= (get available-count inventory-data) disc-count) ERR-INSUFFICIENT-INVENTORY)
    (asserts! (is-none (get current-rental renter-data)) ERR-ALREADY-RENTED)
    (asserts! (>= (stx-get-balance tx-sender) total-cost) ERR-INSUFFICIENT-FUNDS)

    ;; Transfer payment
    (try! (stx-transfer? total-cost tx-sender (as-contract tx-sender)))

    ;; Update inventory
    (map-set disc-inventory
      { disc-type: disc-type }
      (merge inventory-data {
        available-count: (- (get available-count inventory-data) disc-count)
      })
    )

    ;; Create rental record
    (map-set active-rentals
      { rental-id: rental-id }
      {
        renter: tx-sender,
        disc-count: disc-count,
        disc-type: disc-type,
        rental-date: block-height,
        deposit-paid: deposit-amount,
        rental-fee-paid: rental-cost,
        returned: false,
        return-date: none
      }
    )

    ;; Update renter history
    (map-set renter-history
      { renter: tx-sender }
      {
        total-rentals: (+ (get total-rentals renter-data) u1),
        current-rental: (some rental-id),
        reputation-score: (get reputation-score renter-data)
      }
    )

    (var-set next-rental-id (+ rental-id u1))
    (ok rental-id)
  )
)

;; Return discs
(define-public (return-discs (rental-id uint))
  (let (
    (rental-data (unwrap! (map-get? active-rentals { rental-id: rental-id }) ERR-RENTAL-NOT-FOUND))
    (inventory-data (unwrap! (map-get? disc-inventory { disc-type: (get disc-type rental-data) }) ERR-RENTAL-NOT-FOUND))
    (renter-data (unwrap! (map-get? renter-history { renter: tx-sender }) ERR-RENTAL-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender (get renter rental-data)) ERR-NOT-AUTHORIZED)
    (asserts! (not (get returned rental-data)) ERR-NOT-RENTED)

    ;; Update rental record
    (map-set active-rentals
      { rental-id: rental-id }
      (merge rental-data {
        returned: true,
        return-date: (some block-height)
      })
    )

    ;; Update inventory
    (map-set disc-inventory
      { disc-type: (get disc-type rental-data) }
      (merge inventory-data {
        available-count: (+ (get available-count inventory-data) (get disc-count rental-data))
      })
    )

    ;; Update renter history
    (map-set renter-history
      { renter: tx-sender }
      (merge renter-data {
        current-rental: none,
        reputation-score: (+ (get reputation-score renter-data) u10)
      })
    )

    ;; Return deposit
    (try! (as-contract (stx-transfer? (get deposit-paid rental-data) tx-sender (get renter rental-data))))
    (ok true)
  )
)

;; Update rental rates
(define-public (update-rental-rate (new-rate uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> new-rate u0) ERR-INVALID-INPUT)
    (var-set rental-rate-per-disc new-rate)
    (ok true)
  )
)

;; Read-only Functions

;; Get rental information
(define-read-only (get-rental-info (rental-id uint))
  (map-get? active-rentals { rental-id: rental-id })
)

;; Get disc inventory
(define-read-only (get-disc-inventory (disc-type (string-ascii 20)))
  (map-get? disc-inventory { disc-type: disc-type })
)

;; Get renter history
(define-read-only (get-renter-history (renter principal))
  (map-get? renter-history { renter: renter })
)

;; Get current rental rates
(define-read-only (get-rental-rates)
  {
    rental-rate: (var-get rental-rate-per-disc),
    deposit-rate: (var-get deposit-per-disc)
  }
)

;; Check availability
(define-read-only (check-availability (disc-type (string-ascii 20)))
  (match (map-get? disc-inventory { disc-type: disc-type })
    inventory-data (get available-count inventory-data)
    u0
  )
)
