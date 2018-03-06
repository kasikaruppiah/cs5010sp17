;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname flight) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require "extras.rkt")
(require rackunit)

(provide make-UTC
         UTC-hour
         UTC-minute
         UTC=?
         make-flight
         flight-name
         departs
         arrives
         departs-at
         arrives-at
         flight=?)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; DATA DEFINITIONS

(define-struct UTC (hour minute))
;;; A UTC is a structure (make-UTC NonNegInt NonNegInt)
;;; Interpretation:
;;;     hour is the hour part of a time in UTC
;;;     minute is the minute part of a time in UTC
;;; TEMPLATE:
;;;     UTC-fn : UTC -> ??
#;
(define (UTC-fn utc)
  (...
   (UTC-hour utc)
   (UTC-minute utc)))

(define-struct flight (name departs arrives departs-at arrives-at))
;;; A Flight is a structure (make-flight String String String UTC UTC)
;;; Interpretation:
;;;     name is the name of the flight
;;;     departs is the name of the airport from which the flight departs
;;;     arrives is the name of the airport at which the flight arrives
;;;     departs-at is the time of departure in UTC
;;;     arrives-at is the time of departure in UTC
;;; TEMPLATE:
;;;     flight-fn : Flight -> ??
#;
(define (flight-fn flt)
  (...
   (flight-name flt)
   (flight-departs flt)
   (flight-arrives flt)
   (flight-departs-at flt)
   (flight-arrives-at flt)))

;;; A list of Flight (ListOfFlight) is either
;;;   -- empty
;;;   -- (cons Flight ListOfFlight)
;;; TEMPLATE:
;;;   lof-fn : ListOfFlight -> ??
;;;   HALTING MEASURE: length of lof
#;
(define (lof-fn lof)
  (cond [(empty? lof) ...]
        [else (...
               (flight-fn (first lof))
               (lof-fn (rest lof)))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CONSTANTS

(define flt1
  (make-flight "United 448"
               "BOS" "DEN"
               (make-UTC 20 03) (make-UTC 00 53)))

;;; Pan American is no longer flying.
(define panAmFlights '())

(define deltaFlights
  (let ((u make-UTC)) ; so u can abbreviate make-UTC
    (list
     (make-flight "Delta 0121" "LGA" "MSP" (u 11 00) (u 14 09))
     (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
     (make-flight "Delta 5703" "DEN" "LAX" (u 14 04) (u 17 15))
     (make-flight "Delta 2077" "LAX" "PDX" (u 17 35) (u 20 09))
     (make-flight "Delta 2163" "MSP" "PDX" (u 15 00) (u 19 02)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; FUNCTIONS

;;; UTC=? : UTC UTC -> Boolean
;;; GIVEN: two UTC times
;;; RETURNS: true iff they have the same hour and minute parts
;;; EXAMPLES:
;;;     (UTC=? (make-UTC 15 31) (make-UTC 15 31))  =>  true
;;;     (UTC=? (make-UTC 15 31) (make-UTC 14 31))  =>  false
;;;     (UTC=? (make-UTC 15 31) (make-UTC 15 32))  =>  false
;;; STRATEGY: Combine simpler functions
(define (UTC=? utc1 utc2)
  (equal? utc1 utc2))

;;; TESTS:
(begin-for-test
  (check-equal? (UTC=? (make-UTC 15 31) (make-UTC 15 31)) true
                "UTC with same hour and minute part should return true")
  (check-equal? (UTC=? (make-UTC 15 31) (make-UTC 14 31)) false
                "UTC with different hour and minute part should return false")
  (check-equal? (UTC=? (make-UTC 15 31) (make-UTC 15 32)) false
                "UTC with different hour and minute part should return false"))

;;; departs : Flight -> String
;;; GIVEN: a flight
;;; RETURNS: the name of the airport from which the flight departs
;;; EXAMPLE:
;;;     (departs flt1)  =>  "BOS"
;;; STRATEGY: Use template for Flight on flt
(define (departs flt)
  (flight-departs flt))

;;; TEST:
(begin-for-test
  (check-equal? (departs flt1) "BOS" "mis-match in flight-departs in flt1"))

;;; arrives : Flight -> String
;;; GIVEN: a flight
;;; RETURNS: the name of the airport at which the flight arrives
;;; EXAMPLE:
;;;     (arrives flt1)  =>  "DEN"
;;; STRATEGY: Use template for Flight on flt
(define (arrives flt)
  (flight-arrives flt))

;;; TEST:
(begin-for-test
  (check-equal? (arrives flt1) "DEN" "mis-match in flight-arrives in flt1"))

;;; departs-at : Flight -> UTC
;;; GIVEN: a flight
;;; RETURNS: the time (in UTC, see above) at which the flight departs
;;; EXAMPLE:
;;;     (departs-at flt1)  =>  (make-UTC 20 03)
;;; STRATEGY: Use template for Flight on flt
(define (departs-at flt)
  (flight-departs-at flt))

;;; TEST:
(begin-for-test
  (check-equal? (departs-at flt1) (make-UTC 20 03)
                "mis-match in departs-at UTC in flt1"))

;;; arrives-at : Flight -> UTC
;;; GIVEN: a flight
;;; RETURNS: the time (in UTC, see above) at which the flight arrives
;;; EXAMPLE:
;;;     (arrives-at flt1)  =>  (make-UTC 00 53)
;;; STRATEGY: Use template for Flight on flt
(define (arrives-at flt)
  (flight-arrives-at flt))

;;; TEST:
(begin-for-test
  (check-equal? (arrives-at flt1) (make-UTC 00 53)
                "mis-match in arrivess-at UTC in flt1"))

;;; flight=? : Flight Flight -> Boolean
;;; GIVEN: two flights
;;; RETURNS: true if and only if the two flights have the same
;;;     name, depart from the same airport, arrive at the same
;;;     airport, depart at the same time, and arrive at the same time
;;; EXAMPLES:
;;;     (flight=? flt1 flt1)  =>  true
;;;     (flight=? (make-flight "United 448"
;;;                            "BOS" "DEN"
;;;                            (make-UTC 20 00) (make-UTC 00 55))
;;;               flt1)
;;;       =>  false
;;; STRATEGY: Combine simpler functions
(define (flight=? flt1 flt2)
  (equal? flt1 flt2))

;;; TESTS:
(begin-for-test
  (check-equal? (flight=? flt1 flt1) true
                "Should return true when same flights are compared")
  (check-equal? (flight=? (make-flight "United 448" "BOS" "DEN"
                                       (make-UTC 20 00) (make-UTC 00 55))
                          flt1)
                false
                "Should return false when different flights are compared"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; TESTS:

(begin-for-test
  ;;; struct UTC
  (check-equal? (UTC-hour (make-UTC 15 31)) 15)
  (check-equal? (UTC-minute (make-UTC 15 31)) 31)
  
  ;;; struct flight
  (check-equal? (flight-name flt1) "United 448"))