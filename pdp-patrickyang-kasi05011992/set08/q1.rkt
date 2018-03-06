;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;;; Program to find if it's feasible to get from one airport to another
;;;     using the given list of flights and if so what's the fastest itinerary
;;;     and the travel time to get there

(require "extras.rkt")
(require rackunit)

(require "flight.rkt")

(provide can-get-there?
         fastest-itinerary
         travel-time)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; DATA DEFINITIONS

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

;;; A list of list of Flight (ListOfListOfFlight) is either
;;;   -- empty
;;;   -- (cons ListOfFlight ListOfListOfFlight)
;;; TEMPLATE:
;;;   loflof-fn : ListOfListOfFlight -> ??
;;;   HALTING MEASURE: length of lolof
#;
(define (lolof-fn lolof)
  (cond [(empty? lolof) ...]
        [else (...
               (lof-fn (first lolof))
               (lolof-fn (rest lolof)))]))

;;; A list of list of list of Flight (Table) is either 
;;;   -- empty
;;;   -- (cons ListOfListOfFlight Table)
;;; TEMPLATE:
;;;   table-fn : Table -> ??
;;;   HALTING MEASURE: length of table
#;
(define (table-fn table)
  (cond [(empty? table) ...]
        [else (...
               (lolof-fn (first lolof))
               (table-fn (rest lolof)))]))

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

(define cyclicFlights
  (let ((u make-UTC)) ; so u can abbreviate make-UTC
    (list
     (make-flight "Delta 0121" "LGA" "MSP" (u 11 00) (u 14 09))
     (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
     (make-flight "Delta 5703" "DEN" "LAX" (u 14 04) (u 17 15))
     (make-flight "Delta 2077" "LAX" "PDX" (u 17 35) (u 20 09))
     (make-flight "Delta 5705" "LAX" "MSP" (u 17 25) (u 20 15))
     (make-flight "Delta 2163" "MSP" "PDX" (u 15 00) (u 19 02)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; FUNCTIONS

;;; can-get-there? : String String ListOfFlight -> Boolean
;;; GIVEN: the names of two airports, ap1 and ap2 (respectively),
;;;     and a ListOfFlight that describes all of the flights a
;;;     traveller is willing to consider taking
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
  (let ((lolof (get-itineraries  ap1 ap2 lof)))
    (or (string=? ap1 ap2) (not (empty? lolof)))))

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

;;; sort-lof : String ListOfString ListOfFlight -> ListOfFlight
;;; GIVEN: The starting airport, a list of traveled airports, (initially empty)
;;;     and the ListofFlights that needed to be sorted
;;; RETURNS: A sorted lof that starting from the given airport, the sorting is
;;;     done in a BFS way.
;;; EXAMPLES:
;;;     (sort-lof "AP1" '() panAmFlights)  =>  '()
;;;     (sort-lof "LGA" '() deltaFlights)  =>
;;;     (let ((u make-UTC))
;;;      (list
;;;       (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
;;;       (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
;;;       (make-flight "Delta 2163" "MSP" "PDX" (u 15 0) (u 19 2))
;;;       (make-flight "Delta 5703" "DEN" "LAX" (u 14 4) (u 17 15))
;;;       (make-flight "Delta 2077" "LAX" "PDX" (u 17 35) (u 20 9)))
;;; STRATEGY: Combine simpler functions
;;; HALTING MEASURE: length of (lof-from-ap (flights-from-ap ap lof))
(define (sort-lof ap tloa lof)
  (let ((lof-from-ap (flights-from-ap ap lof))) 
    (append
     lof-from-ap
     (sort-res-lof (arrives-at-ap lof-from-ap) (append tloa (list ap)) lof))))

;;; TESTS:
(begin-for-test
  (check-equal? (lof=? (sort-lof "AP1" '() panAmFlights) '()) #t
                "sorting empty lof should return empty")
  (check-equal? (lof=?
                 (sort-lof "LGA" '() deltaFlights)
                 (let ((u make-UTC))
                   (list
                    (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
                    (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
                    (make-flight "Delta 2163" "MSP" "PDX" (u 15 0) (u 19 2))
                    (make-flight "Delta 5703" "DEN" "LAX" (u 14 4) (u 17 15))
                    (make-flight "Delta 2077" "LAX" "PDX" (u 17 35) (u 20 9)))))
                #t
                "mis-match in sorted flights list"))

;;; sort-res-lof : ListOfString ListOfString ListOfFlight -> ListOfFlight
;;; GIVEN: A list of airports, a List of traveled airports, (initially empty)
;;;        and the ListofFlight that needed to be sorted
;;; RETURNS: A sorted ListOfFlight, the sorting is done in a BFS way
;;; STRATEGY: Combine simpler functions
;;; HALTING MEASURE: length of loa
(define (sort-res-lof loa tloa lof)
  (cond [(empty? loa) '()]
        [(ap-inside-loa? tloa (first loa)) (sort-res-lof (rest loa) tloa lof)]
        [else
         (append
          (sort-lof (first loa) tloa lof)
          (sort-res-lof (rest loa) (append tloa (list (first loa))) lof))]))

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
;;; STRATEGY: Use HOF filter on lof
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
  (check-equal? (lof=? (flights-from-ap "LGA" panAmFlights) empty) true
                "Fligths from airport in empty ListOfFlight should be empty")
  (check-equal? (lof=?
                 (flights-from-ap "MSP" deltaFlights)
                 (let ((u make-UTC))
                   (list
                    (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
                    (make-flight "Delta 2163" "MSP" "PDX" (u 15 00) (u 19 02))))
                 ) true
                   "mis-match in flights from airport in deltaFlights"))

;;; arrives-at-ap: ListOfFlight -> ListOfString
;;; Given: A ListOfFlight
;;; RETURNS: A ListOfString that reprsents the list of airports that the
;;;     given lof is arriving at.
;;; EXAMPLE:
;;;     (arrives-at-ap deltaFlights) =>  (list "MSP" "DEN" "LAX" "PDX" "PDX")
;;; STRATEGY: Use HOF of map on lof
(define (arrives-at-ap lof)
  (map
   ;;; Flight -> Boolean
   ;;; GIVEN: a Flight
   ;;; RETURNS: a String that indicates the arrival city of the Flight
   (λ (flt) (arrives flt))
   lof))

;;; TEST:
(begin-for-test
  (check-equal? (arrives-at-ap deltaFlights)
                (list "MSP" "DEN" "LAX" "PDX" "PDX")
                "mis-match in the list of airports"))

;;; ap-inside-loa? : ListofString String -> Boolean
;;; GIVEN: A list of airports and a specific airport
;;; RETURNS: True if the airport is contained in the list
;;; EXAMPLES:
;;;     (ap-inside-loa? deltaFlights "LGA")  =>  #t
;;;     (ap-inside-loa? deltaFlights "A")  =>  #f
;;; STRATEGY: Use HOF ormap on loa
(define (ap-inside-loa? loa ap1)
  (ormap
   ;;; String -> Boolean
   ;;; Given: a String
   ;;; Return: True if the String is the same with the given one
   (λ (ap2) (string=? ap1 ap2))
   loa))

;;; TESTS:
(begin-for-test
  (check-equal? (ap-inside-loa? (all-airports deltaFlights) "LGA") #t
                "expecting true for perfect match")
  (check-equal? (ap-inside-loa? (all-airports deltaFlights) "AP1") #f
                "expecting false for custom airport"))

;;; get-empty-table: PosInt -> Table
;;; GIVEN: a Positive Interger
;;; RETURNS: An empty Table of the given length
;;; EXAMPLE:
;;;     (get-empty-table 5)  =>  (list '() '() '() '() '() '())
;;; STRATEGY: Combine simpler functions
;;; HALTING MEASURE: len
(define (get-empty-table len)
  (if (= len 0)
      '()
      (append (list '()) (get-empty-table (- len 1)))))

(begin-for-test
  (check-equal? (get-empty-table 5)
                (list '() '() '() '() '())
                "empty table mismatch"))

;;; check-flight-taken? : String LisfOfFlight -> Boolean
;;; GIVEN: a name of airport and a ListOfFlight
;;; RETURNS: true if the ListOfFlight doesn't contain a flight that departs from
;;;     the given airport
;;; EXAMPLES:
;;;     (check-flight-taken? "LGA" '())  =>  false
;;;     (check-flight-taken? "PDX"
;;;                          (let ((u make-UTC))
;;;                            (list
;;;                             (make-flight "Delta 1609" "MSP" "DEN"
;;;                                          (u 20 35) (u 22 52))
;;;                             (make-flight "Delta 2163" "MSP" "PDX"
;;;                                          (u 15 00) (u 19 02)))))  =>  true
;;; STRATEGY: Use HOF ormap on lof
(define (check-flight-taken? ap lof)
  (cond [(empty? lof) false]
        [else (ormap (lambda (f) (string=? ap (departs f))) lof)]))

;;; TESTS:
(begin-for-test
  (check-equal? (check-flight-taken? "LGA" '()) false)
  (check-equal? (check-flight-taken?
                 "MSP"
                 (let ((u make-UTC)) ; so u can abbreviate make-UTC
                   (list
                    (make-flight "Delta 0121" "LGA" "MSP"
                                 (u 11 00) (u 14 09))
                    (make-flight "Delta 1609" "MSP" "DEN"
                                 (u 20 35) (u 22 52))))) true))

;;; all-itineraries : ListOfFlight ListOfString Table -> Table
;;; GIVEN: a ListOfFlight that describes all of the flights a traveller is
;;;     willing to consider taking, a list of all airports served by some flight
;;;     in the given list and a Table with paths between airports from previous
;;;     iteration
;;; WHERE: the ListOfFlight are in sorted order with respect to the order of
;;;     airports from travellers starting point
;;; RETURNS: a Table with all fastest paths between airports using different
;;;     airports
;;; EXAMPLES:
;;;     (all-itineraries "PDX" "LGA" deltaFlights '())  =>
;;;     (get-empty-table (length (all-airports deltaFlights)))
;;;     (all-itineraries "LGA" "PDX" deltaFlights '())  =>
;;;     (list
;;;      (list
;;;       (make-flight "Delta 0121" "LGA" "MSP"
;;;                    (make-UTC 11 0) (make-UTC 14 9))
;;;       (make-flight "Delta 1609" "MSP" "DEN"
;;;                    (make-UTC 20 35) (make-UTC 22 52))
;;;       (make-flight "Delta 5703" "DEN" "LAX"
;;;                    (make-UTC 14 4) (make-UTC 17 15))
;;;       (make-flight "Delta 2077" "LAX" "PDX"
;;;                    (make-UTC 17 35) (make-UTC 20 9)))
;;;      (list
;;;       (make-flight "Delta 0121" "LGA" "MSP"
;;;                    (make-UTC 11 0) (make-UTC 14 9))
;;;       (make-flight "Delta 2163" "MSP" "PDX"
;;;                    (make-UTC 15 0) (make-UTC 19 2))))
;;; STRATEGY: Use template for ListOfFlight on sorted-lof
;;; HALTING MEASURE: length of sorted-lof
(define (all-itineraries sorted-lof loa table)
  (cond [(empty? sorted-lof) table]
        [else (all-itineraries
               (rest sorted-lof) loa
               (renew-table table
                            (create-new-table table loa (first sorted-lof))))]))

;;; TESTS:
(begin-for-test
  (check-equal?
   (table=? (all-itineraries
             (sort-lof "PDX" '() deltaFlights)
             (all-airports deltaFlights)
             (get-empty-table (length (all-airports deltaFlights))))
            (get-empty-table (length (all-airports deltaFlights))))
   true
   "all itineraries on empty ListOfFlight should be empty")
  (check-equal?
   (table=?
    (all-itineraries
     (sort-lof "LGA" '() deltaFlights)
     (all-airports deltaFlights)
     (get-empty-table (length (all-airports deltaFlights))))
    (let ((u make-UTC))
      (list
       (list
        (list
         (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
         (make-flight "Delta 2163" "MSP" "PDX" (u 15 0) (u 19 2)))
        (list
         (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
         (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
         (make-flight "Delta 5703" "DEN" "LAX" (u 14 4) (u 17 15))
         (make-flight "Delta 2077" "LAX" "PDX" (u 17 35) (u 20 9))))
       (list
        (list
         (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
         (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
         (make-flight "Delta 5703" "DEN" "LAX" (u 14 4) (u 17 15))))
       (list
        (list
         (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
         (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))))
       (list (list (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))))
       '())))
   true
   "mis-match on all itineraries from LGA to PDX on deltaFlights"))

;;; create-new-table : Table ListofString Flight -> Table
;;; GIVEN: An old Table, A list of airports and newly added Flight
;;; RETURNS: A new table with the flight added to the old one
;;; EXAMPLE:
;;;     (create-new-table (get-empty-table 5)
;;;                       (all-airports deltaFlights)
;;;                       (make-flight "newFlight" "LGA" "MSP"
;;;                                    (make-UTC 11 0) (make-UTC 14 9)))  =>
;;;     (list '() '() '() (list
;;;                        (list
;;;                         (make-flight "newFlight" "LGA" "MSP"
;;;                                      (make-UTC 11 0) (make-UTC 14 9)))))
;;;           '()))
;;; STRATEGY: Combine simpler functions
(define (create-new-table table loa flt)
  (let ((lolof (combine-itineraries
                (get-lolof table (find-index loa (departs flt) 0))
                flt))
        (index (find-index loa (arrives flt) 0))
        (len (length loa)))
    (append
     (get-empty-table index)
     (list lolof)
     (get-empty-table (- len index 1)))))

;;; TEST:
(begin-for-test
  (check-equal? (create-new-table (get-empty-table 5)
                                  (all-airports deltaFlights)
                                  (make-flight "newFlight" "LGA" "MSP"
                                               (make-UTC 11 0) (make-UTC 14 9)))
                (list '() '() '()
                      (list
                       (list
                        (make-flight "newFlight" "LGA" "MSP"
                                     (make-UTC 11 0) (make-UTC 14 9))))
                      '())
                "mis-match in create-new-table"))

;;; find-index : ListofString String -> Integer
;;; GIVEN: a list of airports and a specific airport
;;; RETURNS: the index where the given ap is located in loa
;;;          return -1 if the given ap is not in the list
;;; EXAMPLES:
;;;     (find-index (all-airports deltaFlights) "LGA" 0)  =>  4
;;;     (find-index (all-airports deltaFlights) "AP1" 0)  =>  -1
;;; STRATEGY: Divide into cases on loa 
(define (find-index loa ap num)
  (cond [(empty? loa) -1]
        [(string=? (first loa) ap) num]
        [else (find-index (rest loa) ap (+ num 1))]))

;;; TESTS:
(begin-for-test
  (check-equal? (find-index (all-airports deltaFlights) "LGA" 0) 4
                "incorrect index returned")
  (check-equal? (find-index (all-airports deltaFlights) "AP1" 0) -1
                "expecting -1 for an airport not present in the list"))

;;; get-lolof : Table Integer -> LisfOfListOfFlights
;;; GIVEN: A Table and an index
;;; WHERE: index is -1 or any positive integer
;;; RETURNS: the lolof that is in the position of given num
;;; EXAMPLES:
;;;     (get-lolof
;;;      (let ((u make-UTC))
;;;        (list
;;;         (list
;;;          (list
;;;           (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
;;;           (make-flight "Delta 2163" "MSP" "PDX" (u 15 0) (u 19 2)))
;;;          (list
;;;           (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
;;;           (make-flight "Delta 1609" "MSP" "DEN"
;;;                        (u 20 35) (u 22 52))
;;;           (make-flight "Delta 5703" "DEN" "LAX" (u 14 4) (u 17 15))
;;;           (make-flight "Delta 2077" "LAX" "PDX"
;;;                        (u 17 35) (u 20 9))))
;;;         (list
;;;          (list
;;;           (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
;;;           (make-flight "Delta 1609" "MSP" "DEN"
;;;                        (u 20 35) (u 22 52))
;;;           (make-flight "Delta 5703" "DEN" "LAX"
;;;                        (u 14 4) (u 17 15))))
;;;         (list
;;;          (list
;;;           (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
;;;           (make-flight "Delta 1609" "MSP" "DEN" (u 20 35)
;;;                        (u 22 52))))
;;;         (list
;;;          (list
;;;           (make-flight "Delta 0121" "LGA" "MSP"
;;;                        (u 11 0) (u 14 9))))
;;;         '()))
;;;      3)  =>
;;;     (list
;;;      (list
;;;       (make-flight "Delta 0121" "LGA" "MSP"
;;;                    (make-UTC 11 0) (make-UTC 14 9))))
;;;     (get-lolof
;;;      (list '() '() '()
;;;            (list
;;;             (list (make-flight "Delta 0121" "LGA" "MSP"
;;;                                (make-UTC 11 0) (make-UTC 14 9))))
;;;            '())
;;;      -1)  =>
;;;     '()
;;; STRATEGY: Combine simpler functions
(define (get-lolof table index)
  (if (= index -1)
      '()
      (list-ref table index)))

;;; TESTS:
(begin-for-test
  (check-equal? (lolof=?
                 (get-lolof
                  (let ((u make-UTC))
                    (list
                     (list
                      (list
                       (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
                       (make-flight "Delta 2163" "MSP" "PDX" (u 15 0) (u 19 2)))
                      (list
                       (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
                       (make-flight "Delta 1609" "MSP" "DEN"
                                    (u 20 35) (u 22 52))
                       (make-flight "Delta 5703" "DEN" "LAX" (u 14 4) (u 17 15))
                       (make-flight "Delta 2077" "LAX" "PDX"
                                    (u 17 35) (u 20 9))))
                     (list
                      (list
                       (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
                       (make-flight "Delta 1609" "MSP" "DEN"
                                    (u 20 35) (u 22 52))
                       (make-flight "Delta 5703" "DEN" "LAX"
                                    (u 14 4) (u 17 15))))
                     (list
                      (list
                       (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
                       (make-flight "Delta 1609" "MSP" "DEN" (u 20 35)
                                    (u 22 52))))
                     (list
                      (list
                       (make-flight "Delta 0121" "LGA" "MSP"
                                    (u 11 0) (u 14 9))))
                     '()))
                  3)
                 (list
                  (list
                   (make-flight "Delta 0121" "LGA" "MSP"
                                (make-UTC 11 0) (make-UTC 14 9)))))
                #t "mis-match in lolof value")
  (check-equal?
   (lolof=?
    (get-lolof
     (list '() '() '()
           (list
            (list (make-flight "Delta 0121" "LGA" "MSP"
                               (make-UTC 11 0) (make-UTC 14 9))))
           '())
     -1)
    '()) #t "mis-match in negative index"))

;;; combine-itineraries : ListOfListOfFlight Flight -> ListOfListOfFlight
;;; GIVEN: a ListOfFlight and a Flight
;;; RETURNS: a ListOfFlight that has the fastest way to get to the destination
;;;     using the given Flight
;;; STRATEGY: Combine simpler functions
(define (combine-itineraries lolof flt)
  (let ((new-lolof (get-updated-itineraries lolof flt)))
    (cond [(empty? lolof) (list (list flt))]
          [(empty? new-lolof) '()]
          [else (list (find-fastest-itinerary
                       (find-fastest-travel-time new-lolof)
                       new-lolof))])))

;;; get-updated-itineraries : ListOfListOfFlight Flight -> ListOfListOfFlight
;;; GIVEN: a ListOfListOfFlight and a Flight
;;; RETURNS: an updated ListOfListOfFlight with the Flight added to the
;;;     itinerary
;;; EXAMPLES:
;;;     (get-updated-itineraries
;;;      (list
;;;       (list
;;;        (make-flight "Delta 0121" "LGA" "MSP"
;;;                     (make-UTC 11 00) (make-UTC 14 09))))
;;;      (make-flight "Delta 1609" "MSP" "DEN"
;;;                   (make-UTC 20 35) (make-UTC 22 52)))  =>
;;;     (list
;;;      (list
;;;       (make-flight "Delta 0121" "LGA" "MSP"
;;;                    (make-UTC 11 00) (make-UTC 14 09))
;;;       (make-flight "Delta 1609" "MSP" "DEN"
;;;                    (make-UTC 20 35) (make-UTC 22 52))))
;;;     (get-updated-itineraries
;;;      '()
;;;      (make-flight "Delta 1609" "MSP" "DEN"
;;;                   (make-UTC 20 35) (make-UTC 22 52)))  =>
;;;     '()
;;; STRATEGY: Use HOF map on (get-non-cyclic-itineraries lolof flt)
(define (get-updated-itineraries lolof flt)
  (let ((new-lolof (get-non-cyclic-itineraries lolof flt)))
    (map
     ;;; ListOfFlight -> ListOfFlight
     ;;; GIVEN: a ListOfFlight
     ;;; RETURNS: a ListOfFlight with the flt appended to the ListOfFlight
     (λ (lof) (append lof (list flt))) new-lolof)))

;;; TESTS:
(begin-for-test
  (check-equal?
   (lolof=?
    (get-updated-itineraries
     (list
      (list
       (make-flight "Delta 0121" "LGA" "MSP"
                    (make-UTC 11 00) (make-UTC 14 09))))
     (make-flight "Delta 1609" "MSP" "DEN" (make-UTC 20 35) (make-UTC 22 52)))
    (list
     (list
      (make-flight "Delta 0121" "LGA" "MSP"
                   (make-UTC 11 00) (make-UTC 14 09))
      (make-flight "Delta 1609" "MSP" "DEN"
                   (make-UTC 20 35) (make-UTC 22 52)))))
   #t "mis-match in updated itineraries")
  (check-equal?
   (lolof=?
    (get-updated-itineraries
     '()
     (make-flight "Delta 1609" "MSP" "DEN" (make-UTC 20 35) (make-UTC 22 52)))
    '())
   #t "expected empty"))

;;; get-non-cyclic-itineraries : ListOfListOfFlight Flight -> ListOfListOfFlight
;;; GIVEN: a ListOfListOfFlight and Flight the user is considering to taking
;;;     next
;;; RETURNS: a ListOfListOfFlight that doesn't involve the traveller take cyclic
;;;     trip if the input Flight is taken
;;; EXAMPLES:
;;;     (let ((u make-UTC))
;;;       (get-non-cyclic-itineraries
;;;        (list
;;;         (list
;;;          (make-flight "Delta 0121" "LGA" "MSP"
;;;                       (u 11 00) (u 14 09))))
;;;        (make-flight "Delta 1609" "MSP" "DEN"
;;;                     (u 20 35) (u 22 52))))
;;;       =>
;;;     (let ((u make-UTC))
;;;       (list
;;;        (list
;;;         (make-flight "Delta 0121" "LGA" "MSP"
;;;                      (u 11 00) (u 14 09)))))
;;;     (let ((u make-UTC))
;;;       (get-non-cyclic-itineraries
;;;        (list
;;;         (list
;;;          (make-flight "Delta 0121" "LGA" "MSP"
;;;                       (u 11 00) (u 14 09))
;;;          (make-flight "Delta 1609" "MSP" "DEN"
;;;                       (u 20 35) (u 22 52))
;;;          (make-flight "Delta 5703" "DEN" "LAX"
;;;                       (u 14 04) (u 17 15))))
;;;        (make-flight "Delta 5705" "LAX" "MSP"
;;;                     (u 17 25) (u 20 15))))
;;;       =>  empty
;;; STRATEGY: Use HOF filter on lolof
(define (get-non-cyclic-itineraries lolof flt)
  (filter
   ;;; ListOfFlight -> Boolean
   ;;; GIVEN: a ListOfFlight
   ;;; RETURNS: true if there's a flight in ListOfFlight
   ;;;    departing from the arrives of the flt
   (λ (lof) (not (check-flight-taken? (arrives flt) lof)))
   lolof))

;;; TESTS:
(begin-for-test
  (check-equal? (lolof=?
                 (let ((u make-UTC))
                   (get-non-cyclic-itineraries
                    (list
                     (list
                      (make-flight "Delta 0121" "LGA" "MSP"
                                   (u 11 00) (u 14 09))))
                    (make-flight "Delta 1609" "MSP" "DEN"
                                 (u 20 35) (u 22 52))))
                 (let ((u make-UTC))
                   (list
                    (list
                     (make-flight "Delta 0121" "LGA" "MSP"
                                  (u 11 00) (u 14 09))))))
                true
                "mis-match in get non cyclic itineraries")
  (check-equal? (lolof=?
                 (let ((u make-UTC))
                   (get-non-cyclic-itineraries
                    (list
                     (list
                      (make-flight "Delta 0121" "LGA" "MSP"
                                   (u 11 00) (u 14 09))
                      (make-flight "Delta 1609" "MSP" "DEN"
                                   (u 20 35) (u 22 52))
                      (make-flight "Delta 5703" "DEN" "LAX"
                                   (u 14 04) (u 17 15))))
                    (make-flight "Delta 5705" "LAX" "MSP"
                                 (u 17 25) (u 20 15))))
                 empty)
                true
                "get non cyclic itineraries should return empty"))

;;; renew-table : Table -> Table
;;; GIVEN: two tables, the old one keep track of all possible fastest 
;;;        itinernaries of the first k flights; the new one contains the
;;;        k+1 flight
;;; RETURNS: a Table that keep track of all possible fastest 
;;;        itinernaries of the first k+1 flights
;;; EXAMPLE:
;;;     (renew-table (get-empty-table 5)
;;;                  (list
;;;                   '() '() '()
;;;                   (list
;;;                    (list
;;;                     (make-flight "Delta 5705" "LAX" "MSP"
;;;                                  (make-UTC 17 25) (make-UTC 20 15))))
;;;                   '()))  =>
;;;     (list
;;;      '() '() '()
;;;      (list
;;;       (list
;;;        (make-flight "Delta 5705" "LAX" "MSP"
;;;                     (make-UTC 17 25) (make-UTC 20 15))))
;;;      '())
;;; STRATEGY: Use HOF map on table
(define (renew-table table-old table-new)
  (map (λ (fst sec)
         ;;; Given: Lolof Lolof
         ;;; Return: a Lolof that merge two lolof
         (cond [(empty? fst) sec]
               [(empty? sec) fst]
               [else (append fst sec)]))
       table-old table-new))

;;; TEST:
(begin-for-test
  (check-equal?
   (table=?
    (renew-table (get-empty-table 5)
                 (list
                  '() '() '()
                  (list
                   (list
                    (make-flight "Delta 5705" "LAX" "MSP"
                                 (make-UTC 17 25) (make-UTC 20 15))))
                  '()))
    (list
     '() '() '()
     (list
      (list
       (make-flight "Delta 5705" "LAX" "MSP"
                    (make-UTC 17 25) (make-UTC 20 15))))
     '()))
   #t
   "mis-match in renew-table"))

;;; get-itineraries : String String ListOfFlight -> ListOfListOfFlight
;;; GIVEN: the names of the two airports, ap1 and ap2 (respectively),
;;;     a ListOfFlight that describes all of the flights a traveller is willing
;;;     to consider taking
;;; RETURNS: a ListOfListOfFlight that describes how a traveller could fly from
;;;     first airport (ap1) to the second airport (ap2)
;;; EXAMPLES:
;;;     (get-itineraries "PDX" "LGA" deltaFlights '())  =>  empty
;;;     (get-itineraries "LGA" "PDX" deltaFlights '())
;;;       =>  (list
;;;            (list
;;;             (make-flight "Delta 0121" "LGA" "MSP"
;;;                          (make-UTC 11 0) (make-UTC 14 9))
;;;             (make-flight "Delta 2163" "MSP" "PDX"
;;;                          (make-UTC 15 0) (make-UTC 19 2))
;;;            (list
;;;             (make-flight "Delta 0121" "LGA" "MSP"
;;;                          (make-UTC 11 0) (make-UTC 14 9))
;;;             (make-flight "Delta 1609" "MSP" "DEN"
;;;                          (make-UTC 20 35) (make-UTC 22 52))
;;;             (make-flight "Delta 5703" "DEN" "LAX"
;;;                          (make-UTC 14 4) (make-UTC 17 15))
;;;             (make-flight "Delta 2077" "LAX" "PDX"
;;;                          (make-UTC 17 35) (make-UTC 20 9)))))
;;; STRATEGY: Combine simpler functions
(define (get-itineraries  ap1 ap2 lof)
  (let ((table (all-itineraries
                (sort-lof ap1 '() lof)
                (all-airports lof)
                (get-empty-table (length (all-airports lof)))))
        (index (find-index (all-airports lof) ap2 0)))
    (if (= -1 index)
        '()
        (list-ref table index))))

;;; TESTS:
(begin-for-test
  (check-equal? (lolof=?
                 (get-itineraries "PDX" "LGA" deltaFlights) empty)
                true
                "get itineraries on empty ListOfFlight should be empty")
  (check-equal?
   (lolof=?
    (get-itineraries "LGA" "PDX" deltaFlights)
    (list
     (list
      (make-flight "Delta 0121" "LGA" "MSP" (make-UTC 11 0) (make-UTC 14 9))
      (make-flight "Delta 2163" "MSP" "PDX" (make-UTC 15 0) (make-UTC 19 2)))
     (list
      (make-flight "Delta 0121" "LGA" "MSP" (make-UTC 11 0) (make-UTC 14 9))
      (make-flight "Delta 1609" "MSP" "DEN" (make-UTC 20 35) (make-UTC 22 52))
      (make-flight "Delta 5703" "DEN" "LAX" (make-UTC 14 4) (make-UTC 17 15))
      (make-flight "Delta 2077" "LAX" "PDX" (make-UTC 17 35) (make-UTC 20 9)))))
   true
   "mis-match on get itineraries from LGA to PDX on deltaFlights"))

;;; fastest-itinerary : String String ListOfFlight -> ListOfFlight
;;; GIVEN: the names of two airports, ap1 and ap2 (respectively),
;;;     and a ListOfFlight that describes all of the flights a
;;;     traveller is willing to consider taking
;;; WHERE: it is possible to fly from the first airport (ap1) to
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
        (find-fastest-itinerary t (get-itineraries ap1 ap2 lof))
        '())))

;;; TESTS:
(begin-for-test
  (check-equal? (lof=? (fastest-itinerary "JFK" "JFK" panAmFlights) empty)
                true
                "fastest itinerary between two airports in empty ListOfFlight
should be empty")
  (check-equal? (lof=?
                 (fastest-itinerary "LGA" "PDX" deltaFlights)
                 (list (make-flight "Delta 0121"
                                    "LGA" "MSP"
                                    (make-UTC 11 00) (make-UTC 14 09))
                       (make-flight "Delta 2163"
                                    "MSP" "PDX"
                                    (make-UTC 15 00) (make-UTC 19 02))))
                true
                "mis-match in fastest itinerary between two airports in
deltaFlights"))

;;; find-fastest-itinerary : NonNegInt ListOfListOfFlight -> ListOfFlight
;;; GIVEN: the fastest travel time and a ListOfListOfFlight
;;; RETURNS: A ListOfFlight within the ListOfListOfFlight matching the fastest
;;;     travel time
;;; STRATEGY: Use template for ListOfListOfFlight on
;;;     (find-fastest-itineraries t lolof)
(define (find-fastest-itinerary t lolof)
  (let ((new-lolof (find-fastest-itineraries t lolof)))
    (first new-lolof)))

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
  (check-equal? (lolof=?
                 (find-fastest-itineraries 482
                                           (get-itineraries "LGA" "PDX"
                                                            deltaFlights))
                 (list (list (make-flight "Delta 0121"
                                          "LGA" "MSP"
                                          (make-UTC 11 00) (make-UTC 14 09))
                             (make-flight "Delta 2163"
                                          "MSP" "PDX"
                                          (make-UTC 15 00) (make-UTC 19 02)))))
                true
                "mis-match in fastest itinerary between two airports in
deltaFlights"))

;;; travel-time : String String ListOfFlight -> NonNegInt
;;; GIVEN: the names of two airports, ap1 and ap2 (respectively),
;;;     and a ListOfFlight that describes all of the flights a
;;;     traveller is willing to consider taking
;;; WHERE: it is possible to fly from the first airport (ap1) to
;;;     the second airport (ap2) using only the given flights
;;; RETURNS: the number of minutes it takes to fly from the first
;;;     airport (ap1) to the second airport (ap2), including any
;;;     layovers, by the fastest possible route that uses only
;;;     the given flights
;;; EXAMPLES:
;;;     (travel-time "JFK" "JFK" panAmFlights)  =>  0
;;;     (travel-time "LGA" "PDX" deltaFlights)  =>  482
;;; STRATEGY: Combine simpler functions
(define (travel-time ap1 ap2 lof)
  (let ((lolof (get-itineraries  ap1 ap2 lof)))
    (if (empty? lolof)
        0
        (find-fastest-travel-time lolof))))

;;; TESTS:
(begin-for-test
  (check-equal? (travel-time "JFK" "JFK" panAmFlights) 0
                "travel time between same airports should be 0")
  (check-equal? (travel-time "LGA" "PDX" deltaFlights) 482
                "mis-match in travel time between two airports in deltaFlights")
  (check-equal? (travel-time "LGA" "PDX" testFlights) 482
                "mis-match in travel time between two airports in testFlights"))

;;; find-fastest-travel-time : ListOfListOfFlight -> NonNegInt
;;; GIVEN: a ListOfListOfFlight that describes all of the itineraries a
;;;     traveller is willing to consider taking
;;; RETURNS: the number of minutes it takes to fly from the first
;;;     airport (ap1) to the second airport (ap2), including any
;;;     layovers, by the fastest possible route
;;; EXAMPLES:
;;;     (find-fastest-travel-time
;;;      (list
;;;       (list
;;;        (make-flight "Delta 0121" "LGA" "MSP"
;;;                     (make-UTC 11 0) (make-UTC 14 9)))))  =>  189
;;;     (let ((u make-UTC))
;;;       (find-fastest-travel-time
;;;        (list
;;;         (list
;;;          (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
;;;          (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
;;;          (make-flight "Delta 5703" "DEN" "LAX" (u 14 4) (u 17 15))
;;;          (make-flight "Delta 2077" "LAX" "PDX" (u 17 35) (u 20 9)))
;;;         (list
;;;          (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
;;;          (make-flight "Delta 2163" "MSP" "PDX" (u 15 0) (u 19 2))))))
;;;       =>  482
;;; STRATEGY: Use HOF foldr on lolof
(define (find-fastest-travel-time lolof)
  (foldr
   ;;; ListOfFlight NonNegInt -> NonNegInt
   ;;; GIVEN: a ListofFlight and a NonNegInt
   ;;; RETURNS: the smaller between the flight-time and the number
   (λ (lof t)
     (let ((local-total-travel-time (total-travel-time lof)))
       (if (< t local-total-travel-time)
           t
           local-total-travel-time)))
   (total-travel-time (first lolof)) (rest lolof)))

;;; TESTS:
(begin-for-test
  (check-equal? (find-fastest-travel-time
                 (list
                  (list
                   (make-flight "Delta 0121" "LGA" "MSP"
                                (make-UTC 11 0) (make-UTC 14 9)))))
                189
                "fastest travel time mismatch for custom list of itineraries")
  (check-equal? (let ((u make-UTC))
                  (find-fastest-travel-time
                   (list
                    (list
                     (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
                     (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
                     (make-flight "Delta 5703" "DEN" "LAX" (u 14 4) (u 17 15))
                     (make-flight "Delta 2077" "LAX" "PDX" (u 17 35) (u 20 9)))
                    (list
                     (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
                     (make-flight "Delta 2163" "MSP" "PDX" (u 15 0) (u 19 2)))))
                  )
                482
                "fastest travel time mismatch for custom list of itineraries"))

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
  (+ (* 60 (hours-between utc1 utc2))
     (- (UTC-minute utc2) (UTC-minute utc1))))

;;; TESTS:
(begin-for-test
  (check-equal? (time-between (make-UTC 12 00) (make-UTC 12 00)) 1440
                "time between two equal UTC should be 1440")
  (check-equal? (time-between (make-UTC 12 10) (make-UTC 12 00)) 1430
                "mis-match in time between two custom UTC with utc1 > utc2")
  (check-equal? (time-between (make-UTC 11 00) (make-UTC 12 00)) 60
                "mis-match in time between two custom UTC"))

;;; hours-between : UTC UTC -> NonNegInt
;;; GIVEN: two UTC, utc1 and utc2 (respectively)
;;; RETURN: the difference in hours between the two UTC
;;; EXAMPLE:
;;;     (hours-between (make-UTC 12 00) (make-UTC 12 00))  =>  24
;;;     (hours-between (make-UTC 12 10) (make-UTC 12 00))  =>  24
;;;     (hours-between (make-UTC 11 00) (make-UTC 12 00))  =>  1
;;; STRATEGY: Combine simpler functions
(define (hours-between utc1 utc2)
  (- (if (UTC-previousday? utc1 utc2)
         (+ (UTC-hour utc2) 24)
         (UTC-hour utc2))
     (UTC-hour utc1)))

;;; TESTS:
(begin-for-test
  (check-equal? (hours-between (make-UTC 12 00) (make-UTC 12 00)) 24
                "hours between two equal UTC should be 24")
  (check-equal? (hours-between (make-UTC 12 10) (make-UTC 12 00)) 24
                "mis-match in hours between two custom UTC with utc1 > utc2")
  (check-equal? (hours-between (make-UTC 11 00) (make-UTC 12 00)) 1
                "mis-match in hours between two custom UTC"))

;;; UTC-previousday? : UTC UTC -> Boolean
;;; GIVEN: two UTC, utc1 and utc2 (respectively)
;;; RETURN: true iff the first flight is ealier than the second one
;;; EXAMPLES:
;;;     (UTC-previousday? (make-UTC 12 00) (make-UTC 12 00))  =>  #t
;;;     (UTC-previousday? (make-UTC 12 00) (make-UTC 12 10))  =>  #f
;;; STRATEGY: Combine simpler functions
(define (UTC-previousday? utc1 utc2)
  (or (> (UTC-hour utc1) (UTC-hour utc2))
      (and (= (UTC-hour utc1) (UTC-hour utc2))
           (>= (UTC-minute utc1) (UTC-minute utc2)))))

;;; TESTS:
(begin-for-test
  (check-equal? (UTC-previousday? (make-UTC 12 00) (make-UTC 12 00)) true
                "mis-match in boolean return, expecting true")
  (check-equal? (UTC-previousday? (make-UTC 12 00) (make-UTC 12 10)) false
                "mis-match in boolean return, expecting false"))

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
;;; HALTING MEASURE: length of lof2
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

;;; table=? : Table Table -> Boolean
;;; GIVEN: two Table
;;; RETURNS: true if each ListOfListOfFlight in both Table are equal
;;; EXAMPLES:
;;;    (table=? (get-empty-table 5) (get-empty-table 5))  => #t
;;;    (table=? (get-empty-table 5) (get-empty-table 4))  => #f
;;; STRATEGY: Combine simpler functions
(define (table=? table1 table2)
  (if (= (length table1) (length table2))
      (compare-table? table1 table2)
      false))

;;; TESTS:
(begin-for-test
  (check-equal? (table=? (get-empty-table 5) (get-empty-table 5))
                #t "expect empty equal table to be equal")
  (check-equal? (table=? (get-empty-table 5) (get-empty-table 4))
                #f "mis-match in table=?"))

;;; compare-table? : Table Table -> Boolean
;;; GIVEN: Two Table
;;; WHERE: both Table are of equal length
;;; RETURNS: True if each ListOfListOfFlight in both Table are equal
;;; EXAMPLES:
;;;    (compare-table? (get-empty-table 5) (get-empty-table 5))  => #t
;;;    (compare-table?
;;;     (get-empty-table 5)
;;;     (list '() '() '() '() (list (list (first deltaFlights)))))  =>  #f
;;; STRATEGY: Use template for ListOfListOfFlight on loflof1
;;; HALTING MEASURE: length of loflof1
(define (compare-table? table1 table2)
  (cond [(empty? table1) true]
        [(lolof=? (first table1) (first table2))
         (table=? (rest table1) (rest table2))]
        [else false]))

;;; TESTS:
(begin-for-test
  (check-equal? (compare-table? (get-empty-table 5) (get-empty-table 5)) #t
                "equal table should return true")
  (check-equal? (compare-table?
                 (get-empty-table 5)
                 (list '() '() '() '() (list (list (first deltaFlights)))))
                #f "mis-match in compare table"))

;;; lolof=? : ListOfListOfFlight ListOfListOfFlight -> Boolean
;;; GIVEN: two ListOfListOfFlight
;;; RETURNS: true if each ListOfFlight in both ListOfListOfFlight are equal
;;; EXAMPLES:
;;;     (lolof=? (all-itineraries "LGA" "PDX" deltaFlights '()) '())  => false
;;;     (lolof=?
;;;      (all-itineraries "LGA" "PDX" deltaFlights '())
;;;      (list
;;;       (list
;;;        (make-flight "Delta 0121" "LGA" "MSP"
;;;                     (make-UTC 11 0) (make-UTC 14 9))
;;;        (make-flight "Delta 1609" "MSP" "DEN"
;;;                     (make-UTC 20 35) (make-UTC 22 52))
;;;        (make-flight "Delta 5703" "DEN" "LAX"
;;;                     (make-UTC 14 4) (make-UTC 17 15))
;;;        (make-flight "Delta 2077" "LAX" "PDX"
;;;                     (make-UTC 17 35) (make-UTC 20 9)))
;;;       (list
;;;        (make-flight "Delta 0121" "LGA" "MSP"
;;;                     (make-UTC 11 0) (make-UTC 14 9))
;;;        (make-flight "Delta 2163" "MSP" "PDX"
;;;                     (make-UTC 15 0) (make-UTC 19 2)))))  => true
;;; STRATEGY: Combine simpler functions
(define (lolof=? lolof1 lolof2)
  (if (= (length lolof1) (length lolof2))
      (compare-lolof? lolof1 lolof2)
      false))

;;; TESTS:
(begin-for-test
  (check-equal? (lolof=? (get-itineraries "LGA" "PDX" deltaFlights) '())
                false
                "should return false when different ListOfListOfFlight are
compared")
  (check-equal? (let ((u make-UTC))
                  (lolof=?
                   (get-itineraries "LGA" "PDX" deltaFlights)
                   (list
                    (list
                     (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
                     (make-flight "Delta 2163" "MSP" "PDX" (u 15 0) (u 19 2)))
                    (list
                     (make-flight "Delta 0121" "LGA" "MSP" (u 11 0) (u 14 9))
                     (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
                     (make-flight "Delta 5703" "DEN" "LAX" (u 14 4) (u 17 15))
                     (make-flight "Delta 2077" "LAX" "PDX" (u 17 35) (u 20 9))))
                   ))
                true
                "should return true when same ListOfListOfFlight are compared"))

;;; compare-lolof : ListOfListOfFlight ListOfListOfFlight -> Boolean
;;; GIVEN: Two ListOfListOfFlight
;;; WHERE: both ListOfListOfFlight are of equal length
;;; RETURNS: True if each ListOfFlight in both ListOfListOfFlight are equal
;;; EXAMPLES:
;;;     (compare-lolof?
;;;      (find-fastest-itineraries 482
;;;                                (all-itineraries "LGA" "PDX"
;;;                                                 deltaFlights '())) '())
;;;       =>  true
;;;     (compare-lolof?
;;;      (find-fastest-itineraries 482
;;;                                (all-itineraries "LGA" "PDX"
;;;                                                 deltaFlights '()))
;;;      (list (list (make-flight "Delta 0121"
;;;                               "LGA" "MSP"
;;;                               (make-UTC 11 00) (make-UTC 14 09))
;;;                  (make-flight "Delta 2123"
;;;                               "MSP" "PDX"
;;;                               (make-UTC 15 00) (make-UTC 19 02)))))
;;;       =>  false
;;; STRATEGY: Use template for ListOfListOfFlight on loflof1
;;; HALTING MEASURE: length of loflof1
(define (compare-lolof? lolof1 lolof2)
  (cond [(empty? lolof1) true]
        [(lof=? (first lolof1) (first lolof2))
         (lolof=? (rest lolof1) (rest lolof2))]
        [else false]))

;;; TESTS:
(begin-for-test
  (check-equal? (compare-lolof? (find-fastest-itineraries
                                 200 (get-itineraries "LGA" "PDX"
                                                      deltaFlights)) '())
                true
                "should return true when empty ListOfListOfFlight are compared")
  (check-equal? (compare-lolof?
                 (find-fastest-itineraries 482
                                           (get-itineraries "LGA" "PDX"
                                                            deltaFlights))
                 (list (list (make-flight "Delta 0121"
                                          "LGA" "MSP"
                                          (make-UTC 11 00) (make-UTC 14 09))
                             (make-flight "Delta 2123"
                                          "MSP" "PDX"
                                          (make-UTC 15 00) (make-UTC 19 02)))))
                false
                "should return false when different ListOfListOfFlight are
compared"))

;;; lof=?: ListofFlight ListofFlight -> Boolean
;;; GIVEN: Two ListOfFlight
;;; RETURNS: True if each Flight in both ListOfFlight are equal
;;; EXAMPLES:
;;;     (lof=? (flights-from-ap "MSP" deltaFlights) '())  =>  false
;;;     (lof=?
;;;      (flights-from-ap "MSP" deltaFlights)
;;;      (let ((u make-UTC))
;;;        (list
;;;         (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
;;;         (make-flight "Delta 2163" "MSP" "PDX" (u 15 00) (u 19 02))))
;;;      )  =>  true
;;; STRATEGY: Combine simpler functions
(define (lof=? lof1 lof2)
  (if (= (length lof1) (length lof2))
      (compare-lof? lof1 lof2)
      false))

;;; TESTS:
(begin-for-test
  (check-equal? (lof=? (flights-from-ap "MSP" deltaFlights) '())
                false
                "should return false when different ListOfFlight are compared")
  (check-equal? (lof=?
                 (flights-from-ap "MSP" deltaFlights)
                 (let ((u make-UTC))
                   (list
                    (make-flight "Delta 1609" "MSP" "DEN" (u 20 35) (u 22 52))
                    (make-flight "Delta 2163" "MSP" "PDX" (u 15 00) (u 19 02))))
                 )
                true
                "should return true when same ListOfFlight are compared"))

;;; compare-lof?: ListofFlight ListofFlight -> Boolean
;;; GIVEN: Two ListOfFlight
;;; WHERE: both ListOfFlight are of equal length
;;; RETURNS: True if each Flight in both ListOfFlight are equal
;;; EXAMPLES:
;;;     (compare-lof? (fastest-itinerary "JFK" "JFK" panAmFlights) '())  => true
;;;     (compare-lof?
;;;      (fastest-itinerary "LGA" "PDX" deltaFlights)
;;;      (list (make-flight "Delta 0121"
;;;                         "LGA" "MSP"
;;;                         (make-UTC 11 00) (make-UTC 14 09))
;;;            (make-flight "Delta 2123"
;;;                         "MSP" "PDX"
;;;                         (make-UTC 15 00) (make-UTC 19 02))))  =>  false
;;; STRATEGY: Use template for ListOfFlight on lof1
;;; HALTING MEASURE: length of lof1
(define (compare-lof? lof1 lof2)
  (cond [(empty? lof1) true]
        [(flight=? (first lof1) (first lof2))
         (lof=? (rest lof1) (rest lof2))]
        [else false]))

;;; TESTS:
(begin-for-test
  (check-equal? (compare-lof? (fastest-itinerary "JFK" "JFK" panAmFlights) '())
                true
                "should return true when empty ListOfFlight are compared")
  (check-equal? (compare-lof?
                 (fastest-itinerary "LGA" "PDX" deltaFlights)
                 (list (make-flight "Delta 0121"
                                    "LGA" "MSP"
                                    (make-UTC 11 00) (make-UTC 14 09))
                       (make-flight "Delta 2123"
                                    "MSP" "PDX"
                                    (make-UTC 15 00) (make-UTC 19 02))))
                false
                "should return false when different ListOfFlight are compared"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; all-airports : ListOfFlight -> ListOfString
;;; RETURNS: A list of all airports served by some flight
;;;     in the given list.
(define (all-airports flights)
  (all-airports-loop (append (map departs flights)
                             (map arrives flights))
                     empty))
    
;;; all-airports-loop : ListOfString ListOfString -> ListOfString
;;; GIVEN: two lists of strings
;;; WHERE: the second list is a set (no element occurs twice)
;;; RETURNS: the set union of the given lists
(define (all-airports-loop names airports)
  (if (empty? names)
      airports
      (all-airports-loop (rest names)
                         (if (member (first names) airports)
                             airports
                             (cons (first names) airports)))))
    
;;; visit-all-pairs-of-airports :
;;;     (String String ListOfFlight -> X) ListOfFlight -> ListOfX
;;; GIVEN: a function whose arguments are suitable for can-get-there?
;;; RETURNS: a list of the results obtained by calling that function
;;;     on all pairs of airports served by the given flights,
;;;     passing the given list of flights as a third argument.
(define (visit-all-pairs-of-airports visitor flights)
  (let ((airports (all-airports flights)))
    (apply append
           (map (lambda (ap1)
                  (map (lambda (ap2)
                         (visitor ap1 ap2 flights))
                       airports))
                airports))))
    
;;; make-stress-test0 : NonNegInt -> ListOfFlight
;;; GIVEN: a non-negative integer n
;;; RETURNS: a list of 2n flights connecting n+1 airports
(define (make-stress-test0 n)
  (if (= n 0)
      empty
      (let* ((name1 (string-append "NoWays " (number->string (+ n n))))
             (name2 (string-append "NoWays " (number->string (+ n n 1))))
             (ap1 (string-append "AP" (number->string n)))
             (ap2 (string-append "AP" (number->string (+ n 1))))
             (t1 (make-UTC (remainder (* 107 n) 24)
                           (remainder (* 223 n) 60)))
             (t2 (make-UTC (remainder (* 151 n) 24)
                           (remainder (* 197 n) 60)))
             (t3 (make-UTC (remainder (* 163 n) 24)
                           (remainder (* 201 n) 60)))
             (t4 (make-UTC (remainder (* 295 n) 24)
                           (remainder (* 183 n) 60)))
             (f1 (make-flight name1 ap1 ap2 t1 t2))
             (f2 (make-flight name2 ap1 ap2 t3 t4)))
        (cons f1 (cons f2 (make-stress-test0 (- n 1)))))))
    
;;; benchmark0 : NonNegInt -> List
;;; GIVEN: a non-negative integer parameter n
;;; RETURNS: a list of length n^2 showing the travel time for
;;;     every pair of airports in a stress test of size Theta(n)
;;; EFFECT: prints the total running time
(define (benchmark0 n)
  (let ((flights (make-stress-test0 n)))
    (time (visit-all-pairs-of-airports
           (lambda (ap1 ap2 flights)
             (if (can-get-there? ap1 ap2 flights)
                 (list ap1 ap2 (travel-time ap1 ap2 flights))
                 (list ap1 ap2 -1)))
           flights))))