;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
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
;;   HALTING MEASURE: length of lof
#|
(define (lof-fn lof)
  (cond [(empty? lof) ...]
        [else (... (flapjack-fn (first lof))
                   (lof-fn (rest lof)))]))
|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; FUNCTIONS

;; squared-distance-between-points : Posn Posn -> PosReal
;; GIVEN: two Posn
;; RETURNS: the square of distance between the two Posn
;; EXAMPLES:
;;   (squared-distance-between-points
;;    (make-posn 1 1)
;;    (make-posn 5 4)) => 25
;; STRATEGY: Combine simpler functions
(define (squared-distance-between-points posn1 posn2)
  (+ (sqr (- (posn-x posn2) (posn-x posn1)))
     (sqr (- (posn-y posn2) (posn-y posn1)))))

;; overlapping-flapjack-check : Flapjack ListOfFlapjack -> ListOfFlapjack
;; GIVEN: a flapjack and a list of flapjacks
;; RETURNS: a list of flapjacks that overlap with the flapjack in the input
;; EXAMPLE:
;;   (overlapping-flapjack-check
;;    (make-flapjack -10 2 5)
;;    (list (make-flapjack -10 2 5)
;;          (make-flapjack -3 0 4)
;;          (make-flapjack 4 -2 4.6)
;;          (make-flapjack 7.2 6 5)
;;          (make-flapjack 20 4 4.2))) =
;;     (list (make-flapjack -10 2 5)
;;           (make-flapjack -3 0 4))
;; STRATEGY: Use HOF filter of lof
(define (overlapping-flapjack-check fj lof)
  (filter
   ;; Flapjack -> Boolean
   ;; Given: a Flapjack
   ;; RETURNS: a true if the Flapjack overlaps with Flapjack from other list
   ;;   of Flapjack
   (lambda (ifj)
     (<= (squared-distance-between-points
          (make-posn (flapjack-x fj) (flapjack-y fj))
          (make-posn (flapjack-x ifj) (flapjack-y ifj)))
         (sqr (+ (flapjack-radius ifj) (flapjack-radius fj)))))
   lof))

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
;; STRATEGY: use HOF map on lof
(define (overlapping-flapjacks lof)
  (map
   ;; Flapjack -> ListOfFlapjack
   ;; Given: a Flapjack
   ;; RETURNS: a ListOfFlapjack that overlaps with the given Flapjack
   (lambda (fj) (overlapping-flapjack-check fj lof))
   lof))

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
;; STRATEGY: use HOF filter on lof
(define (non-overlapping-flapjacks lof)
  (filter
   ;; Flapjack -> Boolean
   ;; Given: a Flapjack
   ;; RETURNS: a true if the Flapjack overlaps with no other Flapjack from 
   ;;   other list of Flapjack
   (lambda (fj) (= (length (overlapping-flapjack-check fj lof)) 1))
   lof))

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
;; STRATEGY: use HOF filter on lof
(define (flapjacks-in-skillet lof sl)
  (filter
   ;; Flapjack -> Boolean
   ;; Given: a Flapjack
   ;; RETURNS: a true if the Flapjack can fit entirely within the Skillet
   (lambda (fj) (<= (+ (sqrt
                        (squared-distance-between-points
                         (make-posn (skillet-x sl) (skillet-y sl))
                         (make-posn (flapjack-x fj) (flapjack-y fj))))
                       (flapjack-radius fj))
                    (skillet-radius sl)))
   lof))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TESTS

(begin-for-test

  ;; squared-distance-between-points
  (check-equal? (squared-distance-between-points
                 (make-posn 1 1)
                 (make-posn 5 4))
                25
                "Wrong computation of distance between 2 Posn")

  ;; overlapping-flapjack-check
  (check-equal? (overlapping-flapjack-check
                 (make-flapjack -10 2 5)
                 (list (make-flapjack -10 2 5)
                       (make-flapjack -3 0 4)
                       (make-flapjack 4 -2 4.6)
                       (make-flapjack 7.2 6 5)
                       (make-flapjack 20 4 4.2)))
                (list (make-flapjack -10 2 5)
                      (make-flapjack -3 0 4))
                "Irrelavent Overlapping Flapjack list returned")

  ;; overlapping-flapjacks
  (check-equal? (overlapping-flapjacks empty)
                empty
                "Non empty list returned on empty list check")
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
                      (list (make-flapjack 20 4 4.2)))
                "Wrong overlapping-flapjacks returned on overlap check")

  ;; non-overlapping-flapjacks
  (check-equal? (non-overlapping-flapjacks empty)
                empty
                "Non empty list returned on non-overlapping-flapjack check")
  (check-equal? (non-overlapping-flapjacks (list (make-flapjack -10 2 5)
                                                 (make-flapjack -3 0 4)
                                                 (make-flapjack 4 -2 4.6)
                                                 (make-flapjack 7.2 6 5)
                                                 (make-flapjack 20 4 4.2)))
                (list (make-flapjack  20  4 4.2))
                "wrong non-overlapping-flapjacks returned on non-overlap check")

  ;; flapjacks-in-skillet
  (check-equal? (flapjacks-in-skillet (list (make-flapjack -10 2 5)
                                            (make-flapjack -3 0 4)
                                            (make-flapjack 4 -2 4.6)
                                            (make-flapjack 7.2 6 5)
                                            (make-flapjack 20 4 4.2))
                                      (make-skillet 2 3 12))
                (list (make-flapjack -3 0 4)
                      (make-flapjack 4 -2 4.6)
                      (make-flapjack 7.2 6 5))
                "Improper results returned on Flapjack in Skillet check"))