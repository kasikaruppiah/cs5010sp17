;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require "extras.rkt")
(require rackunit)

(provide make-flapjack
         flapjack-x
         flapjack-y
         flapjack-radius
         make-skillet
         skillet-x
         skillet-y
         skillet-radius
         overlapping-flapjacks
         non-overlapping-flapjacks
         flapjacks-in-skillet)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; DATA DEFINITIONS

(define-struct flapjack (x y radius))
;; A Flapjack is a structure:
;;   (make-flapjack Real Real PosReal)
;; Interpretation:
;;   x is the x coordinate of the center of the Flapjack
;;   y is the y coordinate of the center of the Flapjack
;;   radius is the radius of the Flapjack
;; TEMPLATE:
;;   flapjack-fn : Flapjack -> ??
#|
(define (flapjack-fn fj)
  (...
   (flapjack-x fj)
   (flapjack-y fj)
   (flapjack-radius fj)))
|#

(define-struct skillet (x y radius))
;; A Skillet is a structure:
;;   (make-skillet Real Real PosReal)
;; Interpretation:
;;   x is the x coordinate of the center of the Skillet
;;   y is the y coordinate of the center of the Skillet
;;   radius is the radius of the Skillet
;; TEMPLATE:
;;   skillet-fn : Skillet -> ??
#|
(define (skillet-fn sl)
  (...
   (skillet-x sl)
   (skillet-y sl)
   (skillet-radius sl)))
|#

;; A list of Flapjack (ListOfFlapjack) is either
;;   -- empty
;;   -- (cons Flapjack ListOfFlapjack)
;; TEMPLATE:
;;   lof-fn : LOF -> ??
#|
(define (lof-fn lof)
  (cond [(empty? lof) ...]
        [else (... (first lof)
                   (lof-fn (rest lof)))]))
|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; FUNCTIONS

;; overlapping-check-helper : Flapjack ListOfFlapjack -> ListOfFlapjack
;; GIVEN: a flapjack and a list of flapjacks
;; RETURNS: a list of flapjacks that overlap with the flapjack in the input
;; EXAMPLE:
;;   (overlapping-check-helper
;;    (make-flapjack -10 2 5)
;;    (list (make-flapjack -10 2 5)
;;          (make-flapjack -3 0 4)
;;          (make-flapjack 4 -2 4.6)
;;          (make-flapjack 7.2 6 5)
;;          (make-flapjack 20 4 4.2))) =
;;     (list (make-flapjack -10 2 5)
;;           (make-flapjack -3 0 4))
(define (overlapping-check-helper fj lof)
  (cond [(empty? lof) empty]
        [(> (+ (sqr (- (flapjack-x (first lof)) (flapjack-x fj)))
               (sqr (- (flapjack-y (first lof)) (flapjack-y fj))))
            (sqr (+ (flapjack-radius (first lof)) (flapjack-radius fj))))
         (overlapping-check-helper fj (rest lof))]
        [else (cons (first lof)
                    (overlapping-check-helper fj (rest lof)))]))

;; overlapping-flapjacks-helper : ListOfFlapjack ListOfFlapjack ->
;;   ListOfListOfFlapjack
;; GIVEN: a list of flapjacks to be checked and a list of all Flapjacks
;; RETURNS: a list of the same length whose i-th element is a list of the
;;   flapjacks in the given list that overlap with the i-th flapjack in the
;;   given list
;; EXAMPLE:
;;   (overlapping-flapjacks-helper
;;    (list (make-flapjack -10 2 5)
;;          (make-flapjack 20 4 4.2))
;;    (list (make-flapjack -10 2 5)
;;          (make-flapjack -3 0 4)
;;          (make-flapjack 4 -2 4.6)
;;          (make-flapjack 7.2 6 5)
;;          (make-flapjack 20 4 4.2))) =
;;     (list
;;      (list (make-flapjack -10 2 5)
;;            (make-flapjack -3 0 4))
;;      (list (make-flapjack 20 4 4.2)))
;; STRATEGY: use template ListOfFlapjack on i-th-lof
(define (overlapping-flapjacks-helper i-th-lof lof)
  (cond [(empty? i-th-lof) empty]
        [else (cons (overlapping-check-helper (first i-th-lof) lof)
                    (overlapping-flapjacks-helper (rest i-th-lof) lof))]))

;; overlapping-flapjacks : ListOfFlapjack -> ListOfListOfFlapjack
;; GIVEN: a list of flapjacks
;; RETURNS: a list of the same length whose i-th element is a list of the
;;   flapjacks in the given list that overlap with the i-th flapjack in the
;;   given list
;; EXAMPLES:
;;   (overlapping-flapjacks empty) => empty
;;   (overlapping-flapjacks
;;    (list (make-flapjack -10 2 5)
;;          (make-flapjack -3 0 4)
;;          (make-flapjack 4 -2 4.6)
;;          (make-flapjack 7.2 6 5)
;;          (make-flapjack 20 4 4.2))) =>
;;     (list (list (make-flapjack -10 2 5)
;;                 (make-flapjack -3 0 4))
;;           (list (make-flapjack -10 2 5)
;;                 (make-flapjack -3 0 4)
;;                 (make-flapjack 4 -2 4.6))
;;           (list (make-flapjack -3 0 4)
;;                 (make-flapjack 4 -2 4.6)
;;                 (make-flapjack 7.2 6 5))
;;           (list (make-flapjack 4 -2 4.6)
;;                 (make-flapjack 7.2 6 5))
;;           (list (make-flapjack 20 4 4.2)))
;; STRATEGY: use template ListOfFlapjack on lof
(define (overlapping-flapjacks lof)
  (overlapping-flapjacks-helper lof lof))

;; non-overlapping-flapjacks-helper : ListOfFlapjack ListOfFlapjack ->
;;   ListOfFlapjack
;; GIVEN: a list of flapjacks to be checked and a list of all flapjacks
;; RETURNS: a list of the flapjacks in the given list that do not
;;   overlap with any other flapjacks in the list
;; EXAMPLES:
;;   (non-overlapping-flapjacks-helper
;;    (list (make-flapjack -10 2 5)
;;          (make-flapjack 20 4 4.2))
;;    (list (make-flapjack -10 2 5)
;;          (make-flapjack -3 0 4)
;;          (make-flapjack 4 -2 4.6)
;;          (make-flapjack 7.2 6 5)
;;          (make-flapjack 20 4 4.2))) =
;;     (list (make-flapjack  20  4 4.2))
;; STRATEGY: use template ListOfFlapjack on i-th-lof
(define (non-overlapping-flapjacks-helper i-th-lof lof)
  (cond [(empty? i-th-lof) empty]
        [(> (length (overlapping-check-helper (first i-th-lof) lof)) 1)
         (non-overlapping-flapjacks-helper (rest i-th-lof) lof)]
        [else (cons (first i-th-lof)
                    (non-overlapping-flapjacks-helper (rest i-th-lof) lof))]))

;; non-overlapping-flapjacks : ListOfFlapjack -> ListOfFlapjack
;; GIVEN: a list of flapjacks
;; RETURNS: a list of the flapjacks in the given list that do not
;;   overlap with any other flapjacks in the list
;; EXAMPLES:
;;   (non-overlapping-flapjacks empty) => empty
;;   (non-overlapping-flapjacks
;;    (list (make-flapjack -10 2 5)
;;          (make-flapjack -3 0 4)
;;          (make-flapjack 4 -2 4.6)
;;          (make-flapjack 7.2 6 5)
;;          (make-flapjack 20 4 4.2))) =>
;;     (list (make-flapjack  20  4 4.2))
;; STRATEGY: use template ListOfFlapjack on lof
(define (non-overlapping-flapjacks lof)
  (non-overlapping-flapjacks-helper lof lof))

;; flapjacks-in-skillet : ListOfFlapjack Skillet -> ListOfFlapjack
;; GIVEN: a list of flapjacks and a skillet
;; RETURNS: a list of the given flapjacks that fit entirely within the skillet
;; EXAMPLE:
;;   (flapjacks-in-skillet
;;    (list (make-flapjack -10 2 5)
;;          (make-flapjack -3 0 4)
;;          (make-flapjack 4 -2 4.6)
;;          (make-flapjack 7.2 6 5)
;;          (make-flapjack 20 4 4.2))
;;    (make-skillet 2 3 12)) =>
;;     (list (make-flapjack -3 0 4)
;;           (make-flapjack 4 -2 4.6)
;;           (make-flapjack 7.2 6 5))
;; STRATEGY: use template ListOfFlapjack on lof
(define (flapjacks-in-skillet lof sl)
  (cond [(empty? lof) empty]
        [(> (+ (sqrt (+ (sqr (- (flapjack-x (first lof)) (skillet-x sl)))
                        (sqr (- (flapjack-y (first lof)) (skillet-y sl)))))
               (flapjack-radius (first lof)))
            (skillet-radius sl))
         (flapjacks-in-skillet (rest lof) sl)]
        [else (cons (first lof) (flapjacks-in-skillet (rest lof) sl))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TESTS

(begin-for-test
  ;; overlapping-check-helper
  (check-equal? (overlapping-check-helper
                 (make-flapjack -10 2 5)
                 (list (make-flapjack -10 2 5)
                       (make-flapjack -3 0 4)
                       (make-flapjack 4 -2 4.6)
                       (make-flapjack 7.2 6 5)
                       (make-flapjack 20 4 4.2)))
                (list (make-flapjack -10 2 5)
                      (make-flapjack -3 0 4)))

  ;; overlapping-flapjacks-helper
  (check-equal? (overlapping-flapjacks-helper
                 (list (make-flapjack -10 2 5)
                       (make-flapjack 20 4 4.2))
                 (list (make-flapjack -10 2 5)
                       (make-flapjack -3 0 4)
                       (make-flapjack 4 -2 4.6)
                       (make-flapjack 7.2 6 5)
                       (make-flapjack 20 4 4.2)))
                (list
                 (list (make-flapjack -10 2 5)
                       (make-flapjack -3 0 4))
                 (list (make-flapjack 20 4 4.2))))

  ;; overlapping-flapjacks
  (check-equal? (overlapping-flapjacks empty) empty)
  (check-equal? (overlapping-flapjacks (list (make-flapjack -10 2 5)
                                             (make-flapjack -3 0 4)
                                             (make-flapjack 4 -2 4.6)
                                             (make-flapjack 7.2 6 5)
                                             (make-flapjack 20 4 4.2)))
                (list (list (make-flapjack -10 2 5)
                            (make-flapjack -3 0 4))
                      (list (make-flapjack -10 2 5)
                            (make-flapjack -3 0 4)
                            (make-flapjack 4 -2 4.6))
                      (list (make-flapjack -3 0 4)
                            (make-flapjack 4 -2 4.6)
                            (make-flapjack 7.2 6 5))
                      (list (make-flapjack 4 -2 4.6)
                            (make-flapjack 7.2 6 5))
                      (list (make-flapjack 20 4 4.2))))

  ;; non-overlapping-falpjacks-helper
  (check-equal? (non-overlapping-flapjacks-helper
                 (list (make-flapjack -10 2 5)
                       (make-flapjack 20 4 4.2))
                 (list (make-flapjack -10 2 5)
                       (make-flapjack -3 0 4)
                       (make-flapjack 4 -2 4.6)
                       (make-flapjack 7.2 6 5)
                       (make-flapjack 20 4 4.2)))
                (list (make-flapjack  20  4 4.2)))

  ;; non-overlapping-flapjacks
  (check-equal? (non-overlapping-flapjacks empty) empty)
  (check-equal? (non-overlapping-flapjacks (list (make-flapjack -10 2 5)
                                                 (make-flapjack -3 0 4)
                                                 (make-flapjack 4 -2 4.6)
                                                 (make-flapjack 7.2 6 5)
                                                 (make-flapjack 20 4 4.2)))
                (list (make-flapjack  20  4 4.2)))

  ;; flapjacks-in-skillet
  (check-equal? (flapjacks-in-skillet (list (make-flapjack -10 2 5)
                                            (make-flapjack -3 0 4)
                                            (make-flapjack 4 -2 4.6)
                                            (make-flapjack 7.2 6 5)
                                            (make-flapjack 20 4 4.2))
                                      (make-skillet 2 3 12))
                (list (make-flapjack -3 0 4)
                      (make-flapjack 4 -2 4.6)
                      (make-flapjack 7.2 6 5))))