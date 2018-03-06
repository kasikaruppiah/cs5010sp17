;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require "extras.rkt")
(require rackunit)

(provide initial-state
         next-state
         accepting-state?
         rejecting-state?)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; DATA DEFINITIONS

;; A LegalInput is one of
;;   -- "d"
;;   -- "p"
;;   -- "s"
;;   -- "e"
;; Interpretation: self-evident
;; TEMPLATE:
;;   legalinput-fn : LegalInput -> ??
#|
(define (legalinput-fn li)
  (cond [(string=? li "d") ...]
        [(string=? li "p") ...]
        [(string=? li "s") ...]
        [(string=? li "e") ...]))
|#

;; A State is one of
;;   -- "initial-state"
;;   -- "state-d"
;;   -- "state-p"
;;   -- "state-s"
;;   -- "state-e"
;;   -- "error-state"
;; Interpretation:
;;   "initial-state" - accepts one of "d", "p" or "s" as input
;;     to move to the next non error-state
;;   "state-d" - accepts one of "d", "p" or "e" as input to
;;     move to the next non error-state
;;   "state-p" - accepts only "d" as input to move to the next non error-state
;;   "state-s" - accepts one of "d" or "p" as input to
;;     move to the next non error-state
;;   "state-e" - any input moves to an error-state
;;   "error-state" - any input moves retains it in an error-state and also
;;     any invalid input on any other state moves it error-state
;; TEMPLATE:
;;   state-fn : State -> ??
#|
(define (state-fn state)
  (cond [(string=? state "initial-state") ...]
        [(string=? state "state-d") ...]
        [(string=? state "state-p") ...]
        [(string=? state "state-s") ...]
        [(string=? state "state-e") ...]
        [(string=? state "error-state") ...]))
|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; CONSTANTS

(define IS "initial-state")
(define SD "state-d")
(define SP "state-p")
(define SS "state-s")
(define SE "state-e")
(define ES "error-state")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; FUNCTIONS

;; initial-state : Number -> State
;; GIVEN: a number
;; RETURNS: a representation of the initial state
;;   of your machine.  The given number is ignored.
;; EXAMPLES:
;;   (initial-state 5) = IS
;;   (initial-state 42) = IS
;; STRATEGY: Use state
(define (initial-state num)
  IS)

;; next-state : State LegalInput -> State
;; GIVEN: a state of the machine and a machine input
;; RETURNS: the state the machine should enter if it
;;   is in the given state and sees the given input.
;; EXAMPLES:
;;   (next-state (initial-state 5) "d") = SD
;;   (next-state (initial-state 42) "e") = ES
;; STRATEGY: Use template for LegalInput on State
(define (next-state state li)
  (cond [(string=? state IS)
         (cond [(string=? li "d") SD]
               [(string=? li "p") SP]
               [(string=? li "s") SS]
               [else ES])]
        [(string=? state SD)
         (cond [(string=? li "d") SD]
               [(string=? li "p") SP]
               [(string=? li "e") SE]
               [else ES])]
        [(string=? state SP)
         (if (string=? li "d") SD ES)]
        [(string=? state SS)
         (cond [(string=? li "d") SD]
               [(string=? li "p") SP]
               [else ES])]
        [else ES]))

;; accepting-state? : State -> Boolean
;; GIVEN: a state of the machine
;; RETURNS: true iff the given state is a final (accepting) state
;; EXAMPLES:
;;   (accepting-state? (next-state (initial-state 5) "d")) = true
;;   (accepting-state? (next-state (initial-state 5) "s")) = false
;; STRATEGY: Use template for LegalInput on State
(define (accepting-state? state)
  (if (or (string=? state SD)
          (string=? state SE))
      true
      false))

;; rejecting-state? : State -> Boolean
;; GIVEN: a state of the machine
;; RETURNS: true iff there is no path (empty or non-empty) from
;;   the given state to an accepting state
;; EXAMPLES:
;;   (rejecting-state? (next-state (initial-state 5) "d")) = false
;;   (rejecting-state? (next-state (initial-state 5) "e")) = true
;; STRATEGY: Use template for LegalInput on State
(define (rejecting-state? state)
  (if (string=? state ES) true false))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TESTS

;; EXAMPLES
(begin-for-test
  (check-equal? (initial-state 5) IS)
  (check-equal? (initial-state 42) IS)
  (check-equal? (next-state (initial-state 5) "d") SD)
  (check-equal? (next-state (initial-state 42) "e") ES)
  (check-equal? (accepting-state? (next-state (initial-state 5) "d")) true)
  (check-equal? (accepting-state? (next-state (initial-state 5) "s")) false)
  (check-equal? (rejecting-state? (next-state (initial-state 5) "d")) false)
  (check-equal? (rejecting-state? (next-state (initial-state 6) "e")) true))

;; ADDITIONAL
(begin-for-test
  (check-equal? (next-state (initial-state 5) "p") SP)
  (check-equal? (next-state (initial-state 5) "s") SS)
  (check-equal? (next-state SD "d") SD)
  (check-equal? (next-state SD "p") SP)
  (check-equal? (next-state SD "e") SE)
  (check-equal? (next-state SD "s") ES)
  (check-equal? (next-state SP "d") SD)
  (check-equal? (next-state SP "e") ES)
  (check-equal? (next-state SS "d") SD)
  (check-equal? (next-state SS "p") SP)
  (check-equal? (next-state SS "e") ES)
  (check-equal? (next-state SE "e") ES)
  (check-equal? (next-state ES "d") ES)
  (check-equal? (accepting-state? (next-state SD "e")) true))