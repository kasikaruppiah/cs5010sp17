;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require "extras.rkt")
(require rackunit)

(require 2htdp/image)
(require 2htdp/universe)

(provide doodad-color
         doodad-x
         doodad-y
         doodad-vx
         doodad-vy
         world-doodad-star
         world-doodad-square
         world-paused?
         initial-world
         world-after-tick
         world-after-key-event
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

(define-struct doodad (shape color x y vx vy))
;; A Doodad is a structure:
;;   (make-doodad BasicShape Color Integer Integer Integer Integer)
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
   (doodad-vy dd)))
|#

(define-struct world (doodad-star doodad-square paused?))
;; A World is a structure:
;;   (make-world Doodad Doodad Boolean)
;; Interpretation:
;;   doodad-star is a Doodad representing radial-star
;;   doodad-square is a Doodad representing square
;;   paused? describes whether or not the world is paused
;; TEMPLATE:
;;   world-fn : World -> ??
#|
(define (world-fn w)
  (...
   (world-doodad-star w)
   (world-doodad-square w)
   (world-paused? w)))
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
;; mode of doodad basic shape
(define DOODAD-MODE "solid")
;; starting color radial-star
(define RADIAL-STAR-STARTING-COLOR "Gold")
;; starting color square
(define SQUARE-STARTING-COLOR "Gray")
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; FUNCTIONS

;; initial-world : Any -> World
;; GIVEN: any value (ignored)
;; RETURNS: the initial World specified for the animation
;; EXAMPLE:
;;   (initial-world -174) = (make-world
;;                           (make-doodad "radial-star" "Gold" 125 120 10 12)
;;                           (make-doodad "square" "Gray" 460 350 -13 -9)
;;                           #false)
;;   (initial-world "a") = (make-world
;;                           (make-doodad "radial-star" "Gold" 125 120 10 12)
;;                           (make-doodad "square" "Gray" 460 350 -13 -9)
;;                           #false)
;; STRATEGY: combine simpler functions
(define (initial-world ip)
  (make-world (make-doodad "radial-star"
                           RADIAL-STAR-STARTING-COLOR
                           (posn-x RADIAL-STAR-INITIAL-CENTER)
                           (posn-y RADIAL-STAR-INITIAL-CENTER)
                           RADIAL-STAR-INITIAL-VX
                           RADIAL-STAR-INITIAL-VY)
              (make-doodad "square"
                           SQUARE-STARTING-COLOR
                           (posn-x SQUARE-INITIAL-CENTER)
                           (posn-y SQUARE-INITIAL-CENTER)
                           SQUARE-INITIAL-VX
                           SQUARE-INITIAL-VY)
              false))

;; bounce-x? : Doodad -> Boolean
;; GIVEN: a Doodad
;; RETURNS: true if the tentative x position of the Doodad is negative or
;;   is greater than or equal to the animation window width
;; EXAMPLE:
;;   (bounce-x? (make-doodad "radial-star" "Gold" 125 120 10 12)) = false
;;   (bounce-x? (make-doodad "square" "Gray" 5 350 -13 -9) = true
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
;; EXAMPLE:
;;   (bounce-y? (make-doodad "radial-star" "Gold" 125 120 10 12)) = false
;;   (bounce-y? (make-doodad "square" "Gray" 125 1 -13 -9)) = true
;; STRATEGY: combine simpler functions
(define (bounce-y? dd)
  (if (and (>= (+ (doodad-y dd) (doodad-vy dd)) 0)
           (< (+ (doodad-y dd) (doodad-vy dd)) ANIMATION-WINDOW-HEIGHT))
      false
      true))

;; next-color : Doodad -> Color
;; GIVEN: a Doodad
;; RETURNS: the color of the Doodad at its next position
;; EXAMPLE:
;;   (next-color (make-doodad "radial-star" "Gold" 125 120 10 12)) = "Gold"
;;   (next-color (make-doodad "square" "OliveDrab" 5 350 -13 -9)) = "Khaki"
;; STRATEGY: combine simpler functions
(define (next-color dd)
  (if (or (bounce-x? dd) (bounce-y? dd))
      (if (string=? (doodad-shape dd) "radial-star")
          (cond [(string=? (doodad-color dd) "Gold") "Green"]
                [(string=? (doodad-color dd) "Green") "Blue"]
                [else "Gold"])
          (cond [(string=? (doodad-color dd) "Gray") "OliveDrab"]
                [(string=? (doodad-color dd) "OliveDrab") "Khaki"]
                [(string=? (doodad-color dd) "Khaki") "Orange"]
                [(string=? (doodad-color dd) "Orange") "Crimson"]
                [else "Gray"]))
      (doodad-color dd)))

;; next-x : Doodad -> Integer
;; GIVEN: a Doodad
;; RETURNS: the next x position of the Doodad
;; EXAMPLE:
;;   (next-x (make-doodad "radial-star" "Gold" 125 120 10 12)) = 135
;;   (next-x (make-doodad "square" "Gray" 5 350 -13 -9)) = 8
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
;; EXAMPLE:
;;   (next-y (make-doodad "radial-star" "Gold" 125 120 10 12)) = 132
;;   (next-y (make-doodad "square" "Gray" 460 3 -13 -9)) = 6
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
;; EXAMPLE:
;;   (next-vx (make-doodad "radial-star" "Gold" 5 120 -10 12)) = 10
;;   (next-vx (make-doodad "square" "Gray" 447 341 -13 -9)) = -13
;; STRATEGY: combine simpler functions
(define (next-vx dd)
  (if (bounce-x? dd)
      (- (doodad-vx dd))
      (doodad-vx dd)))

;; next-vy : Doodad -> Integer
;; GIVEN: a Doodad
;; RETURNS: the next vy, number of pixels the doodad moves on
;;   each tick in the y direction
;; EXAMPLE:
;;   (next-vy (make-doodad "radial-star" "Gold" 125 1 -10 -12)) = 12
;;   (next-vy (make-doodad "square" "Gray" 460 350 -13 -9)) = -9
;; STRATEGY: combine simpler functions
(define (next-vy dd)
  (if (bounce-y? dd)
      (- (doodad-vy dd))
      (doodad-vy dd)))

;; next-doodad : Doodad -> Doodad
;; GIVEN: a Doodad
;; RETURNS: the Doodad that should follow the given Doodad after a tick
;; EXAMPLE:
;;   (next-doodad (make-doodad "radial-star" "Gold" 125 120 10 12)) =
;;     (make-doodad "radial-star" "Gold" 135 132 10 12)
;;   (next-doodad (make-doodad "square" "Gray" 460 350 -13 -9)) =
;;     (make-doodad "square" "Gray" 447 341 -13 -9)
;; STRATEGY: combine simpler functions
(define (next-doodad dd)
  (make-doodad (doodad-shape dd)
               (next-color dd)
               (next-x dd)
               (next-y dd)
               (next-vx dd)
               (next-vy dd)))

;; world-after-tick : World -> World
;; GIVEN: any World that's possible for the animation
;; RETURNS: the World that should follow the given World after a tick
;; EXAMPLE:
;;   (world-after-tick (initial-world 0)) =
;;     (make-world (make-doodad "radial-star" "Gold" 135 132 10 12)
;;                 (make-doodad "square" "Gray" 447 341 -13 -9)
;;                 #false)
;;   (world-after-tick (world-after-tick (initial-world 0))) =
;;     (make-world (make-doodad "radial-star" "Gold" 145 144 10 12)
;;                 (make-doodad "square" "Gray" 434 332 -13 -9)
;;                 #false)
;; STRATEGY: combine simpler functions
(define (world-after-tick w)
  (if (world-paused? w)
      w
      (make-world (next-doodad (world-doodad-star w))
                  (next-doodad (world-doodad-square w))
                  (world-paused? w))))

;; world-after-key-event : World KeyEvent -> World
;; GIVEN: a World and a KeyEvent
;; RETURNS: the World that should follow the given World
;;   after the given KeyEvent
;; EXAMPLE:
;;   (world-after-key-event (initial-world 0) "a") =
;;     (make-world (make-doodad "radial-star" "Gold" 125 120 10 12)
;;                 (make-doodad "square" "Gray" 460 350 -13 -9)
;;                 #false)
;;   (world-after-key-event (initial-world 0) " ") =
;;     (make-world (make-doodad "radial-star" "Gold" 125 120 10 12)
;;                 (make-doodad "square" "Gray" 460 350 -13 -9)
;;                 #true)
;; STRATEGY: combine simpler functions
(define (world-after-key-event w ke)
  (if (key=? ke " ")
      (make-world (world-doodad-star w)
                  (world-doodad-square w)
                  (not (world-paused? w)))
      w))

;; doodad-to-image : Doodad -> Image
;; GIVEN: a Doodad
;; RETURNS: the Image that portays the given Doodad
;; EXAMPLE:
;;   (doodad-to-image (make-doodad "radial-star" "Gold" 135 132 10 12)) =
;;     (radial-star 8 10 50 "solid" "Gold")
;;   (doodad-to-image (make-doodad "square" "Gray" 460 350 -13 -9)) =
;;     (square 71 "solid" "Gray")
;; STRATEGY: combine simpler functions
(define (doodad-to-image dd)
  (if (string=? (doodad-shape dd) "radial-star")
      (radial-star RADIAL-STAR-POINT-COUNT
                   RADIAL-STAR-INNER-RADIUS
                   RADIAL-STAR-OUTER-RADIUS
                   DOODAD-MODE
                   (doodad-color dd))
      (square SQUARE-SIDE-LEN DOODAD-MODE (doodad-color dd))))

;; world-to-scene : World -> Scene
;; GIVEN: a World
;; RETURNS: a Scene that portrays the given world
;; EXAMPLE:
;;   (world-to-scene (initial-world 0)) =
;;     (place-image (radial-star 8 10 50 "solid" "Gold")
;;                  125 120
;;                  (place-image (square 71 "solid" "Gray")
;;                               460 350
;;                               ANIMATION-WINDOW))
;; STRATEGY: combine simpler functions
(define (world-to-scene w)
  (place-image (doodad-to-image (world-doodad-star w))
               (doodad-x (world-doodad-star w))
               (doodad-y (world-doodad-star w))
               (place-image (doodad-to-image (world-doodad-square w))
                            (doodad-x (world-doodad-square w))
                            (doodad-y (world-doodad-square w))
                            ANIMATION-WINDOW)))

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
            (on-draw world-to-scene)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TESTS

;; EXAMPLES
(begin-for-test
  (check-equal? (initial-world -174)
                (make-world (make-doodad "radial-star" "Gold" 125 120 10 12)
                            (make-doodad "square" "Gray" 460 350 -13 -9)
                            #false))
  (check-equal? (initial-world "a")
                (make-world (make-doodad "radial-star" "Gold" 125 120 10 12)
                            (make-doodad "square" "Gray" 460 350 -13 -9)
                            #false))
  (check-equal? (bounce-x? (make-doodad "radial-star" "Gold" 125 120 10 12))
                false)
  (check-equal? (bounce-x? (make-doodad "square" "Gray" 5 350 -13 -9))
                true)
  (check-equal? (bounce-y? (make-doodad "radial-star" "Gold" 125 120 10 12))
                false)
  (check-equal? (bounce-y? (make-doodad "square" "Gray" 125 1 -13 -9))
                true)
  (check-equal? (next-color (make-doodad "radial-star" "Gold" 125 120 10 12))
                "Gold")
  (check-equal? (next-color (make-doodad "square" "OliveDrab" 5 350 -13 -9))
                "Khaki")
  (check-equal? (next-x (make-doodad "radial-star" "Gold" 125 120 10 12))
                135)
  (check-equal? (next-x (make-doodad "square" "Gray" 5 350 -13 -9))
                8)
  (check-equal? (next-y (make-doodad "radial-star" "Gold" 125 120 10 12))
                132)
  (check-equal? (next-y (make-doodad "square" "Gray" 460 3 -13 -9))
                6)
  (check-equal? (next-vx (make-doodad "radial-star" "Gold" 5 120 -10 12))
                10)
  (check-equal? (next-vx (make-doodad "square" "Gray" 447 341 -13 -9))
                -13)
  (check-equal? (next-vy (make-doodad "radial-star" "Gold" 125 1 -10 -12))
                12)
  (check-equal? (next-vy (make-doodad "square" "Gray" 460 350 -13 -9))
                -9)
  (check-equal? (next-doodad (make-doodad "radial-star" "Gold" 125 120 10 12))
                (make-doodad "radial-star" "Gold" 135 132 10 12))
  (check-equal? (next-doodad (make-doodad "square" "Gray" 460 350 -13 -9))
                (make-doodad "square" "Gray" 447 341 -13 -9))
  (check-equal? (world-after-tick (initial-world 0))
                (make-world (make-doodad "radial-star" "Gold" 135 132 10 12)
                            (make-doodad "square" "Gray" 447 341 -13 -9)
                            #false))
  (check-equal? (world-after-tick (world-after-tick (initial-world 0)))
                (make-world (make-doodad "radial-star" "Gold" 145 144 10 12)
                            (make-doodad "square" "Gray" 434 332 -13 -9)
                            #false))
  (check-equal? (world-after-key-event (initial-world 0) "a")
                (make-world (make-doodad "radial-star" "Gold" 125 120 10 12)
                            (make-doodad "square" "Gray" 460 350 -13 -9)
                            #false))
  (check-equal? (world-after-key-event (initial-world 0) " ")
                (make-world (make-doodad "radial-star" "Gold" 125 120 10 12)
                            (make-doodad "square" "Gray" 460 350 -13 -9)
                            #true))
  (check-equal? (doodad-to-image (make-doodad
                                  "radial-star" "Gold" 135 132 10 12))
                (radial-star 8 10 50 "solid" "Gold"))
  (check-equal? (doodad-to-image (make-doodad "square" "Gray" 460 350 -13 -9))
                (square 71 "solid" "Gray"))
  (check-equal? (world-to-scene (initial-world 0))
                (place-image (radial-star 8 10 50 "solid" "Gold")
                             125 120
                             (place-image (square 71 "solid" "Gray")
                                          460 350
                                          ANIMATION-WINDOW))))

;; ADDITIONAL
(begin-for-test
  (check-equal? (next-color (make-doodad
                             "radial-star" "Gold" 660 120 10 12)) "Green")
  (check-equal? (next-color (make-doodad
                             "radial-star" "Green" 660 120 10 12)) "Blue")
  (check-equal? (next-color (make-doodad
                             "radial-star" "Blue" 660 120 10 12)) "Gold")
  (check-equal? (next-color (make-doodad
                             "square" "Gray" 5 350 -13 -9)) "OliveDrab")
  (check-equal? (next-color (make-doodad
                             "square" "Khaki" 5 350 -13 -9)) "Orange")
  (check-equal? (next-color (make-doodad
                             "square" "Orange" 5 350 -13 -9)) "Crimson")
  (check-equal? (next-color (make-doodad
                             "square" "Crimson" 5 350 -13 -9)) "Gray")
  (check-equal? (next-x (make-doodad "radial-star" "Gold" 600 120 10 12)) 590)
  (check-equal? (next-y (make-doodad "radial-star" "Gold" 350 440 10 12)) 444)
  (check-equal? (world-after-tick (make-world
                                   (make-doodad
                                    "radial-star" "Gold" 135 132 10 12)
                                   (make-doodad "square" "Gray" 447 341 -13 -9)
                                   true))
                (make-world
                 (make-doodad "radial-star" "Gold" 135 132 10 12)
                 (make-doodad "square" "Gray" 447 341 -13 -9)
                 true)))