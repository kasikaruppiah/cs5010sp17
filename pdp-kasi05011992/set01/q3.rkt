;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname q3) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")

(provide string-insert)

;; string-insert : String NonNegInt -> String
;; GIVEN: a string and a number
;; WHERE: (and (>= number 0) (<= number (string-length string)))
;; RETURNS: a string similar to the given string with "_" at ith position
;; EXAMPLE:
;; (string-insert "HelloWorld!" 5) = "Hello_World!"
;; (string-insert "Int" 3) = "Int_"
;; STATERGY: combine simpler functions
(define (string-insert str i)
  (string-append (substring str 0 i) "_" (substring str i)))

(begin-for-test
  (check-equal? (string-insert "HelloWorld!" 5) "Hello_World!")
  (check-equal? (string-insert "Int" 3) "Int_"))