;; Payment Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-payment-exists (err u103))

;; Data Variables
(define-data-var last-payment-id uint u0)

;; Maps
(define-map payments
  { payment-id: uint }
  {
    payer: principal,
    recipient: principal,
    amount: uint,
    status: (string-ascii 20)
  }
)

;; Public Functions
(define-public (make-payment (recipient principal) (amount uint))
  (let
    (
      (payment-id (+ (var-get last-payment-id) u1))
    )
    (asserts! (> amount u0) err-unauthorized)
    (asserts! (is-none (map-get? payments { payment-id: payment-id })) err-payment-exists)
    (try! (stx-transfer? amount tx-sender recipient))
    (map-set payments
      { payment-id: payment-id }
      {
        payer: tx-sender,
        recipient: recipient,
        amount: amount,
        status: "completed"
      }
    )
    (var-set last-payment-id payment-id)
    (ok payment-id)
  )
)

(define-read-only (get-payment (payment-id uint))
  (map-get? payments { payment-id: payment-id })
)

(define-read-only (get-last-payment-id)
  (ok (var-get last-payment-id))
)

