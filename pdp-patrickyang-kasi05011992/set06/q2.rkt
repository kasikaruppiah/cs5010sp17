;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require "extras.rkt")
(require rackunit)

(require "flight.rkt")

(provide can-get-there?
         fastest-itinerary
         travel-time)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; DATA DEFINITIONS

;; A list of list of Flight (ListOfListOfFlight) is either
;;   -- empty
;;   -- (cons ListOfFlight ListOfListOfFlight)
;; TEMPLATE:
;;   loflof-fn : ListOfListOfFlight -> ??
;;   HALTING MEASURE: length of lolof
#;
(define (lolof-fn lolof)
  (cond [(empty? lolof) ...]
        [else (...
               (lof-fn (first lolof))
               (lolof-fn (rest lolof)))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CONSTANTS

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

(define testFlights
  (let ((u make-UTC)) ; so u can abbreviate make-UTC
    (list
     (make-flight "Delta 0121" "LGA" "MSP" (u 11 00) (u 14 09))
     (make-flight "Delta 2163" "MSP" "PDX" (u 15 00) (u 19 02))
     (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
     (make-flight "Delta 5703" "DEN" "LAX" (u 14 04) (u 17 15))
     (make-flight "Delta 2077" "LAX" "PDX" (u 17 35) (u 20 09)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; FUNCTIONS

;;; can-get-there? : String String ListOfFlight -> Boolean
;;; GIVEN: the names of two airports, ap1 and ap2 (respectively),
;;;     and a ListOfFlight that describes all of the flights a
;;;     traveller is willing to consider taking
;;; WHERE: there are no non-trivial round trips
;;;     (Once you depart from an airport, you can't get back to it.)
;;; RETURNS: true if and only if it is possible to fly from the
;;;     first airport (ap1) to the second airport (ap2) using
;;;     only the given flights
;;; EXAMPLES:
;;;     (can-get-there? "06N" "JFK" panAmFlights)  =>  false
;;;     (can-get-there? "JFK" "JFK" panAmFlights)  =>  true
;;;     (can-get-there? "06N" "LAX" deltaFlights)  =>  false
;;;     (can-get-there? "LAX" "06N" deltaFlights)  =>  false
;;;     (can-get-there? "LGA" "PDX" deltaFlights)  =>  true
;;; STRATEGY: Combine simpler functions
(define (can-get-there? ap1 ap2 lof)
  (or (string=? ap1 ap2) (not (empty? (all-itineraries ap1 ap2 lof '())))))

;;; TESTS:
(begin-for-test
  (check-equal? (can-get-there? "06N" "JFK" panAmFlights) false
                "can get there should be false on empty ListOfFlight")
  (check-equal? (can-get-there? "JFK" "JFK" panAmFlights) true
                "can get there should return true for same airports")
  (check-equal? (can-get-there? "06N" "LAX" deltaFlights) false
                "mis-match in can get there on deltaFlights")
  (check-equal? (can-get-there? "LAX" "06N" deltaFlights) false
                "mis-match in can get there on deltaFlights")
  (check-equal? (can-get-there? "LGA" "PDX" deltaFlights) true
                "mis-match in can get there on deltaFlights"))

;;; all-itineraries : String String ListOfFlight ListOfFlight
;;;     -> ListOfListOfFlight
;;; GIVEN: the names of the two airports, ap1 and ap2 (respectively),
;;;     a ListOfFlight that describes all of the flights a traveller is willing
;;;     to consider taking and a ListOfFlight that describes the ListOfFlights a
;;;     traveller has already taken
;;; RETURNS: a ListOfListOfFlight that describes how a traveller could fly from
;;;     first airport (ap1) to the second airport (ap2)
;;; EXAMPLES:
;;;     (all-itineraries "PDX" "LGA" deltaFlights '())  =>  empty
;;;     (all-itineraries "LGA" "PDX" deltaFlights '())
;;;       =>  (list
;;;            (list
;;;             (make-flight "Delta 0121" "LGA" "MSP"
;;;                          (make-UTC 11 0) (make-UTC 14 9))
;;;             (make-flight "Delta 1609" "MSP" "DEN"
;;;                          (make-UTC 20 35) (make-UTC 22 52))
;;;             (make-flight "Delta 5703" "DEN" "LAX"
;;;                          (make-UTC 14 4) (make-UTC 17 15))
;;;             (make-flight "Delta 2077" "LAX" "PDX"
;;;                          (make-UTC 17 35) (make-UTC 20 9)))
;;;            (list
;;;             (make-flight "Delta 0121" "LGA" "MSP"
;;;                          (make-UTC 11 0) (make-UTC 14 9))
;;;             (make-flight "Delta 2163" "MSP" "PDX"
;;;                          (make-UTC 15 0) (make-UTC 19 2))))
;;; STRATEGY: Divide into cases on (flights-from-ap ap1 lof) and
;;;     Use template for Flight on rlof
;;; HALTING MEASURE: length of rlof
(define (all-itineraries ap1 ap2 lof tlof)
  (let ((rlof (flights-from-ap ap1 lof)))
    (cond [(empty? rlof) '()]
          [(string=? ap2 (arrives (first rlof)))
           (add-itinerary ap1 ap2 lof tlof rlof)]
          [else (other-itineraries ap1 ap2 lof tlof rlof)])))

;;; TESTS:
(begin-for-test
  (check-equal? (all-itineraries "PDX" "LGA" deltaFlights '()) empty
                "all itineraries on empty ListOfFlight should be empty")
  (check-equal?
   (all-itineraries "LGA" "PDX" deltaFlights '())
   (list
    (list
     (make-flight "Delta 0121" "LGA" "MSP" (make-UTC 11 0) (make-UTC 14 9))
     (make-flight "Delta 1609" "MSP" "DEN" (make-UTC 20 35) (make-UTC 22 52))
     (make-flight "Delta 5703" "DEN" "LAX" (make-UTC 14 4) (make-UTC 17 15))
     (make-flight "Delta 2077" "LAX" "PDX" (make-UTC 17 35) (make-UTC 20 9)))
    (list
     (make-flight "Delta 0121" "LGA" "MSP" (make-UTC 11 0) (make-UTC 14 9))
     (make-flight "Delta 2163" "MSP" "PDX" (make-UTC 15 0) (make-UTC 19 2))))
   "mis-match on all itineraries from LGA to PDX on deltaFlights")
  (check-equal?
   (all-itineraries "LGA" "DEN" deltaFlights '())
   (list
    (list
     (make-flight "Delta 0121" "LGA" "MSP" (make-UTC 11 0) (make-UTC 14 9))
     (make-flight "Delta 1609" "MSP" "DEN" (make-UTC 20 35) (make-UTC 22 52))))
   "mis-match on all itineraries from LGA to DEN on deltaFlights"))

;;; flights-from-ap : String ListOfFlight -> ListOfFlight
;;; GIVEN: the name of an airport and a ListOfFlight that describes all of the
;;;     flights a traveller is willing to consider taking
;;; RETURNS: a ListOfFlight departing from the given airport
;;; EXAMPLES:
;;;     (flights-from-ap "LGA" panAmFlights)  =>  empty
;;;     (flights-from-ap "MSP" deltaFlights)
;;;       =>  (let ((u make-UTC))
;;;             (list
;;;              (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
;;;              (make-flight "Delta 2163" "MSP" "PDX" (u 15 00) (u 19 02))))
;;; STRATEGY: using HOF filter on lof
(define (flights-from-ap ap lof)
  (filter
   ;;; Flight -> Boolean
   ;;; GIVEN: a Flight
   ;;; RETURNS: true if flight departs from the same airport given as input to
   ;;;     flights-from-ap
   (λ (flt) (string=? ap (departs flt)))
   lof))

;;; TESTS:
(begin-for-test
  (check-equal? (flights-from-ap "LGA" panAmFlights) empty
                "Fligths from airport in empty ListOfFlight should be empty")
  (check-equal? (flights-from-ap "MSP" deltaFlights)
                (let ((u make-UTC))
                  (list
                   (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
                   (make-flight "Delta 2163" "MSP" "PDX" (u 15 00) (u 19 02))))
                "mis-match in flights from airport in deltaFlights"))

;;; add-itinerary : String String ListOfFlight ListOfFlight ListOfFlight
;;;     -> ListOfListOfFlight
;;; GIVEN: the names of the two airports, ap1 and ap2 (respectively),
;;;     a ListOfFlight that describes all of the flights a traveller is willing
;;;     to consider taking, a ListOfFlight that describes the ListOfFlights a
;;;     traveller has already taken and a ListOfFlight departing from the
;;;     first airport (ap1)
;;; RETURNS: a ListOfListOfFlight that describes how a traveller could fly from
;;;     first airport (ap1) to the second airport (ap2)
;;; STRATEGY: Use template for ListOfFlight on rlof
;;; HALTING MEASURE: length of rlof
(define (add-itinerary ap1 ap2 lof tlof rlof)
  (append (list (append tlof (list (first rlof))))
          (find-other-itineraries ap1 ap2 lof tlof (rest rlof))))

;;; find-other-itineraries : String String ListOfFlight ListOfFlight
;;;     ListOfFlight -> ListOfListOfFlight
;;; GIVEN: the names of an airport, a ListOfFlight that describes all of the
;;;     flights a traveller is willing to consider taking, a ListOfFlight that
;;;     describes the ListOfFlights a traveller has already taken and a
;;;     ListOfFlight departing from the first airport
;;; RETURNS: a ListOfListOfFlight that describes how a traveller could fly from
;;;     first airport (ap1) to the second airport (ap2)
;;; STRATEGY: Use template for ListOfFlight on rlof
;;; HALTING MEASURE: length of rlof
(define (find-other-itineraries ap1 ap2 lof tlof rlof)
  (cond [(empty? rlof) '()]
        [(string=? ap2 (arrives (first rlof)))
         (add-itinerary ap1 ap2 lof tlof rlof)]
        [else
         (other-itineraries ap1 ap2 lof tlof rlof)]))

;;; other-itineraries : String String ListOfFlight ListOfFlight ListOfFlight
;;;     -> ListOfListOfFlight
;;; GIVEN: the names of an airport, a ListOfFlight that describes all of the
;;;     flights a traveller is willing to consider taking, a ListOfFlight that
;;;     describes the ListOfFlights a traveller has already taken and a
;;;     ListOfFlight departing from the first airport
;;; RETURNS: a ListOfListOfFlight that describes how a traveller could fly from
;;;     first airport (ap1) to the second airport (ap2)
;;; STRATEGY: Use template for ListOfFlight on rlof
;;; HALTING MEASURE: length of rlof
(define (other-itineraries ap1 ap2 lof tlof rlof)
  (append (all-itineraries (arrives (first rlof)) ap2 lof
                           (append tlof (list (first rlof))))
          (find-other-itineraries ap1 ap2 lof tlof (rest rlof))))

;;; fastest-itinerary : String String ListOfFlight -> ListOfFlight
;;; GIVEN: the names of two airports, ap1 and ap2 (respectively),
;;;     and a ListOfFlight that describes all of the flights a
;;;     traveller is willing to consider taking
;;; WHERE: there are no non-trivial round trips, and
;;;     it is possible to fly from the first airport (ap1) to
;;;     the second airport (ap2) using only the given flights
;;; RETURNS: a list of flights that tells how to fly from the
;;;     first airport (ap1) to the second airport (ap2) in the
;;;     least possible time, using only the given flights
;;; NOTE: to simplify the problem, your program should incorporate
;;;     the totally unrealistic simplification that no layover
;;;     time is necessary, so it is possible to arrive at 1500
;;;     and leave immediately on a different flight that departs
;;;     at 1500
;;; EXAMPLES:
;;;     (fastest-itinerary "JFK" "JFK" panAmFlights)  =>  empty
;;;     (fastest-itinerary "LGA" "PDX" deltaFlights)
;;;       =>  (list (make-flight "Delta 0121"
;;;                              "LGA" "MSP"
;;;                              (make-UTC 11 00) (make-UTC 14 09))
;;;                 (make-flight "Delta 2163"
;;;                              "MSP" "PDX"
;;;                              (make-UTC 15 00) (make-UTC 19 02)))
;;; STRATEGY: Combine simpler functions
(define (fastest-itinerary ap1 ap2 lof)
  (let ((t (travel-time ap1 ap2 lof)))
    (if (> t 0)
        (first (find-fastest-itineraries t (all-itineraries ap1 ap2 lof '())))
        '())))

;;; TESTS:
(begin-for-test
  (check-equal? (fastest-itinerary "JFK" "JFK" panAmFlights) empty
                "fastest itinerary between two airports in empty ListOfFlight
should be empty")
  (check-equal? (fastest-itinerary "LGA" "PDX" deltaFlights)
                (list (make-flight "Delta 0121"
                                   "LGA" "MSP"
                                   (make-UTC 11 00) (make-UTC 14 09))
                      (make-flight "Delta 2163"
                                   "MSP" "PDX"
                                   (make-UTC 15 00) (make-UTC 19 02)))
                "mis-match in fastest itinerary between two airports in
deltaFlights"))

;;; find-fastest-itineraries : NonNegInt ListOfListOfFlight
;;;     -> ListOfListOfFlight
;;; GIVEN: the fastest travel time and a ListOfListOfFlight
;;; RETURNS: A ListOfListOfFlight within the ListOfListOfFlight matching
;;;     the fastest travel time
;;; EXAMPLE:
;;;     (find-fastest-itineraries "LGA" "PDX" deltaFlights)
;;;       =>  (list (list (make-flight "Delta 0121"
;;;                                    "LGA" "MSP"
;;;                                    (make-UTC 11 00) (make-UTC 14 09))
;;;                       (make-flight "Delta 2163"
;;;                                    "MSP" "PDX"
;;;                                    (make-UTC 15 00) (make-UTC 19 02)))
;;; STRATEGY: use HOF filter on lolof
(define (find-fastest-itineraries t lolof)
  (filter
   ;;; ListOfFlight -> Boolean
   ;;; GIVEN: a ListofFlight
   ;;; RETURNS: true if the travel-time of ListOfFlight is equal to fastest
   ;;;     travel travel given as input to find-fastest-itineraries
   (λ (lof) (= (total-travel-time lof) t))
   lolof))

;;; TEST:
(begin-for-test
  (check-equal? (find-fastest-itineraries 482 (all-itineraries
                                               "LGA" "PDX" deltaFlights '()))
                (list (list (make-flight "Delta 0121"
                                         "LGA" "MSP"
                                         (make-UTC 11 00) (make-UTC 14 09))
                            (make-flight "Delta 2163"
                                         "MSP" "PDX"
                                         (make-UTC 15 00) (make-UTC 19 02))))
                "mis-match in fastest itinerary between two airports in
deltaFlights"))

;;; travel-time : String String ListOfFlight -> NonNegInt
;;; GIVEN: the names of two airports, ap1 and ap2 (respectively),
;;;     and a ListOfFlight that describes all of the flights a
;;;     traveller is willing to consider taking
;;; WHERE: there are no non-trivial round trips, and
;;;     it is possible to fly from the first airport (ap1) to
;;;     the second airport (ap2) using only the given flights
;;; RETURNS: the number of minutes it takes to fly from the first
;;;     airport (ap1) to the second airport (ap2), including any
;;;     layovers, by the fastest possible route that uses only
;;;     the given flights
;;; EXAMPLES:
;;;     (travel-time "JFK" "JFK" panAmFlights)  =>  0
;;;     (travel-time "LGA" "PDX" deltaFlights)  =>  482
;;; STRATEGY: Use HOF foldr on (all-itineraries ap1 ap2 lof '())
(define (travel-time ap1 ap2 lof)
  (let ((lolof (all-itineraries ap1 ap2 lof '())))
    (cond [(empty? lolof) 0]
          [else
           (foldr
            ;;; ListOfFlight NonNegInt -> NonNegInt
            ;;; GIVEN: a ListofFlight and a NonNegInt
            ;;; RETURNS: the smaller between the flight-time and the number
            (λ (lof t)
              (let ((total-travel-time (total-travel-time lof)))
                (if (< t total-travel-time)
                    t
                    total-travel-time)))
            (total-travel-time (first lolof)) (rest lolof))])))

;;; TESTS:
(begin-for-test
  (check-equal? (travel-time "JFK" "JFK" panAmFlights) 0
                "travel time between same airports should be 0")
  (check-equal? (travel-time "LGA" "PDX" deltaFlights) 482
                "mis-match in travel time between two airports in deltaFlights")
  (check-equal? (travel-time "LGA" "PDX" testFlights) 482
                "mis-match in travel time between two airports in testFlights"))

;;; time-between : UTC UTC -> NonNegInt
;;; GIVEN: two UTC, utc1 and utc2 (respectively)
;;; WHERE: UTC1 is the earlier one
;;; RETURN: the time difference in minutes between the two UTC
;;; EXAMPLE:
;;;     (time-between (make-UTC 12 00) (make-UTC 12 00))  =>  1440
;;;     (time-between (make-UTC 12 10) (make-UTC 12 00))  =>  1430
;;;     (time-between (make-UTC 11 00) (make-UTC 12 00))  =>  60
;;; STRATEGY: Combine simpler functions
(define (time-between utc1 utc2)
  (+ (* 60 (- (if (or (> (UTC-hour utc1) (UTC-hour utc2))
                      (and (= (UTC-hour utc1) (UTC-hour utc2))
                           (>= (UTC-minute utc1) (UTC-minute utc2))))
                  (+ (UTC-hour utc2) 24)
                  (UTC-hour utc2))
              (UTC-hour utc1)))
     (- (UTC-minute utc2) (UTC-minute utc1))))

;;; TESTS:
(begin-for-test
  (check-equal? (time-between (make-UTC 12 00) (make-UTC 12 00)) 1440
                "time between two equal UTC should be 1440")
  (check-equal? (time-between (make-UTC 12 10) (make-UTC 12 00)) 1430
                "mis-match in time between two custom UTC with utc1 > utc2")
  (check-equal? (time-between (make-UTC 11 00) (make-UTC 12 00)) 60
                "mis-match in time between two custom UTC"))

;;; total-flight-time : ListOfFlight -> NonNegInt
;;; GIVEN: a ListofFlight
;;; RETURNS: the in-flight time in minutes taken to fly through ListOfFlight
;;; EXAMPLES:
;;;     (total-flight-time panAmFlights)  =>  0
;;;     (total-flight-time
;;;      (let ((u make-UTC))
;;;        (list
;;;         (make-flight "Delta 0121" "LGA" "MSP" (u 11 00) (u 14 09))
;;;         (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
;;;         (make-flight "Delta 5703" "DEN" "LAX" (u 14 04) (u 17 15)))))
;;;       =>  517
;;; STRATEGY: Use HOF foldr on lof
(define (total-flight-time lof)
  (foldr
   ;;; Flight -> NonNegInt
   ;;; GIVEN: a Flight and minutes
   ;;; RETURNS: the sum of the time spent on the Flight and minutes
   (λ (flt t) (+ (time-between (departs-at flt) (arrives-at flt)) t))
   0 lof))

;;; TESTS:
(begin-for-test
  (check-equal? (total-flight-time panAmFlights) 0
                "total flight time of empty ListOfFlight should be 0")
  (check-equal?
   (total-flight-time
    (let ((u make-UTC))
      (list
       (make-flight "Delta 0121" "LGA" "MSP" (u 11 00) (u 14 09))
       (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
       (make-flight "Delta 5703" "DEN" "LAX" (u 14 04) (u 17 15)))))
   517 "mis-match in total flight time of custom ListOfFlight"))

;;; total-layover-time : ListOfFlight ListOfFlight -> NonNegInt
;;; GIVEN: two ListofFlight, the first containing the ListOfFlight and the
;;;     second containing similar ListOfFlight as the first but after removing
;;;     the first element of the first ListOfFlight
;;; RETURNS: the number of layover minutes taken to fly through ListOfFlight
;;; EXAMPLES:
;;;     (total-layover-time panAmFlights)  =>  0
;;;     (total-layover-time
;;;      (let ((u make-UTC))
;;;        (list
;;;         (make-flight "Delta 0121" "LGA" "MSP" (u 11 00) (u 14 09))
;;;         (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
;;;         (make-flight "Delta 5703" "DEN" "LAX" (u 14 04) (u 17 15)))))
;;;       =>  
;;; STRATEGY: Use template of ListOfFlight on lof2
(define (total-layover-time lof1 lof2)
  (cond
    [(empty? lof2) 0]
    [else (+ (time-between (arrives-at (first lof1)) (departs-at (first lof2)))
             (total-layover-time (rest lof1) (rest lof2)))]))

;;; TESTS:
(begin-for-test
  (check-equal? (total-layover-time
                 (let ((u make-UTC))
                   (list
                    (make-flight "Delta 0121" "LGA" "MSP" (u 11 00) (u 14 09))))
                 '()) 0 "layover time of single flight should be 0")
  (check-equal?
   (total-layover-time
    (let ((u make-UTC))
      (list
       (make-flight "Delta 0121" "LGA" "MSP" (u 11 00) (u 14 09))
       (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
       (make-flight "Delta 5703" "DEN" "LAX" (u 14 04) (u 17 15))))
    (let ((u make-UTC))
      (list
       (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
       (make-flight "Delta 5703" "DEN" "LAX" (u 14 04) (u 17 15)))))
   1298 "mis-match in layover time for custom ListOfFlight"))

;;; total-travel-time : ListOfFlight -> NonNegInt
;;; GIVEN: a ListofFlight
;;; RETURNS: the total flight time in minutes taken to fly through ListOfFlight
;;; EXAMPLES:
;;;     (total-travel-time panAmFlights)  =>  0
;;;     (total-travel-time
;;;      (let ((u make-UTC))
;;;        (list
;;;         (make-flight "Delta 0121" "LGA" "MSP" (u 11 00) (u 14 09))
;;;         (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
;;;         (make-flight "Delta 5703" "DEN" "LAX" (u 14 04) (u 17 15)))))
;;;       =>  
;;; STRATEGY: Combine simpler functions
(define (total-travel-time lof)
  (+ (total-flight-time lof)
     (if (> (length lof) 1)
         (total-layover-time lof (rest lof))
         0)))

;;; TESTS:
(begin-for-test
  (check-equal? (total-travel-time panAmFlights) 0
                "total travel time of empty ListOfFlight should be 0")
  (check-equal?
   (total-travel-time
    (let ((u make-UTC))
      (list
       (make-flight "Delta 0121" "LGA" "MSP" (u 11 00) (u 14 09))
       (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
       (make-flight "Delta 5703" "DEN" "LAX" (u 14 04) (u 17 15)))))
   1815 "mis-match in total travel time for custom ListOfFlight"))