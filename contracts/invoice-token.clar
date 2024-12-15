;; Invoice Token Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-minted (err u102))

;; Data Variables
(define-data-var last-token-id uint u0)

;; Maps
(define-map invoices
  { token-id: uint }
  {
    issuer: principal,
    payer: principal,
    amount: uint,
    due-date: uint,
    status: (string-ascii 20)
  }
)

;; Define NFT
(define-non-fungible-token invoice-token uint)

;; Mint Invoice Token
(define-public (mint-invoice (payer principal) (amount uint) (due-date uint))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (nft-mint? invoice-token token-id tx-sender))
    (map-set invoices
      { token-id: token-id }
      {
        issuer: tx-sender,
        payer: payer,
        amount: amount,
        due-date: due-date,
        status: "active"
      }
    )
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

;; Get Invoice Details
(define-read-only (get-invoice (token-id uint))
  (map-get? invoices { token-id: token-id })
)

;; Update Invoice Status
(define-public (update-invoice-status (token-id uint) (new-status (string-ascii 20)))
  (let
    (
      (invoice (unwrap! (map-get? invoices { token-id: token-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set invoices
      { token-id: token-id }
      (merge invoice { status: new-status })
    )
    (ok true)
  )
)

;; Transfer invoice token
(define-public (transfer (token-id uint) (recipient principal))
  (let
    (
      (invoice (unwrap! (map-get? invoices { token-id: token-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender (get issuer invoice)) err-owner-only)
    (map-set invoices
      { token-id: token-id }
      (merge invoice { issuer: recipient })
    )
    (ok true)
  )
)

;; Get invoice owner
(define-read-only (get-owner (token-id uint))
  (ok (get issuer (unwrap! (map-get? invoices { token-id: token-id }) err-not-found)))
)

;; Get last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

