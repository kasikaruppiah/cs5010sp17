;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")

(provide string-last)

;; string-last : String -> String
;; GIVEN: a non-empty string
;; RETURNS: the last 1String
;; EXAMPLE:
;; (string-last "Hello Shifu!") = "!"
;; (string-last "DrRacket") = "t"
;; STATERGY: combine simpler functions
(define (string-last str)
  (string-ith str (- (string-length str) 1)))

(begin-for-test
  (check-equal? (string-last "Hello Shifu!") "!")
  (check-equal? (string-last "DrRacket") "t"))