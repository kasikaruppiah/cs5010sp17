;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require "extras.rkt")
(require rackunit)

(require 2htdp/image)
(require 2htdp/universe)

(provide doodad-color
         doodad-x
         doodad-y
         doodad-vx
         doodad-vy
         doodad-selected?
         doodad-age
         world-doodads-star
         world-doodads-square
         world-paused?
         initial-world
         world-after-tick
         world-after-key-event         
         world-after-mouse-event
         animation)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; DATA DEFINITIONS

;; A BasicShape is one of
;;   -- "radial-star"
;;   -- "square"
;; Interpretation: self-evident
;; TEMPLATE:
;;   basicshape-fn : BasicShape -> ??
#|
(define (basicshape-fn shape)
  (cond [(string=? shape "radial-star") ...]
        [(string=? shape "square") ...]))
|#

(define-struct doodad (shape color x y vx vy selected? mx my age))
;; A Doodad is a structure:
;;   (make-doodad BasicShape Color Integer Integer Integer
;;                Integer Boolean Integer Integer Integer)
;; Interpretation:
;;   shape is the basic shape of the doodad
;;   color is a color-symbol
;;     it can take either "Gold", "Green" or "Blue" when shape is "radial-star"
;;     it can take any one of "Gray", "OliveDrab", "Khaki", "Orange"
;;       or "Crimson" when shape is "square"
;;   x is the x component of the posn marking the center of the doodad
;;   y is the y component of the posn marking the center of the doodad
;;   vx is the number of pixels the doodad moves on each tick in the x direction
;;   vy is the number of pixels the doodad moves on each tick in the y direction
;;   selected? describes whether or not the doodad is selected
;;   mx is the distance of the x component from the center of the doodad
;;   my is the distance of the y component from the center of the doodad
;;   age is the number of ticks elapsed since doodad has been added to the world
;; TEMPLATE:
;;   doodad-fn : Doodad -> ??
#|
(define (doodad-fn dd)
  (...
   (doodad-shape dd)
   (doodad-color dd)
   (doodad-x dd)
   (doodad-y dd)
   (doodad-vx dd)
   (doodad-vy dd)
   (doodad-selected? dd)
   (doodad-mx dd)
   (doodad-my dd)
   (doodad-age dd)))
|#

;; A list of Doodad (ListOfDoodad) is either
;;   -- empty
;;   -- (cons Doodad ListOfDoodad)
;; TEMPLATE:
;;   lod-fn : ListOfDoodad -> ??
;;   HALTING MEASURE: length of lod
#|
(define (lod-fn lod)
  (cond [(empty? lod) ...]
        [else (...
               (doodad-fn (first lod))
               (lod-fn (rest lod)))]))
|#

(define-struct world (doodads-star doodads-square paused? star-vr square-vr))
;; A World is a structure:
;;   (make-world ListOfDoodad ListOfDoodad Boolean Integer Integer)
;; Interpretation:
;;   doodads-star is a ListOfDoodad representing list of radial-star's
;;   doodads-square is a ListOfDoodad representing list of square's
;;   paused? describes whether or not the world is paused
;;   star-vr is an Integer that can have values between 0 and 3 (0, 1, 2 or 3)
;;     indicating the number of 90 degree clockwise rotations to be made on the
;;     initial star velocity for the next star Doodad
;;   square-vr is an Integer that can have values between 0 and 3 (0, 1, 2 or 3)
;;     indicating the number of 90 degree clockwise rotations to be made on the
;;     initial square velocity for the next square Doodad
;; TEMPLATE:
;;   world-fn : World -> ??
#|
(define (world-fn w)
  (...
   (world-doodads-star w)
   (world-doodads-square w)
   (world-paused? w)
   (world-star-vr w)
   (world-square-vr w)))
|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; CONSTANTS

;; width of animation window
(define ANIMATION-WINDOW-WIDTH 601)
;; height of animation window
(define ANIMATION-WINDOW-HEIGHT 449)
;; animation window that displays two doodas
(define ANIMATION-WINDOW (empty-scene ANIMATION-WINDOW-WIDTH
                                      ANIMATION-WINDOW-HEIGHT))
;; point-count of radial-star
(define RADIAL-STAR-POINT-COUNT 8)
;; inner-radius of radial-star
(define RADIAL-STAR-INNER-RADIUS 10)
;; outer-radius of radial-star
(define RADIAL-STAR-OUTER-RADIUS 50)
;; side-len of square
(define SQUARE-SIDE-LEN 71)
;; half side-len of square
(define HALF-SQUARE-SIDE-LEN (/ SQUARE-SIDE-LEN 2))
;; mode of doodad basic shape
(define DOODAD-MODE "solid")
;; radial-star colors
(define RADIAL-STAR-COLOR1 "Gold")
(define RADIAL-STAR-COLOR2 "Green")
(define RADIAL-STAR-COLOR3 "Blue")
;; square colors
(define SQUARE-COLOR1 "Gray")
(define SQUARE-COLOR2 "OliveDrab")
(define SQUARE-COLOR3 "Khaki")
(define SQUARE-COLOR4 "Orange")
(define SQUARE-COLOR5 "Crimson")
;; starting color radial-star
(define RADIAL-STAR-STARTING-COLOR RADIAL-STAR-COLOR1)
;; starting color square
(define SQUARE-STARTING-COLOR SQUARE-COLOR1)
;; initial center position of radial-star doodad
(define RADIAL-STAR-INITIAL-CENTER (make-posn 125 120))
;; initial horizontal velocity of radial-star doodad
(define RADIAL-STAR-INITIAL-VX 10)
;; initial vertical velocity of radial-star doodad
(define RADIAL-STAR-INITIAL-VY 12)
;; initial center position of square doodad
(define SQUARE-INITIAL-CENTER (make-posn 460 350))
;; initial horizontal velocity of square doodad
(define SQUARE-INITIAL-VX -13)
;; initial vertical velocity of radial-star doodad
(define SQUARE-INITIAL-VY -9)
;; mouse marker displayed on top of doodad
(define MOUSE-MARKER (circle 3 "solid" "black"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; FUNCTIONS

;; rotate-velocity : Posn Integer
;; GIVEN: a Posn and an Integer
;; RETURNS: returns a Posn similar to the initial Posn but after rotating the
;;   Posn 90 degree in clockwise direction for specified number of times
;; EXAMPLES:
;;   (rotate-velocity (make-posn -13 -9) 0) =>
;;     (make-posn -13 -9)
;;   (rotate-velocity (make-posn -13 -9) 1) =>
;;     (make-posn 9 -13)
;; STRATEGY: combine simpler functions
;; HALTING MEASURE: the value of rotation
(define (rotate-velocity pv rotation)
  (cond [(= rotation 0) pv]
        [else (rotate-velocity (make-posn (- (posn-y pv)) (posn-x pv))
                               (- rotation 1))]))

;; make-new-doodad : BasicShape Integer -> Doodad
;; GIVEN: a BasicShape and an Integer representing the number of 90 degree
;;   rotations to be made on the initial velocity in clockwise direction 
;; RETURNS: a Doodad
;; EXAMPLES:
;;   (make-new-doodad "radial-star" 0) =>
;;     (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
;;   (make-new-doodad "square" 0) =>
;;     (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
;; STRATEGY: combine simpler functions
(define (make-new-doodad shape rotation)
  (if (string=? shape "radial-star")
      (make-doodad shape
                   RADIAL-STAR-STARTING-COLOR
                   (posn-x RADIAL-STAR-INITIAL-CENTER)
                   (posn-y RADIAL-STAR-INITIAL-CENTER)
                   (posn-x (rotate-velocity (make-posn
                                             RADIAL-STAR-INITIAL-VX
                                             RADIAL-STAR-INITIAL-VY)
                                            rotation))
                   (posn-y (rotate-velocity (make-posn
                                             RADIAL-STAR-INITIAL-VX
                                             RADIAL-STAR-INITIAL-VY)
                                            rotation))
                   false 0 0 0)
      (make-doodad shape        
                   SQUARE-STARTING-COLOR
                   (posn-x SQUARE-INITIAL-CENTER)
                   (posn-y SQUARE-INITIAL-CENTER)
                   (posn-x (rotate-velocity (make-posn
                                             SQUARE-INITIAL-VX
                                             SQUARE-INITIAL-VY)
                                            rotation))
                   (posn-y (rotate-velocity (make-posn
                                             SQUARE-INITIAL-VX
                                             SQUARE-INITIAL-VY)
                                            rotation))
                   false 0 0 0)))

;; initial-world : Any -> World
;; GIVEN: any value (ignored)
;; RETURNS: the initial World specified for the animation
;; EXAMPLES:
;;   (initial-world -174) =>
;;     (make-world
;;      (list (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0))
;;      (list (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0))
;;      #false 1 1)
;; STRATEGY: combine simpler functions
(define (initial-world ip)
  (make-world (cons (make-new-doodad "radial-star" 0)
                    empty)
              (cons (make-new-doodad "square" 0)
                    empty)
              false 1 1))

;; bounce-x? : Doodad -> Boolean
;; GIVEN: a Doodad
;; RETURNS: true if the tentative x position of the Doodad is negative or
;;   is greater than or equal to the animation window width
;; EXAMPLES:
;;   (bounce-x? (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
;;     => #false
;;   (bounce-x? (make-doodad "square" "Gray" 0 350 -13 -9 #false 0 0 0))
;;     => #true
;; STRATEGY: combine simpler functions
(define (bounce-x? dd)
  (if (and (>= (+ (doodad-x dd) (doodad-vx dd)) 0)
           (< (+ (doodad-x dd) (doodad-vx dd)) ANIMATION-WINDOW-WIDTH))
      false
      true))

;; bounce-y? : Doodad -> Boolean
;; GIVEN: a Doodad
;; RETURNS: true if the tentative y position of the Doodad is negative or
;;   is greater than or equal to the animation window width
;; EXAMPLES:
;;   (bounce-y? (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)) =
;;     #false
;;   (bounce-y? (make-doodad "square" "Gray" 460 0 -13 -9 #false 0 0 0))) =
;;     #true
;; STRATEGY: combine simpler functions
(define (bounce-y? dd)
  (if (and (>= (+ (doodad-y dd) (doodad-vy dd)) 0)
           (< (+ (doodad-y dd) (doodad-vy dd)) ANIMATION-WINDOW-HEIGHT))
      false
      true))

;; next-color : Doodad -> Color
;; GIVEN: a Doodad
;; RETURNS: the color of the Doodad at its next position
;; EXAMPLES:
;;   (next-color (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
;;     => "Green"
;;   (next-color (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
;;     => "Khaki"
;; STRATEGY: combine simpler functions
(define (next-color dd)
  (if (string=? (doodad-shape dd) "radial-star")
      (cond [(string=? (doodad-color dd) RADIAL-STAR-COLOR1) RADIAL-STAR-COLOR2]
            [(string=? (doodad-color dd) RADIAL-STAR-COLOR2) RADIAL-STAR-COLOR3]
            [else RADIAL-STAR-COLOR1])
      (cond [(string=? (doodad-color dd) SQUARE-COLOR1) SQUARE-COLOR2]
            [(string=? (doodad-color dd) SQUARE-COLOR2) SQUARE-COLOR3]
            [(string=? (doodad-color dd) SQUARE-COLOR3) SQUARE-COLOR4]
            [(string=? (doodad-color dd) SQUARE-COLOR4) SQUARE-COLOR5]
            [else SQUARE-COLOR1])))

;; next-x : Doodad -> Integer
;; GIVEN: a Doodad
;; RETURNS: the next x position of the Doodad
;; EXAMPLES:
;;   (next-x (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
;;     => 135
;;   (next-x (make-doodad "square" "Gray" 0 350 -13 -9 #false 0 0 0)) => 13
;; STRATEGY: combine simpler functions
(define (next-x dd)
  (if (bounce-x? dd)
      (if (< (+ (doodad-x dd) (doodad-vx dd)) 0)
          (abs (+ (doodad-x dd) (doodad-vx dd)))
          (- (* 2 (- ANIMATION-WINDOW-WIDTH 1))
             (+ (doodad-x dd) (doodad-vx dd))))
      (+ (doodad-x dd) (doodad-vx dd))))

;; next-y : Doodad -> Integer
;; GIVEN: a Doodad
;; RETURNS: the next y position of the Doodad
;; EXAMPLES:
;;   (next-y (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)) =>
;;     132
;;   (next-y (make-doodad "square" "Gray" 460 0 -13 -9 #false 0 0 0)) => 9
;; STRATEGY: combine simpler functions
(define (next-y dd)
  (if (bounce-y? dd)
      (if (< (+ (doodad-y dd) (doodad-vy dd)) 0)
          (abs (+ (doodad-y dd) (doodad-vy dd)))
          (- (* 2 (- ANIMATION-WINDOW-HEIGHT 1))
             (+ (doodad-y dd) (doodad-vy dd))))
      (+ (doodad-y dd) (doodad-vy dd))))

;; next-vx : Doodad -> Integer
;; GIVEN: a Doodad
;; RETURNS: the next vx, number of pixels the doodad moves on
;;   each tick in the x direction
;; EXAMPLES:
;;   (next-vx (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)) =>
;;     10
;;   (next-vx (make-doodad "square" "Gray" 0 350 -13 -9 #false 0 0 0)) => 13
;; STRATEGY: combine simpler functions
(define (next-vx dd)
  (if (bounce-x? dd)
      (- (doodad-vx dd))
      (doodad-vx dd)))

;; next-vy : Doodad -> Integer
;; GIVEN: a Doodad
;; RETURNS: the next vy, number of pixels the doodad moves on
;;   each tick in the y direction
;; EXAMPLES:
;;   (next-vy (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)) =>
;;     12
;;   (next-vy (make-doodad "square" "Gray" 460 0 -13 -9 #false 0 0 0)) => 9
;; STRATEGY: combine simpler functions
(define (next-vy dd)
  (if (bounce-y? dd)
      (- (doodad-vy dd))
      (doodad-vy dd)))

;; next-doodad : Doodad Boolean -> Doodad
;; GIVEN: a Doodad and a Boolean value indicating the paused status of the world
;; RETURNS: the Doodad that should follow the given Doodad after a tick
;; EXAMPLES:
;;   (next-doodad (make-doodad "radial-star" "Gold" 125 120 10 12 #true 0 0 0)
;;                #false) =>
;;     (make-doodad "radial-star" "Gold" 125 120 10 12 #true 0 0 1)
;;   (next-doodad (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)
;;                #false) =>
;;     (make-doodad "radial-star" "Gold" 135 132 10 12 #false 0 0 1)
;; STRATEGY: combine simpler functions
(define (next-doodad dd paused?)
  (if (or (doodad-selected? dd) paused?)
      (make-doodad (doodad-shape dd)
                   (doodad-color dd)
                   (doodad-x dd)
                   (doodad-y dd)
                   (doodad-vx dd)
                   (doodad-vy dd)
                   (doodad-selected? dd)
                   (doodad-mx dd)
                   (doodad-my dd)
                   (+ (doodad-age dd) 1))
      (make-doodad (doodad-shape dd)
                   (if (or (bounce-x? dd) (bounce-y? dd))
                       (next-color dd)
                       (doodad-color dd))
                   (next-x dd)
                   (next-y dd)
                   (next-vx dd)
                   (next-vy dd)
                   (doodad-selected? dd)
                   (doodad-mx dd)
                   (doodad-my dd)
                   (+ (doodad-age dd) 1))))

;; next-doodads : ListOfDoodad Boolean -> ListOfDoodad
;; GIVEN: a ListOfDoodad and the state of the World (world-paused? w)
;; RETURNS: the ListOfDoodad that should follow the given ListOfDoodad
;;   after a tick
;; EXAMPLE:
;;   (next-doodads (world-doodads-star (initial-world 0)))
;;                                    12 #true 0 0 0))
;;                 #true) =>
;;     (list (make-doodad "radial-star" "Gold" 125 120 10 12 #true 0 0 1))
;; STRATEGY: use HOF map on lod
(define (next-doodads lod paused?)
  (map
   ;; Doodad -> Doodad
   ;; GIVEN: a Doodad
   ;; RETURNS: the Doodad that's supposed to follow the given Doodad after a
   ;;   World tick
   (lambda (dd) (next-doodad dd paused?))
   lod))

;; world-after-tick : World -> World
;; GIVEN: any World that's possible for the animation
;; RETURNS: the World that should follow the given World after a tick
;; EXAMPLE:
;;   (world-after-tick (initial-world 0)) =>
;;     (make-world
;;      (list (make-doodad "radial-star" "Gold" 135 132 10 12 #false 0 0 1))
;;      (list (make-doodad "square" "Gray" 447 341 -13 -9 #false 0 0 1))
;;      #false 1 1)
;; STRATEGY: combine simpler functions
(define (world-after-tick w)
  (make-world (next-doodads (world-doodads-star w) (world-paused? w))
              (next-doodads (world-doodads-square w) (world-paused? w))
              (world-paused? w)
              (world-star-vr w)
              (world-square-vr w)))

;; next-vr : Integer -> Integer
;; GIVEN: an Integer representing the number of 90 degree clockwise rotations
;; RETURNS: an Integer representing the number of 90 degree clockwise rotations
;;   on the next doodad
;; EXAMPLES:
;;   (next-vr 0) => 1
;; STRATEGY: combine simpler functions
(define (next-vr rotation)
  (remainder (+ rotation 1) 4))

;; oldest-doodad-age : ListOfDoodad -> Integer
;; GIVEN: a ListOfDoodad
;; RETURNS: the oldest age of the Doodad in the ListOfDoodad
;; EXAMPLES:
;;   (oldest-doodad-age empty) => 0
;;   (oldest-doodad-age
;;    (list
;;     (make-doodad "radial-star" "Blue" 595 176 12 -10 #false 0 0 60)
;;     (make-doodad "radial-star" "Blue" 465 44 -10 -12 #false 0 0 61)
;;     (make-doodad "radial-star" "Gold" 331 396 -12 -10 #false 0 0 62))) => 62
;; STRATEGY: combine simpler functions
(define (oldest-doodad-age lod)
  (if (empty? lod)
      0
      (doodad-age (first (reverse lod)))))

;; remove-doodad-with-age : ListOfDoodad Integer -> ListOfDoodad
;; GIVEN: a ListOfDoodad and an Integer representing the age of Doodad to be
;;   removed
;; RETURNS: a ListOfDoodad similar to the input but after removing the Doodad's
;;   in the input matching the given age
;; EXAMPLE:
;;   (remove-doodad-with-age
;;    (list (make-doodad "radial-star" "Blue" 595 176 12 -10 #false 0 0 60)
;;          (make-doodad "radial-star" "Blue" 465 44 -10 -12 #false 0 0 61)
;;          (make-doodad "radial-star" "Gold" 331 396 -12 -10 #false 0 0 62))
;;    62) =>
;;     (list (make-doodad "radial-star" "Blue" 595 176 12 -10 #false 0 0 60)
;;           (make-doodad "radial-star" "Blue" 465 44 -10 -12 #false 0 0 61))
;; STRATEGY: use HOF filter on lod
(define (remove-doodad-with-age lod age)
  (filter
   ;; Doodad -> Boolean
   ;; Given: a Doodad
   ;; RETURNS: a true if the doodad has the age as the input to
   ;;   remove-doodad-with-age
   (lambda (dd) (not (= (doodad-age dd) age)))
   lod))

;; change-selected-doodad-color : ListOfDoodad -> ListOfDoodad
;; GIVEN: a ListOfDoodad
;; RETURNS: a ListOfDoodad after changing color of selected Doodad's
;;   from the ListOfDoodad given as input
;; EXAMPLE:
;;   (change-selected-doodad-color
;;    (list (make-doodad "radial-star" "Blue" 595 176 12 -10 #true 0 0 60)
;;          (make-doodad "radial-star" "Blue" 465 44 -10 -12 #false 0 0 61))) =>
;;     (list (make-doodad "radial-star" "Gold" 595 176 12 -10 #true 0 0 60)
;;           (make-doodad "radial-star" "Blue" 465 44 -10 -12 #false 0 0 61))
;; STRATEGY: use HOF foldr on lod
(define (change-selected-doodad-color lod)
  (foldr
   ;; Doodad ListOfDoodad -> ListOfDoodad
   ;; GIVEN: a Doodad and a ListOfDoodad
   ;; RETURNS: a ListOfDoodad after adding the Doodad similar
   ;;   to the Input Doodad
   (lambda (dd llod) (cons (if (doodad-selected? dd)
                               (make-doodad (doodad-shape dd) 
                                            (next-color dd)
                                            (doodad-x dd)
                                            (doodad-y dd)
                                            (doodad-vx dd)
                                            (doodad-vy dd)
                                            true
                                            (doodad-mx dd)
                                            (doodad-my dd)
                                            (doodad-age dd))
                                            dd) llod))
   empty lod))

;; world-after-key-event : World KeyEvent -> World
;; GIVEN: a World and a KeyEvent
;; RETURNS: the World that should follow the given World
;;   after the given KeyEvent
;; EXAMPLE:
;;   (world-after-key-event (initial-world 0) " ") =>
;;     (make-world
;;      (list (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
;;      (list (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
;;      #true)
;;   (world-after-key-event (initial-world 0) "t") =>
;;     (make-world
;;      (list
;;       (make-doodad "radial-star" "Gold" 125 120 -12 10 #false 0 0 0)
;;       (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
;;      (list (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
;;      #false)
;; STRATEGY: combine simpler functions
(define (world-after-key-event w ke)
  (cond [(key=? ke " ")
         (make-world (world-doodads-star w)
                     (world-doodads-square w)
                     (not (world-paused? w))
                     (world-star-vr w)
                     (world-square-vr w))]
        [(key=? ke "t")
         (make-world (cons
                      (make-new-doodad "radial-star" (world-star-vr w))
                      (world-doodads-star w))
                     (world-doodads-square w)
                     (world-paused? w)
                     (next-vr (world-star-vr w))
                     (world-square-vr w))]
        [(key=? ke "q")
         (make-world (world-doodads-star w)
                     (cons
                      (make-new-doodad "square" (world-square-vr w))
                      (world-doodads-square w))
                     (world-paused? w)
                     (world-star-vr w)
                     (next-vr (world-square-vr w)))]
        [(key=? ke ".")
         (make-world
          (remove-doodad-with-age (world-doodads-star w)
                                  (oldest-doodad-age (world-doodads-star w)))
          (remove-doodad-with-age (world-doodads-square w)
                                  (oldest-doodad-age (world-doodads-square w)))
          (world-paused? w)
          (world-star-vr w)
          (world-square-vr w))]
        [(key=? ke "c")
         (make-world (change-selected-doodad-color (world-doodads-star w))
                     (change-selected-doodad-color (world-doodads-square w))
                     (world-paused? w)
                     (world-star-vr w)
                     (world-square-vr w))]
        [else w]))

;; in-doodad? : Doodad Integer Integer -> Boolean
;; GIVEN: a Doodad and an x and y coordinate of the mouse event
;; RETURNS: true if the x and y coordinate lies in the circular area whose
;;   radius is equal to the outer radius of the star if the BasicShape is
;;   "radial-star" or inside the square in case of the Doodad with BasicShape
;;   "square"
;; EXAMPLES:
;;   (in-doodad? (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)
;;               135 132) => #true
;;   (in-doodad? (make-doodad "square" "Gray" 460 350 -13 -9 false 0 0)
;;               135 132) => false
;; STRATEGY: combine simpler functions
(define (in-doodad? dd mx my)
  (if (string=? (doodad-shape dd) "radial-star")
      (<= (sqrt (+ (sqr (- mx (doodad-x dd))) (sqr (- my (doodad-y dd)))))
          RADIAL-STAR-OUTER-RADIUS)
      (and (<= (- (doodad-x dd) HALF-SQUARE-SIDE-LEN)
               mx
               (+ (doodad-x dd) HALF-SQUARE-SIDE-LEN))
           (<= (- (doodad-y dd) HALF-SQUARE-SIDE-LEN)
               my
               (+ (doodad-y dd) HALF-SQUARE-SIDE-LEN)))))

;; doodad-after-button-down : Doodad Integer Integer -> Doodad
;; GIVEN: a Doodad and an x and y coordinate of the mouse event
;; RETURNS: a Doodad similar to input Doodad with updated selected?, mx and my
;; EXAMPLES:
;;   (doodad-after-button-down
;;    (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0) 135 132) =>
;;     (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0)
;;   (doodad-after-button-down
;;    (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0) 100 100) =>
;;     (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0)
;; STRATEGY: combine simpler functions
(define (doodad-after-button-down dd mx my)
  (if (in-doodad? dd mx my)
      (make-doodad (doodad-shape dd)
                   (doodad-color dd)
                   (doodad-x dd)
                   (doodad-y dd)
                   (doodad-vx dd)
                   (doodad-vy dd)
                   true
                   (- mx (doodad-x dd))
                   (- my (doodad-y dd))
                   (doodad-age dd))
      dd))

;; doodad-after-drag : Doodad Integer Integer -> Doodad
;; GIVEN: a Doodad and an x and y coordinate of the mouse event
;; WHERE: the Doodad is Selected
;; RETURNS: a Doodad similar to input Doodad with updated x and y
;; EXAMPLES:
;;   (doodad-after-drag
;;    (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0) 140 140) =>
;;     (make-doodad "radial-star" "Gold" 130 128 10 12 #true 10 12 0)
;;   (doodad-after-drag
;;    (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0) 100 100) =>
;;     (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0)
;; STRATEGY: combine simpler functions
(define (doodad-after-drag dd mx my)
  (if (doodad-selected? dd)
      (make-doodad (doodad-shape dd)
                   (doodad-color dd)
                   (- mx (doodad-mx dd))
                   (- my (doodad-my dd))
                   (doodad-vx dd)
                   (doodad-vy dd)
                   true
                   (doodad-mx dd)
                   (doodad-my dd)
                   (doodad-age dd))
      dd))

;; doodad-after-button-up : Doodad Integer Integer -> Doodad
;; GIVEN: a Doodad and an x and y coordinate of the mouse event
;; RETURNS: a Doodad similar to input Doodad with updated selected?, mx and my
;; EXAMPLES:
;;   (doodad-after-button-up
;;    (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0) 140 140) =>
;;     (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)
;;   (doodad-after-button-up
;;    (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0) 100 100) =>
;;     (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0)
;; STRATEGY: combine simpler functions
(define (doodad-after-button-up dd mx my)
  (if (doodad-selected? dd)
      (make-doodad (doodad-shape dd)
                   (doodad-color dd)
                   (doodad-x dd)
                   (doodad-y dd)
                   (doodad-vx dd)
                   (doodad-vy dd)
                   false 0 0
                   (doodad-age dd))
      dd))

;; doodad-after-mouse-event : Doodad Integer Integer MouseEvent -> Doodad
;; GIVEN: A Doodad, the x- and y-coordinates of a mouse event,
;;   and the mouse event
;; RETURNS: the Doodad that should follow the given Doodad after the given
;;   mouse event
;; EXAMPLES:
;;   (doodad-after-mouse-event
;;    (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)
;;    135 132 "button-down") =>
;;     (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0)
;;   (doodad-after-mouse-event
;;    (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0)
;;    140 140 "drag") =>
;;     (make-doodad "radial-star" "Gold" 130 128 10 12 #true 10 12 0)
;; STRATEGY: combine simpler functions
(define (doodad-after-mouse-event dd mx my me)
  (cond [(mouse=? me "button-down") (doodad-after-button-down dd mx my)]
        [(mouse=? me "drag") (doodad-after-drag dd mx my)]
        [(mouse=? me "button-up") (doodad-after-button-up dd mx my)]
        [else dd]))

;; doodads-after-mouse-event : ListOfDoodad Integer Integer MouseEvent ->
;;   ListOfDoodad
;; GIVEN: a ListOfDoodad
;; RETURNS: a ListOfDoodad similar to the input ListOfDoodad's after the
;;   changing Doodad's affected by the MouseEvent
;; EXAMPLE:
;;   (doodads-after-mouse-event
;;    (list (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
;;    135 132 "button-down") =>
;;     (list (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0))
;; STRATEGY: use HOF map on lod
(define (doodads-after-mouse-event lod mx my me)
  (map
   ;; Doodad -> Doodad
   ;; GIVEN: a Doodad
   ;; RETURNS: a Doodad similar to the Input but with modifications based on
   ;;   on the MouseEvent
   (lambda (dd) (doodad-after-mouse-event dd mx my me))
   lod))

;; world-after-mouse-event : World Integer Integer MouseEvent -> World
;; GIVEN: A world, the x- and y-coordinates of a mouse event,
;;   and the mouse event
;; RETURNS: the world that should follow the given world after the
;;   given mouse event
;; EXAMPLE:
;;   (world-after-mouse-event (initial-world 0) 1 1 "button-down") =>
;;     (make-world
;;      (list (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
;;      (list (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
;;      #false 1 1)
;; STRATEGY: combine simpler functions
(define (world-after-mouse-event w mx my me)
  (make-world (doodads-after-mouse-event (world-doodads-star w) mx my me)
              (doodads-after-mouse-event (world-doodads-square w) mx my me)
              (world-paused? w)
              (world-star-vr w)
              (world-square-vr w)))

;; doodad-to-image : Doodad -> Image
;; GIVEN: a Doodad
;; RETURNS: the Image that portays the given Doodad
;; EXAMPLES:
;;   (doodad-to-image
;;    (make-doodad "radial-star" "Gold" 125 120 10 12 #true 5 10 0)) =>
;;     (underlay/offset (radial-star 8 10 50 "solid" "Gold")
;;                      5 10 MOUSE-MARKER)
;;   (doodad-to-image
;;    (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)) =>
;;     (radial-star 8 10 50 "solid" "Gold")
;; STRATEGY: combine simpler functions
(define (doodad-to-image dd)
  (if (doodad-selected? dd)
      (underlay/offset (if (string=? (doodad-shape dd) "radial-star")
                           (radial-star RADIAL-STAR-POINT-COUNT
                                        RADIAL-STAR-INNER-RADIUS
                                        RADIAL-STAR-OUTER-RADIUS
                                        DOODAD-MODE
                                        (doodad-color dd))
                           (square SQUARE-SIDE-LEN
                                   DOODAD-MODE
                                   (doodad-color dd)))
                       (doodad-mx dd)
                       (doodad-my dd)
                       MOUSE-MARKER)
      (if (string=? (doodad-shape dd) "radial-star")
          (radial-star RADIAL-STAR-POINT-COUNT
                       RADIAL-STAR-INNER-RADIUS
                       RADIAL-STAR-OUTER-RADIUS
                       DOODAD-MODE
                       (doodad-color dd))
          (square SQUARE-SIDE-LEN DOODAD-MODE (doodad-color dd)))))

;; doodads-to-images : ListOfDoodad -> ListOfImages
;; GIVEN: a ListOfDoodad
;; RETURNS: a list of images representing a the ListOfDoodad given as Input
;; EXAMPLE:
;;   (doodads-to-images
;;    (list (make-doodad "radial-star" "Gold" 125 120 10 12 #true 5 10 0))) =>
;;     (list (underlay/offset
;;            (radial-star 8 10 50 "solid" "Gold") 5 10 MOUSE-MARKER))
;; STRATEGY: use HOF map on lod
(define (doodads-to-images lod)
  (map
   ;; Doodad -> Image
   ;; GIVEN: a Doodad
   ;; RETURNS: an Image representing the Doodad
   (lambda (dd) (doodad-to-image dd))
   lod))

;; doodads-to-posn : ListOfDoodad -> ListOfPosn
;; GIVEN: a ListOfDoodad
;; RETURNS: a list of posn representing location of the ListOfDoodad
;;   given as Input
;; EXAMPLE:
;;   (doodads-to-posn
;;    (list (make-doodad "radial-star" "Gold" 125 120 10 12 #true 5 10 0))) =>
;;     (list (make-posn 125 120))
;; STRATEGY: use HOF map on lod
(define (doodads-to-posn lod)
  (map
   ;; Doodad -> Posn
   ;; GIVEN: a Doodad
   ;; RETURNS: a Posn representing the Center of Doodad
   (lambda (dd) (make-posn (doodad-x dd) (doodad-y dd)))
   lod))

;; world-to-scene : World -> Scene
;; GIVEN: a World
;; RETURNS: a Scene that portrays the given world
;; EXAMPLE:
;;   (world-to-scene (initial-world 0)) =>
;;     (place-image (radial-star 8 10 50 "solid" "Gold")
;;                  125 120
;;                  (place-image (square 71 "solid" "Gray")
;;                               460 350
;;                               ANIMATION-WINDOW))
;; STRATEGY: combine simpler functions
(define (world-to-scene w)
  (place-images (doodads-to-images (append (world-doodads-star w)
                                           (world-doodads-square w)))
                (doodads-to-posn (append (world-doodads-star w)
                                          (world-doodads-square w)))
                ANIMATION-WINDOW))
   
;; animation : PosReal -> World
;; GIVEN: the speed of the animation, in seconds per tick
;;     (so larger numbers run slower)
;; EFFECT: runs the animation, starting with the initial world as
;;     specified in the problem set
;; RETURNS: the final state of the world
;; EXAMPLES:
;;   (animation 1) runs the animation at normal speed
;;   (animation 1/4) runs at a faster than normal speed
(define (animation ts)
  (big-bang (initial-world 0)
            (on-tick world-after-tick ts)
            (on-key world-after-key-event)
            (on-mouse world-after-mouse-event)
            (on-draw world-to-scene)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TESTS

(begin-for-test

  ;; rotate-velocity
  (check-equal? (rotate-velocity (make-posn -13 -9) 0)
                (make-posn -13 -9)
                "Should've returned the same Posn as input")
  (check-equal? (rotate-velocity (make-posn -13 -9) 1)
                (make-posn 9 -13)
                "Should've returned the initial Posn rotated once")

  ;; make-new-doodad
  (check-equal? (make-new-doodad "radial-star" 0)
                (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)
                "New Star Doodad with Initial values should've been created")
  (check-equal? (make-new-doodad "square" 0)
                (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0)
                "New Square Doodad with Initial values should've been created")

  ;; initial-world
  (check-equal? (initial-world -174)
                (make-world
                 (list (make-doodad "radial-star" "Gold" 125 120 10 12
                                    #false 0 0 0))
                 (list (make-doodad "square" "Gray" 460 350 -13 -9
                                    #false 0 0 0))
                 #false 1 1)
                "initial-world created incorrectly")

  ;; bounce-x?
  (check-equal? (bounce-x?
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                #false
                "Core bounce detected when there isn't one in x")
  (check-equal? (bounce-x?
                 (make-doodad "square" "Gray" 0 350 -13 -9 #false 0 0 0))
                #true
                "Core bounce not detected in x")

  ;; bounce-y?
  (check-equal? (bounce-y?
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                #false
                "Core bounce detected when there isn't one in y")
  (check-equal? (bounce-y?
                 (make-doodad "square" "Gray" 460 0 -13 -9 #false 0 0 0))
                #true
                "Core bounce not detected in y")

  ;; next-color
  (check-equal? (next-color
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                "Green"
                "Should've returned Green for Gold Star Doodad")
  (check-equal? (next-color
                 (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
                "OliveDrab"
                "Should've returned OliveDrab for Gray Square Doodad")
  ;; ADDITIONAL
  (check-equal? (next-color
                 (make-doodad "radial-star" "Green" 125 120 10 12 #false 0 0 0))
                "Blue"
                "Should've returned Blue for Green Star Doodad")
  (check-equal? (next-color
                 (make-doodad "radial-star" "Blue" 125 120 10 12 #false 0 0 0))
                "Gold"
                "Should've returned Gold for Blue Star Doodad")
  (check-equal? (next-color
                 (make-doodad "square" "OliveDrab" 460 350 -13 -9 #false 0 0 0))
                "Khaki"
                "Should've returned Khaki for OliveDrab Square Doodad")
  (check-equal? (next-color
                 (make-doodad "square" "Khaki" 460 350 -13 -9 #false 0 0 0))
                "Orange"
                "Should've returned Orange for Khaki Square Doodad")
  (check-equal? (next-color
                 (make-doodad "square" "Orange" 460 350 -13 -9 #false 0 0 0))
                "Crimson"
                "Should've returned Crimson for Orange Square Doodad")
  (check-equal? (next-color
                 (make-doodad "square" "Crimson" 460 350 -13 -9 #false 0 0 0))
                "Gray"
                "Should've returned Gray for Crimson Square Doodad")

  ;; next-x
  (check-equal? (next-x
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                135
                "Should've returned the updated x coordinate after adding vx")
  (check-equal? (next-x (make-doodad "square" "Gray" 0 350 -13 -9 #false 0 0 0))
                13
                "Should've returned the updated negated x coordinate after
adding vx")
  ;; ADDITIONAL
  (check-equal? (next-x
                 (make-doodad "radial-star" "Gold" 601 120 10 12 #false 0 0 0))
                589
                "Should've returned the updated x coordinate after adding vx
and subtracting x window length")

  ;; next-y
  (check-equal? (next-y
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                132
                "Should've returned the updated y coordinate after adding vy")
  (check-equal? (next-y (make-doodad "square" "Gray" 460 0 -13 -9 #false 0 0 0))
                9
                "Should've returned the updated negated y coordinate after
adding vy")
  ;; ADDITIONAL
  (check-equal? (next-y
                 (make-doodad "radial-star" "Gold" 125 441 10 12 #false 0 0 0))
                443
                "Should've returned the updated y coordinate after adding vy")

  ;; next-vx
  (check-equal? (next-vx
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                10
                "Should've returned same vx velocity as input")
  (check-equal? (next-vx
                 (make-doodad "square" "Gray" 0 350 -13 -9 #false 0 0 0))
                13
                "Should've returned negated velocity of vx")

  ;; next-vy
  (check-equal? (next-vy
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                12
                "Should've returned same vy velocity as input")
  (check-equal? (next-vy
                 (make-doodad "square" "Gray" 460 0 -13 -9 #false 0 0 0))
                9
                "Should've returned negated velocity of vy")

  ;; next-doodad
  (check-equal? (next-doodad (make-doodad "radial-star" "Gold" 125 120 10 12
                                          #true 0 0 0)
                             #false)
                (make-doodad "radial-star" "Gold" 125 120 10 12 #true 0 0 1)
                "Should've returned the same doodad")
  (check-equal? (next-doodad (make-doodad "radial-star" "Gold" 125 120 10 12
                                          #false 0 0 0) #false)
                (make-doodad "radial-star" "Gold" 135 132 10 12 #false 0 0 1)
                "Should've returned the doodad with incremented age")
  ;; ADDITIONAL
  (check-equal? (next-doodad (make-doodad "radial-star" "Gold" 125 120 10 12
                                          #false 0 0 0) #true)
                (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 1)
                "Should've returned the doodad with incremented age")
  (check-equal? (next-doodad (make-doodad "radial-star" "Gold" 601 120 10 12
                                          #false 0 0 0) #false)
                (make-doodad "radial-star" "Green" 589 132 -10 12 #false 0 0 1)
                "Should've returned the doodad with incremented age and next
color")
  (check-equal? (next-doodad (make-doodad "radial-star" "Gold" 125 441 10 12
                                          #false 0 0 0) #false)
                (make-doodad "radial-star" "Green" 135 443 10 -12 #false 0 0 1)
                "Should've returned the doodad with incremented age and next
color")

  ;; next-doodads
  (check-equal? (next-doodads (world-doodads-star (initial-world 0)) #true)
                (list
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 1))
                "Should've returned a list of Doodad with incremented age")

  ;; world-after-tick
  (check-equal? (world-after-tick (initial-world 0))
                (make-world
                 (list
                  (make-doodad "radial-star" "Gold" 135 132 10 12 #false 0 0 1))
                 (list
                  (make-doodad "square" "Gray" 447 341 -13 -9 #false 0 0 1))
                 #false 1 1)
                "inital world after tick should've been returned")

  ;; next-vr
  (check-equal? (next-vr 0)
                1
                "Wrong remainder on divisiblity by 4")

  ;; oldest-doodad-age
  (check-equal? (oldest-doodad-age empty) 0
                "0 should be returned when empty list is given as input")
  (check-equal? (oldest-doodad-age
                 (list (make-doodad "radial-star" "Blue" 595 176 12 -10
                                    #false 0 0 60)
                       (make-doodad "radial-star" "Blue" 465 44 -10 -12
                                    #false 0 0 61)
                       (make-doodad "radial-star" "Gold" 331 396 -12 -10
                                    #false 0 0 62)))
                62
                "Oldest age of the list of Doodad should've been returned")

  ;; remove-doodad-with-age
  (check-equal? (remove-doodad-with-age
                 (list
                  (make-doodad "radial-star" "Blue" 595 176 12 -10
                               #false 0 0 60)
                  (make-doodad "radial-star" "Blue" 465 44 -10 -12
                               #false 0 0 61)
                  (make-doodad "radial-star" "Gold" 331 396 -12 -10
                               #false 0 0 62))
                 62)
                (list
                 (make-doodad "radial-star" "Blue" 595 176 12 -10
                              #false 0 0 60)
                 (make-doodad "radial-star" "Blue" 465 44 -10 -12
                              #false 0 0 61))
                "Doodads with specified age should've been removed")

  ;; change-selected-doodad-color
  (check-equal? (change-selected-doodad-color
                 (list
                  (make-doodad "radial-star" "Blue" 595 176 12 -10 #true 0 0 60)
                  (make-doodad "radial-star" "Blue" 465 44 -10 -12
                               #false 0 0 61)))
                (list
                 (make-doodad "radial-star" "Gold" 595 176 12 -10 #true 0 0 60)
                 (make-doodad "radial-star" "Blue" 465 44 -10 -12
                              #false 0 0 61))
                "Selected Doodad colors should've been changed")

  ;; world-after-key-event
  (check-equal? (world-after-key-event (initial-world 0) " ")
                (make-world
                 (list
                  (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                 (list
                  (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
                 #true 1 1)
                "world should be paused on KeyEvent SPACE")
  (check-equal? (world-after-key-event (initial-world 0) "t")
                (make-world
                 (list
                  (make-doodad "radial-star" "Gold" 125 120 -12 10 #false 0 0 0)
                  (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                 (list
                  (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
                 #false 2 1)
                "a new star should be added to the world on KeyEvent q")
  ;; ADDITIONAL
  (check-equal? (world-after-key-event (initial-world 0) "q")
                (make-world
                 (list
                  (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                 (list
                  (make-doodad "square" "Gray" 460 350 9 -13 #false 0 0 0)
                  (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
                 #false 1 2)
                "a new square should be added to the world on KeyEvent q")
  (check-equal? (world-after-key-event (initial-world 0) ".")
                (make-world empty empty #false 1 1)
                "world should be empty on deleting Doodads from initial world")
  (check-equal? (world-after-key-event (initial-world 0) "c")
                (make-world
                 (list (make-doodad "radial-star" "Gold" 125 120 10 12
                                    #false 0 0 0))
                 (list (make-doodad "square" "Gray" 460 350 -13 -9
                                    #false 0 0 0))
                 #false 1 1)
                "Color of Unselected Doodads should not change for KeyEvent c")
  (check-equal? (world-after-key-event (initial-world 0) "!")
                (make-world
                 (list
                  (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                 (list
                  (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
                 #false 1 1)
                "world should be un-altered for ! KeyEvent")

  ;; in-doodad?
  (check-equal? (in-doodad?
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)
                 135 132)
                #true
                "Should return true as Posn is in Doodad")
  (check-equal? (in-doodad?
                 (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0)
                 100 100)
                #false
                "Should return false as Posn is in Doodad")
  (check-equal? (in-doodad?
                 (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0)
                 450 325)
                #true
                "Should return true as Posn is in Doodad")

  ;; doodad-after-button-down
  (check-equal? (doodad-after-button-down
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)
                 135 132)
                (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0)
                "Selected Doodad should be altered for button-down")
  (check-equal? (doodad-after-button-down
                 (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0)
                 100 100)
                (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0)
                "Doodad should be un-altered for button-down when not selected")

  ;; doodad-after-drag
  (check-equal? (doodad-after-drag
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0)
                 140 140)
                (make-doodad "radial-star" "Gold" 130 128 10 12 #true 10 12 0)
                "Selected Doodad should be altered when dragged")
  (check-equal? (doodad-after-drag
                 (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0)
                 100 100)
                (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0)
                "Doodads not selected should be un-altered when draged")

  ;; doodad-after-button-up
  (check-equal? (doodad-after-button-up
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0)
                 140 140)
                (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)
                "Doodad should be altered for button-up when inside Doodad")
  (check-equal? (doodad-after-button-up
                 (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0)
                 100 100)
                (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0)
                "Doodad should be un-altered for button-up when outside Doodad")

  ;; doodad-after-mouse-event
  (check-equal? (doodad-after-mouse-event
                 (make-doodad "radial-star" "Gold" 125 120 10 12
                              #false 0 0 0) 135 132 "button-down")
                (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0)
                "Doodad should be affected for button-down event is on Doodad")
  (check-equal? (doodad-after-mouse-event
                 (make-doodad "radial-star" "Gold" 125 120 10 12
                              #true 10 12 0) 140 140 "drag")
                (make-doodad "radial-star" "Gold" 130 128 10 12 #true 10 12 0)
                "Doodad x & y should change when draged")
  ;; ADDITIONAL
  (check-equal? (doodad-after-mouse-event
                 (make-doodad "radial-star" "Gold" 125 120 10 12
                              #true 10 12 0) 140 140 "button-up")
                (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)
                "Selected Doodad should be affected for the button-up event")
  (check-equal? (doodad-after-mouse-event
                 (make-doodad "radial-star" "Gold" 125 120 10 12
                              #true 10 12 0) 140 140 "move")
                (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0)
                "Selected Doodad should be un-altered for move MouseEvent")

  ;; doodads-after-mouse-event
  (check-equal? (doodads-after-mouse-event
                 (list (make-doodad "radial-star" "Gold" 125 120 10 12
                                    #false 0 0 0)) 135 132 "button-down")
                (list (make-doodad "radial-star" "Gold" 125 120 10 12
                                   #true 10 12 0))
                "Selected Doodad should be affected for the button-down event")

  ;; world-after-mouse-event
  (check-equal? (world-after-mouse-event (initial-world 0) 1 1 "button-down")
                (make-world
                 (list (make-doodad "radial-star" "Gold" 125 120 10 12
                                    #false 0 0 0))
                 (list (make-doodad "square" "Gray" 460 350 -13 -9
                                    #false 0 0 0))
                 #false 1 1)
                "new world should be un-altered for the button-down action")

  ;; doodad-to-image
  (check-equal? (doodad-to-image
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #true 5 10 0))
                (underlay/offset (radial-star 8 10 50 "solid" "Gold")
                                 5 10 MOUSE-MARKER)
                "image differs from the selected star doodad")
  (check-equal? (doodad-to-image
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                (radial-star 8 10 50 "solid" "Gold")
                "image differs from the star doodad")
  ;; ADDITIONAL
  (check-equal? (doodad-to-image
                 (make-doodad "square" "Gray" 460 350 -13 -9 #true 5 10 0))
                (underlay/offset (square 71 "solid" "Gray")
                                 5 10 MOUSE-MARKER)
                "image differs from the selected square doodad")
  (check-equal? (doodad-to-image
                 (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
                (square 71 "solid" "Gray")
                "image differs from the square doodad")

  ;; doodads-to-images
  (check-equal? (doodads-to-images
                 (list
                  (make-doodad "radial-star" "Gold" 125 120 10 12
                               #true 5 10 0)))
                (list (underlay/offset (radial-star 8 10 50 "solid" "Gold")
                                       5 10 MOUSE-MARKER))
                "image differs from the selected star doodad")

  ;; doodads-to-posn
  (check-equal? (doodads-to-posn
                 (list
                  (make-doodad "radial-star" "Gold" 125 120 10 12
                               #true 5 10 0)))
                (list (make-posn 125 120))
                "list of Posn of list of Doodad don't match")
  
  ;; world-to-scene
  (check-equal? (world-to-scene (initial-world 0))
                (place-image (radial-star 8 10 50 "solid" "Gold")
                             125 120
                             (place-image (square 71 "solid" "Gray")
                                          460 350
                                          ANIMATION-WINDOW))
                "intial workd to scene not as expected"))