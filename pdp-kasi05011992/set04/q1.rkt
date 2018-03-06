;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
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
;;                Integer Boolean Integer Integer)
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
;;   lod-fn : LOD -> ??
#|
(define (lod-fn lod)
  (cond [(empty? lod) ...]
        [else (...
               (doodad-fn (first lod))
               (lod-fn (rest lod)))]))
|#

(define-struct world (doodads-star doodads-square paused?))
;; A World is a structure:
;;   (make-world ListOfDoodad ListOfDoodad Boolean)
;; Interpretation:
;;   doodads-star is a ListOfDoodad representing list of radial-star's
;;   doodads-square is a ListOfDoodad representing list of square's
;;   paused? describes whether or not the world is paused
;; TEMPLATE:
;;   world-fn : World -> ??
#|
(define (world-fn w)
  (...
   (world-doodads-star w)
   (world-doodads-square w)
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

;; make-new-doodad : BasicShape Integer Integer -> Doodad
;; GIVEN: a BasicShape and two Integer's representing the number of pixels
;;   the doodad moves on each tick in the x and y direction
;; RETURNS: a Doodad
;; EXAMPLE:
;;   (make-new-doodad "radial-star"
;;                    RADIAL-STAR-INITIAL-VX RADIAL-STAR-INITIAL-VY) =
;;     (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
;;   (make-new-doodad "square" SQUARE-INITIAL-VX SQUARE-INITIAL-VY) =
;;     (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
;; STRATEGY: combine simpler functions
(define (make-new-doodad shape vx vy)
  (if (string=? shape "radial-star")
      (make-doodad shape        
                   RADIAL-STAR-STARTING-COLOR
                   (posn-x RADIAL-STAR-INITIAL-CENTER)
                   (posn-y RADIAL-STAR-INITIAL-CENTER)
                   vx vy false 0 0 0)
      (make-doodad shape        
                   SQUARE-STARTING-COLOR
                   (posn-x SQUARE-INITIAL-CENTER)
                   (posn-y SQUARE-INITIAL-CENTER)
                   vx vy false 0 0 0)))

;; initial-world : Any -> World
;; GIVEN: any value (ignored)
;; RETURNS: the initial World specified for the animation
;; EXAMPLE:
;;   (initial-world -174) =
;;     (make-world
;;      (list (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0))
;;      (list (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0))
;;      #false)
;; STRATEGY: combine simpler functions
(define (initial-world ip)
  (make-world (cons (make-new-doodad "radial-star"
                                     RADIAL-STAR-INITIAL-VX
                                     RADIAL-STAR-INITIAL-VY)
                    empty)
              (cons (make-new-doodad "square"
                                     SQUARE-INITIAL-VX
                                     SQUARE-INITIAL-VY)
                    empty)
              false))

;; bounce-x? : Doodad -> Boolean
;; GIVEN: a Doodad
;; RETURNS: true if the tentative x position of the Doodad is negative or
;;   is greater than or equal to the animation window width
;; EXAMPLE:
;;   (bounce-x? (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)) =
;;     #false
;;   (bounce-x? (make-doodad "square" "Gray" 0 350 -13 -9 #false 0 0 0)) =
;;     #true
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
;; EXAMPLE:
;;   (next-color (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
;;     = "Green"
;;   (next-color (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0)) =
;;     "Khaki"
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
;; EXAMPLE:
;;   (next-x (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)) =
;;     135
;;   (next-x (make-doodad "square" "Gray" 0 350 -13 -9 #false 0 0 0)) = 13
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
;;   (next-y (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)) =
;;     132
;;   (next-y (make-doodad "square" "Gray" 460 0 -13 -9 #false 0 0 0)) = 9
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
;;   (next-vx (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)) =
;;     10
;;   (next-vx (make-doodad "square" "Gray" 0 350 -13 -9 #false 0 0 0)) = 13
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
;;   (next-vy (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)) =
;;     12
;;   (next-vy (make-doodad "square" "Gray" 460 0 -13 -9 #false 0 0 0)) = 9
;; STRATEGY: combine simpler functions
(define (next-vy dd)
  (if (bounce-y? dd)
      (- (doodad-vy dd))
      (doodad-vy dd)))

;; next-doodad : Doodad -> Doodad
;; GIVEN: a Doodad
;; RETURNS: the Doodad that should follow the given Doodad after a tick
;; EXAMPLE:
;;   (next-doodad (make-doodad "radial-star" "Gold" 125 120 10 12 #true 0 0 0)
;;                #false) =
;;     (make-doodad "radial-star" "Gold" 125 120 10 12 #true 0 0 1)
;;   (next-doodad (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)
;;                #false) =
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
;;                 #true) =
;;     (list (make-doodad "radial-star" "Gold" 125 120 10 12 #true 0 0 1))
;; STRATEGY: use template for ListOfDoodad on lod
(define (next-doodads lod paused?)
  (cond [(empty? lod) empty]
        [else (cons (next-doodad (first lod) paused?)
                    (next-doodads (rest lod) paused?))]))

;; world-after-tick : World -> World
;; GIVEN: any World that's possible for the animation
;; RETURNS: the World that should follow the given World after a tick
;; EXAMPLE:
;;   (world-after-tick (initial-world 0)) =
;;     (make-world
;;      (list (make-doodad "radial-star" "Gold" 135 132 10 12 #false 0 0 1))
;;      (list (make-doodad "square" "Gray" 447 341 -13 -9 #false 0 0 1))
;;      #false)
;; STRATEGY: combine simpler functions
(define (world-after-tick w)
  (make-world (next-doodads (world-doodads-star w) (world-paused? w))
              (next-doodads (world-doodads-square w) (world-paused? w))
              (world-paused? w)))

;; oldest-doodad-age : ListOfDoodad Integer -> Integer
;; GIVEN: a ListOfDoodad and an Integer(initially 0, used to find Doodad with
;;   Maximum age)
;; RETURNS: the oldest age of the Doodad in the ListOfDoodad
;; EXAMPLE:
;;   (oldest-doodad-age
;;    (list
;;     (make-doodad "radial-star" "Blue" 595 176 12 -10 #false 0 0 60)
;;     (make-doodad "radial-star" "Blue" 465 44 -10 -12 #false 0 0 61)
;;     (make-doodad "radial-star" "Gold" 331 396 -12 -10 #false 0 0 62)) 0) = 62
;; STRATEGY: use template for ListOfDoodad on lod
(define (oldest-doodad-age lod oldest)
  (cond [(empty? lod) oldest]
        [(> (doodad-age (first lod)) oldest)
         (oldest-doodad-age (rest lod) (doodad-age (first lod)))]
        [else (oldest-doodad-age (rest lod) oldest)]))

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
;;    62) =
;;     (list (make-doodad "radial-star" "Blue" 595 176 12 -10 #false 0 0 60)
;;           (make-doodad "radial-star" "Blue" 465 44 -10 -12 #false 0 0 61))
;; STRATEGY: use template for ListOfDoodad on lod
(define (remove-doodad-with-age lod age)
  (cond [(empty? lod) empty]
        [(= (doodad-age (first lod)) age)
         (remove-doodad-with-age (rest lod) age)]
        [else (cons (first lod) (remove-doodad-with-age (rest lod) age))]))

;; change-selected-doodad-color : ListOfDoodad -> ListOfDoodad
;; GIVEN: a ListOfDoodad
;; RETURNS: a ListOfDoodad after changing color of selected Doodad's
;;   from the ListOfDoodad given as input
;; EXAMPLE:
;;   (change-selected-doodad-color
;;    (list (make-doodad "radial-star" "Blue" 595 176 12 -10 #true 0 0 60)
;;          (make-doodad "radial-star" "Blue" 465 44 -10 -12 #false 0 0 61))) =
;;     (list (make-doodad "radial-star" "Gold" 595 176 12 -10 #true 0 0 60)
;;           (make-doodad "radial-star" "Blue" 465 44 -10 -12 #false 0 0 61))
;; STRATEGY: use template for ListOfDoodad on lod
(define (change-selected-doodad-color lod)
  (cond [(empty? lod) empty]
        [(doodad-selected? (first lod))
         (cons (make-doodad (doodad-shape (first lod)) 
                            (next-color (first lod))
                            (doodad-x (first lod))
                            (doodad-y (first lod))
                            (doodad-vx (first lod))
                            (doodad-vy (first lod))
                            true
                            (doodad-mx (first lod))
                            (doodad-my (first lod))
                            (doodad-age (first lod)))
               (change-selected-doodad-color (rest lod)))]
        [else (cons (first lod) (change-selected-doodad-color (rest lod)))]))

;; world-after-key-event : World KeyEvent -> World
;; GIVEN: a World and a KeyEvent
;; RETURNS: the World that should follow the given World
;;   after the given KeyEvent
;; EXAMPLE:
;;   (world-after-key-event (initial-world 0) " ") =
;;     (make-world
;;      (list (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
;;      (list (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
;;      #true)
;;   (world-after-key-event (initial-world 0) "t") =
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
                     (not (world-paused? w)))]
        [(key=? ke "t")
         (make-world (cons
                      (cond [(empty? (world-doodads-star w))
                             (make-new-doodad
                              "radial-star"
                              RADIAL-STAR-INITIAL-VX
                              RADIAL-STAR-INITIAL-VY)]
                            [else (make-new-doodad
                                   "radial-star"
                                   (- (doodad-vy
                                       (first (world-doodads-star w))))
                                   (doodad-vx (first (world-doodads-star w))))])
                      (world-doodads-star w))
                     (world-doodads-square w)
                     (world-paused? w))]
        [(key=? ke "q")
         (make-world (world-doodads-star w)
                     (cons
                      (if (empty? (world-doodads-square w))
                          (make-new-doodad
                           "square"
                           SQUARE-INITIAL-VX
                           SQUARE-INITIAL-VY)
                          (make-new-doodad
                           "square"
                           (- (doodad-vy (first (world-doodads-square w))))
                           (doodad-vx (first (world-doodads-square w)))))
                      (world-doodads-square w))
                     (world-paused? w))]
        [(key=? ke ".")
         (make-world
          (remove-doodad-with-age (world-doodads-star w)
                                  (oldest-doodad-age (world-doodads-star w) 0))
          (remove-doodad-with-age (world-doodads-square w)
                                  (oldest-doodad-age (world-doodads-square w)
                                                     0))
          (world-paused? w))]
        [(key=? ke "c")
         (make-world (change-selected-doodad-color (world-doodads-star w))
                     (change-selected-doodad-color (world-doodads-square w))
                     (world-paused? w))]
        [else w]))

;; in-doodad? : Doodad Integer Integer -> Boolean
;; GIVEN: a Doodad and an x and y coordinate of the mouse event
;; RETURNS: true if the x and y coordinate lies in the circular area whose
;;   radius is equal to the outer radius of the star if the BasicShape is
;;   "radial-star" or inside the square in case of the Doodad with BasicShape
;;   "square"
;; EXAMPLE:
;;   (in-doodad? (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)
;;               135 132) = #true
;;   (in-doodad? (make-doodad "square" "Gray" 460 350 -13 -9 false 0 0)
;;               135 132) = false
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
;; EXAMPLE:
;;   (doodad-after-button-down
;;    (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0) 135 132) =
;;     (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0)
;;   (doodad-after-button-down
;;    (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0) 100 100) =
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
;; EXAMPLE:
;;   (doodad-after-drag
;;    (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0) 140 140) =
;;     (make-doodad "radial-star" "Gold" 130 128 10 12 #true 10 12 0)
;;   (doodad-after-drag
;;    (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0) 100 100) =
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
;; EXAMPLE:
;;   (doodad-after-button-up
;;    (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0) 140 140) =
;;     (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)
;;   (doodad-after-button-up
;;    (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0) 100 100) =
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
;; EXAMPLE:
;;   (doodad-after-mouse-event
;;    (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)
;;    135 132 "button-down") =
;;     (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0)
;;   (doodad-after-mouse-event
;;    (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0)
;;    140 140 "drag") =
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
;;    135 132 "button-down") =
;;     (list (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0))
;; STRATEGY: use template for ListOfDoodad on lod
(define (doodads-after-mouse-event lod mx my me)
  (if (empty? lod)
      empty
      (cons (doodad-after-mouse-event (first lod) mx my me)
            (doodads-after-mouse-event (rest lod) mx my me))))

;; world-after-mouse-event : World Integer Integer MouseEvent -> World
;; GIVEN: A world, the x- and y-coordinates of a mouse event,
;;   and the mouse event
;; RETURNS: the world that should follow the given world after the
;;   given mouse event
;; EXAMPLE:
;;   (world-after-mouse-event (initial-world 0) 1 1 "button-down") =
;;     (make-world
;;      (list (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
;;      (list (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
;;      #false)
;; STRATEGY: combine simpler functions
(define (world-after-mouse-event w mx my me)
  (make-world (doodads-after-mouse-event (world-doodads-star w) mx my me)
              (doodads-after-mouse-event (world-doodads-square w) mx my me)
              (world-paused? w)))

;; doodad-to-image : Doodad -> Image
;; GIVEN: a Doodad
;; RETURNS: the Image that portays the given Doodad
;; EXAMPLE:
;;   (doodad-to-image
;;    (make-doodad "radial-star" "Gold" 125 120 10 12 #true 5 10 0)) =
;;     (underlay/offset (radial-star 8 10 50 "solid" "Gold")
;;                      5 10 MOUSE-MARKER)
;;   (doodad-to-image
;;    (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)) =
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

;; doodads-to-scene : ListOfDoodad Image -> Image
;; Given: a ListOfDoodad's and an Image
;; RETURNS: an Image similar to the input Image with the ListOfDoodad's drawn
;;   overit
;; EXAMPLE:
;;   (doodads-to-scene
;;    (list (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
;;    ANIMATION-WINDOW) =
;;     (place-image (radial-star 8 10 50 "solid" "Gold")
;;                  125
;;                  120
;;                  ANIMATION-WINDOW)
;; STRATEGY: use template for ListOfDoodad on lod
(define (doodads-to-scene lod scene)
  (if (empty? lod)
      scene
      (doodads-to-scene (rest lod)
                        (place-image (doodad-to-image (first lod))
                                     (doodad-x (first lod))
                                     (doodad-y (first lod))
                                     scene))))

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
  (doodads-to-scene (append (reverse (world-doodads-square w))
                            (reverse (world-doodads-star w)))
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
  ;; initial-world
  (check-equal? (initial-world -174)
                (make-world
                 (list (make-doodad "radial-star" "Gold" 125 120 10 12
                                    #false 0 0 0))
                 (list (make-doodad "square" "Gray" 460 350 -13 -9
                                    #false 0 0 0))
                 #false))

  ;; make-new-doodad
  (check-equal? (make-new-doodad "radial-star" 10 12)
                (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
  (check-equal? (make-new-doodad "square" -13 -9)
                (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))

  ;; bounce-x?
  (check-equal? (bounce-x?
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                #false)
  (check-equal? (bounce-x?
                 (make-doodad "square" "Gray" 0 350 -13 -9 #false 0 0 0))
                #true)

  ;; bounce-y?
  (check-equal? (bounce-y?
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                #false)
  (check-equal? (bounce-y?
                 (make-doodad "square" "Gray" 460 0 -13 -9 #false 0 0 0))
                #true)

  ;; next-color
  (check-equal? (next-color
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                "Green")
  (check-equal? (next-color
                 (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
                "OliveDrab")
  ;; ADDITIONAL
  (check-equal? (next-color
                 (make-doodad "radial-star" "Green" 125 120 10 12 #false 0 0 0))
                "Blue")
  (check-equal? (next-color
                 (make-doodad "radial-star" "Blue" 125 120 10 12 #false 0 0 0))
                "Gold")
  (check-equal? (next-color
                 (make-doodad "square" "OliveDrab" 460 350 -13 -9 #false 0 0 0))
                "Khaki")
  (check-equal? (next-color
                 (make-doodad "square" "Khaki" 460 350 -13 -9 #false 0 0 0))
                "Orange")
  (check-equal? (next-color
                 (make-doodad "square" "Orange" 460 350 -13 -9 #false 0 0 0))
                "Crimson")
  (check-equal? (next-color
                 (make-doodad "square" "Crimson" 460 350 -13 -9 #false 0 0 0))
                "Gray")

  ;; next-x
  (check-equal? (next-x
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                135)
  (check-equal? (next-x (make-doodad "square" "Gray" 0 350 -13 -9 #false 0 0 0))
                13)
  ;; ADDITIONAL
  (check-equal? (next-x
                 (make-doodad "radial-star" "Gold" 601 120 10 12 #false 0 0 0))
                589)

  ;; next-y
  (check-equal? (next-y
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                132)
  (check-equal? (next-y (make-doodad "square" "Gray" 460 0 -13 -9 #false 0 0 0))
                9)
  ;; ADDITIONAL
  (check-equal? (next-y
                 (make-doodad "radial-star" "Gold" 125 441 10 12 #false 0 0 0))
                443)

  ;; next-vx
  (check-equal? (next-vx
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                10)
  (check-equal? (next-vx
                 (make-doodad "square" "Gray" 0 350 -13 -9 #false 0 0 0))
                13)

  ;; next-vy
  (check-equal? (next-vy
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                12)
  (check-equal? (next-vy
                 (make-doodad "square" "Gray" 460 0 -13 -9 #false 0 0 0))
                9)

  ;; next-doodad
  (check-equal? (next-doodad (make-doodad "radial-star" "Gold" 125 120 10 12
                                          #true 0 0 0)
                             #false)
                (make-doodad "radial-star" "Gold" 125 120 10 12 #true 0 0 1))
  (check-equal? (next-doodad (make-doodad "radial-star" "Gold" 125 120 10 12
                                          #false 0 0 0) #false)
                (make-doodad "radial-star" "Gold" 135 132 10 12 #false 0 0 1))
  ;; ADDITIONAL
  (check-equal? (next-doodad (make-doodad "radial-star" "Gold" 125 120 10 12
                                          #false 0 0 0) #true)
                (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 1))
  (check-equal? (next-doodad (make-doodad "radial-star" "Gold" 601 120 10 12
                                          #false 0 0 0) #false)
                (make-doodad "radial-star" "Green" 589 132 -10 12 #false 0 0 1))
  (check-equal? (next-doodad (make-doodad "radial-star" "Gold" 125 441 10 12
                                          #false 0 0 0) #false)
                (make-doodad "radial-star" "Green" 135 443 10 -12 #false 0 0 1))

  ;; next-doodads
  (check-equal? (next-doodads (world-doodads-star (initial-world 0)) #true)
                (list
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 1)))

  ;; world-after-tick
  (check-equal? (world-after-tick (initial-world 0))
                (make-world
                 (list
                  (make-doodad "radial-star" "Gold" 135 132 10 12 #false 0 0 1))
                 (list
                  (make-doodad "square" "Gray" 447 341 -13 -9 #false 0 0 1))
                 #false))

  ;; oldest-doodad-age
  (check-equal? (oldest-doodad-age
                 (list (make-doodad "radial-star" "Blue" 595 176 12 -10
                                    #false 0 0 60)
                       (make-doodad "radial-star" "Blue" 465 44 -10 -12
                                    #false 0 0 61)
                       (make-doodad "radial-star" "Gold" 331 396 -12 -10
                                    #false 0 0 62)) 0)
                62)

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
                              #false 0 0 61)))

  ;; change-selected-doodad-color
  (check-equal? (change-selected-doodad-color
                 (list
                  (make-doodad "radial-star" "Blue" 595 176 12 -10 #true 0 0 60)
                  (make-doodad "radial-star" "Blue" 465 44 -10 -12
                               #false 0 0 61)))
                (list
                 (make-doodad "radial-star" "Gold" 595 176 12 -10 #true 0 0 60)
                 (make-doodad "radial-star" "Blue" 465 44 -10 -12
                              #false 0 0 61)))

  ;; world-after-key-event
  (check-equal? (world-after-key-event (initial-world 0) " ")
                (make-world
                 (list
                  (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                 (list
                  (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
                 #true))
  (check-equal? (world-after-key-event (initial-world 0) "t")
                (make-world
                 (list
                  (make-doodad "radial-star" "Gold" 125 120 -12 10 #false 0 0 0)
                  (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                 (list
                  (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
                 #false))
  ;; ADDITIONAL
  (check-equal? (world-after-key-event
                 (make-world
                  empty
                  (list
                   (make-doodad "square" "Gray" 460 350 -13 -9
                                #false 0 0 0))
                  #false) "t")
                (make-world
                 (list (make-doodad "radial-star" "Gold" 125 120 10 12
                                    #false 0 0 0))
                 (list (make-doodad "square" "Gray" 460 350 -13 -9
                                    #false 0 0 0))
                 #false))
  (check-equal? (world-after-key-event (initial-world 0) "q")
                (make-world
                 (list
                  (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                 (list
                  (make-doodad "square" "Gray" 460 350 9 -13 #false 0 0 0)
                  (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
                 #false))
  (check-equal? (world-after-key-event
                 (make-world
                  (list (make-doodad "radial-star" "Gold" 125 120 10 12
                                     #false 0 0 0))
                  empty #false) "q")
                (make-world
                 (list
                  (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                 (list
                  (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
                 #false))
  (check-equal? (world-after-key-event (initial-world 0) ".")
                (make-world empty empty #false))
  (check-equal? (world-after-key-event (initial-world 0) "c")
                (make-world
                 (list (make-doodad "radial-star" "Gold" 125 120 10 12
                                    #false 0 0 0))
                 (list (make-doodad "square" "Gray" 460 350 -13 -9
                                    #false 0 0 0))
                 #false))
  (check-equal? (world-after-key-event (initial-world 0) "!")
                (make-world
                 (list
                  (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                 (list
                  (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
                 #false))

  ;; in-doodad?
  (check-equal? (in-doodad?
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)
                 135 132)
                #true)
  (check-equal? (in-doodad?
                 (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0)
                 100 100)
                #false)
  (check-equal? (in-doodad?
                 (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0)
                 450 325)
                #true)

  ;; doodad-after-button-down
  (check-equal? (doodad-after-button-down
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0)
                 135 132)
                (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0))
  (check-equal? (doodad-after-button-down
                 (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0)
                 100 100)
                (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))

  ;; doodad-after-drag
  (check-equal? (doodad-after-drag
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0)
                 140 140)
                (make-doodad "radial-star" "Gold" 130 128 10 12 #true 10 12 0))
  (check-equal? (doodad-after-drag
                 (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0)
                 100 100)
                (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))

  ;; doodad-after-button-up
  (check-equal? (doodad-after-button-up
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0)
                 140 140)
                (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
  (check-equal? (doodad-after-button-up
                 (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0)
                 100 100)
                (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))

  ;; doodad-after-mouse-event
  (check-equal? (doodad-after-mouse-event
                 (make-doodad "radial-star" "Gold" 125 120 10 12
                              #false 0 0 0) 135 132 "button-down")
                (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0))
  (check-equal? (doodad-after-mouse-event
                 (make-doodad "radial-star" "Gold" 125 120 10 12
                              #true 10 12 0) 140 140 "drag")
                (make-doodad "radial-star" "Gold" 130 128 10 12 #true 10 12 0))
  ;; ADDITIONAL
  (check-equal? (doodad-after-mouse-event
                 (make-doodad "radial-star" "Gold" 125 120 10 12
                              #true 10 12 0) 140 140 "button-up")
                (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
  (check-equal? (doodad-after-mouse-event
                 (make-doodad "radial-star" "Gold" 125 120 10 12
                              #true 10 12 0) 140 140 "move")
                (make-doodad "radial-star" "Gold" 125 120 10 12 #true 10 12 0))

  ;; doodads-after-mouse-event
  (check-equal? (doodads-after-mouse-event
                 (list (make-doodad "radial-star" "Gold" 125 120 10 12
                                    #false 0 0 0)) 135 132 "button-down")
                (list (make-doodad "radial-star" "Gold" 125 120 10 12
                                   #true 10 12 0)))

  ;; world-after-mouse-event
  (check-equal? (world-after-mouse-event (initial-world 0) 1 1 "button-down")
                (make-world
                 (list (make-doodad "radial-star" "Gold" 125 120 10 12
                                    #false 0 0 0))
                 (list (make-doodad "square" "Gray" 460 350 -13 -9
                                    #false 0 0 0))
                 #false))

  ;; doodad-to-image
  (check-equal? (doodad-to-image
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #true 5 10 0))
                (underlay/offset (radial-star 8 10 50 "solid" "Gold")
                                 5 10 MOUSE-MARKER))
  (check-equal? (doodad-to-image
                 (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                (radial-star 8 10 50 "solid" "Gold"))
  ;; ADDITIONAL
  (check-equal? (doodad-to-image
                 (make-doodad "square" "Gray" 460 350 -13 -9 #true 5 10 0))
                (underlay/offset (square 71 "solid" "Gray")
                                 5 10 MOUSE-MARKER))
  (check-equal? (doodad-to-image
                 (make-doodad "square" "Gray" 460 350 -13 -9 #false 0 0 0))
                (square 71 "solid" "Gray"))

  ;; doodads-to-scence
  (check-equal? (doodads-to-scene
                 (list
                  (make-doodad "radial-star" "Gold" 125 120 10 12 #false 0 0 0))
                 ANIMATION-WINDOW)
                (place-image (radial-star 8 10 50 "solid" "Gold")
                             125 120 ANIMATION-WINDOW))

  ;; world-to-scene
  (check-equal? (world-to-scene (initial-world 0))
                (place-image (radial-star 8 10 50 "solid" "Gold")
                             125 120
                             (place-image (square 71 "solid" "Gray")
                                          460 350
                                          ANIMATION-WINDOW))))