;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")

(provide cvolume)
(provide csurface)

;; cvolume : PosReal -> PosReal
;; GIVEN: the length of a side of an equilateral cube
;; RETURNS: its volume
;; EXAMPLE:
;; (cvolume 2) = 8
;; (cvolume 3) = 27
;; STATERGY: combine simpler functions
(define (cvolume len)
  (expt len 3))

(begin-for-test
  (check-equal? (cvolume 2) 8)
  (check-equal? (cvolume 3) 27))

;; csurface : PosReal -> PosReal
;; GIVEN: the length of a side of an equilateral cube
;; RETURNS: its surface area
;; EXAMPLE:
;; (csurface 2) = 24
;; (csurface 3) = 54
;; STATERGY: combine simpler functions
(define (csurface len)
  (* 6 (sqr len)))

(begin-for-test
  (check-equal? (csurface 2) 24)
  (check-equal? (csurface 3) 54))