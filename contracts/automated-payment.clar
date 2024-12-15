;; Automated Payment Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-already-paid (err u103))

;; Maps
(define-map payments
  { invoice-id: uint }
  {
    payer: principal,
    amount: uint,
    status: (string-ascii 20)
  }
)

;; Public Functions
(define-public (register-payment (invoice-id uint) (payer principal) (amount uint))
  (let
    (
      (invoice (unwrap! (contract-call? .invoice-token get-invoice invoice-id) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-eq (get payer invoice) payer) err-unauthorized)
    (map-set payments
      { invoice-id: invoice-id }
      {
        payer: payer,
        amount: amount,
        status: "pending"
      }
    )
    (ok true)
  )
)

(define-public (confirm-delivery (invoice-id uint))
  (let
    (
      (payment (unwrap! (map-get? payments { invoice-id: invoice-id }) err-not-found))
      (owner (unwrap! (contract-call? .invoice-token get-owner invoice-id) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-eq (get status payment) "pending") err-already-paid)
    (try! (stx-transfer? (get amount payment) (get payer payment) owner))
    (map-set payments
      { invoice-id: invoice-id }
      (merge payment { status: "paid" })
    )
    (try! (contract-call? .invoice-token update-invoice-status invoice-id "paid"))
    (ok true)
  )
)

(define-read-only (get-payment-status (invoice-id uint))
  (map-get? payments { invoice-id: invoice-id })
)

