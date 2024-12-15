;; Credit Scoring Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))

;; Maps
(define-map credit-scores
  { participant: principal }
  {
    score: uint,
    total-transactions: uint,
    total-value: uint,
    on-time-payments: uint
  }
)

;; Public Functions
(define-public (update-credit-score (participant principal) (transaction-value uint) (on-time bool))
  (let
    (
      (current-score (default-to { score: u500, total-transactions: u0, total-value: u0, on-time-payments: u0 }
                                 (map-get? credit-scores { participant: participant })))
      (new-total-transactions (+ (get total-transactions current-score) u1))
      (new-total-value (+ (get total-value current-score) transaction-value))
      (new-on-time-payments (if on-time (+ (get on-time-payments current-score) u1) (get on-time-payments current-score)))
      (new-score (calculate-score new-total-transactions new-total-value new-on-time-payments))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set credit-scores
      { participant: participant }
      {
        score: new-score,
        total-transactions: new-total-transactions,
        total-value: new-total-value,
        on-time-payments: new-on-time-payments
      }
    )
    (ok new-score)
  )
)

(define-private (calculate-score (total-transactions uint) (total-value uint) (on-time-payments uint))
  (let
    (
      (base-score u500)
      (transaction-score (/ (* total-transactions u100) u10))
      (value-score (/ total-value u1000000))
      (on-time-score (/ (* on-time-payments u300) total-transactions))
      (total-score (+ base-score transaction-score value-score on-time-score))
    )
    (if (> total-score u1000)
      u1000
      total-score
    )
  )
)

(define-read-only (get-credit-score (participant principal))
  (map-get? credit-scores { participant: participant })
)

