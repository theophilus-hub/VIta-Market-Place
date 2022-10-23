;; BUYERS MAP
(define-map buyers {id: principal, type: (string-ascii 7)} 
    {
        nickname: (string-ascii 28),
        email: (string-ascii 28),
        address: principal,
        location: (string-ascii 28),
    }
)
;; SELLER MAP
(define-map sellers {id: principal, type: (string-ascii 7)}
    {
        nickname: (string-ascii 28),
        email: (string-ascii 28),
        address: principal,
        location: (string-ascii 28),
    }
)
;; ITEMS MAP
(define-map items uint {id: principal, type: (string-ascii 7),
        name: (string-ascii 25),
        description: (string-ascii 28),
        address: principal,
        price: uint,
        quantity: uint,
    }
)
;;order map
(define-map order uint 
    {
    name: (string-ascii 25),
    price: uint, 
    buyers-addr: principal, 
    sellers-addr: principal, 
    buy-confirm: bool,
    sell-confirm: bool
    }
)


;;variables
(define-data-var cartId uint u0)
(define-data-var toupleid uint u0)
(define-data-var confirm bool true)


;; CREATE BUYER PROFILE
(define-public (create-buyer (nickname (string-ascii 28)) (email (string-ascii 28)) (address principal) (location (string-ascii 28))
)
    (begin
        ;; #[filter(nickname, email, address, location)]
        (map-set buyers {id: address, type: "acc"} {nickname: nickname, email: email, address: address, location: location} )
        (ok (map-get? buyers {id: address, type: "acc"}))
    )
)
;; CREATE SELLER PROFILE
(define-public (create-seller (nickname (string-ascii 28)) (email (string-ascii 28)) (address principal) (location (string-ascii 28)))
    (begin
        (map-set sellers {id: address, type: "acc"} { nickname: nickname, email: email, address: address, location: location })
        (ok (map-get? sellers {id: address, type: "acc"}))
    )
)


;; GET ACCOUNT FUNCTION
(define-read-only (get-account (id {id: principal, type: (string-ascii 7)}) (category (string-ascii 15)))
  
  
    (if (is-eq  category "buy")

    (begin (ok (map-get? buyers id)))

    (begin (ok (map-get? sellers id)))
    )
)


;; CREATE ITEM
(define-public (create-item (name (string-ascii 25)) (description (string-ascii 28)) (price uint) (quantity uint) (address principal))
    (begin
        (map-insert items (var-get toupleid) {id: address, type: "item", name: name, description: description, address: address, price: price, quantity: quantity})
        (print (map-get? items (var-get toupleid)))
        (var-set toupleid (+ (var-get toupleid) u1))
        (ok (var-get toupleid))
       
    )
)


;;CREATE ORDER
(define-public (create-order (touplenum uint) (address principal) )
    (let ((getter (map-get? items touplenum)))
        ;;(print (unwrap! (map-get? items touplenum) (err u76)))
        (print
         (map-insert order (var-get cartId) {
            name: (get name (unwrap! (map-get? items touplenum) (err u1))), 
            price: (get price (unwrap! (map-get? items touplenum) (err u1))),
            buyers-addr: address,
            sellers-addr: (get address (unwrap! (map-get? items touplenum) (err u1))),
            buy-confirm: false,
            sell-confirm: false
            }))
           
         (print (unwrap! (map-get? order (var-get cartId)) (err u76)))
        (var-set cartId (+ (var-get cartId) u1))
        (ok (var-get cartId))
    )
)


;;CONFIRM ORDER BUY
(define-public (confirm-order-buy (key uint))
(begin
   (is-ok (stx-transfer? (get price (unwrap! (map-get? order key) (err u1))) (get buyers-addr (unwrap! (map-get? order key) (err u1))) (as-contract tx-sender)))
    (ok
         (map-set order key {
            name: (get name (unwrap! (map-get? order key) (err u1))), 
            price: (get price (unwrap! (map-get? order key) (err u1))),
            buyers-addr: (get buyers-addr (unwrap! (map-get? order key) (err u1))),
            sellers-addr: (get sellers-addr (unwrap! (map-get? order key) (err u1))),
            buy-confirm: (var-get confirm),
            sell-confirm: false
            }))
    )
)

;;CONFIRM ORDER SELL
(define-public (confirm-order-sell (key uint))
(begin
      (is-ok (stx-transfer? (get price (unwrap! (map-get? order key) (err u1))) (as-contract tx-sender) (get sellers-addr (unwrap! (map-get? order key) (err u1)))))
    (ok
         (map-set order key {
            name: (get name (unwrap! (map-get? order key) (err u1))), 
            price: (get price (unwrap! (map-get? order key) (err u1))),
            buyers-addr: (get buyers-addr (unwrap! (map-get? order key) (err u1))),
            sellers-addr: (get sellers-addr (unwrap! (map-get? order key) (err u1))),
            buy-confirm: (get buy-confirm (unwrap! (map-get? order key) (err u1))),
            sell-confirm: (var-get confirm)
            }))
    )
)

;; (define-public (purchase-item (itemNo uint))

;;     (map-insert buyers-cart u0 {})

;; )