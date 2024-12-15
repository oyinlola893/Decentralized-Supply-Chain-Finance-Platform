;; Product Registry Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))

;; Data Variables
(define-data-var last-product-id uint u0)

;; Maps
(define-map products
  { product-id: uint }
  {
    manufacturer: principal,
    name: (string-ascii 50),
    description: (string-ascii 500)
  }
)

;; Public Functions
(define-public (register-product (name (string-ascii 50)) (description (string-ascii 500)))
  (let
    (
      (product-id (+ (var-get last-product-id) u1))
    )
    (map-set products
      { product-id: product-id }
      {
        manufacturer: tx-sender,
        name: name,
        description: description
      }
    )
    (var-set last-product-id product-id)
    (ok product-id)
  )
)

;; Read-only Functions
(define-read-only (get-manufacturer (product-id uint))
  (match (map-get? products { product-id: product-id })
    product (ok (get manufacturer product))
    (err err-not-found)
  )
)

(define-read-only (get-product-details (product-id uint))
  (map-get? products { product-id: product-id })
)

(define-read-only (get-last-product-id)
  (ok (var-get last-product-id))
)

