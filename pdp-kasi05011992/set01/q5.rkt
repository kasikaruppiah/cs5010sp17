;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname q5) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")

(provide string-remove-last)

;; string-remove-last : String -> String
;; GIVEN: a string
;; RETURNS: a string similar to the given string with the last character removed
;; EXAMPLE:
;; (string-remove-last "Hello World!") = "Hello World"
;; (string-insert "Pink") = "Pin"
;; STATERGY: combine simpler functions
(define (string-remove-last str)
  (if (> (string-length str) 0)
      (substring str 0 (- (string-length str) 1))
      str))

(begin-for-test
  (check-equal? (string-remove-last "Hello World!") "Hello World")
  (check-equal? (string-remove-last "Pink") "Pin")
  (check-equal? (string-remove-last "") ""))