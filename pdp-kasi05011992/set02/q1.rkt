;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require "extras.rkt")
(require 2htdp/image)
(require 2htdp/universe)
(require rackunit)

(provide make-editor
         editor-pre
         editor-post
         editor?
         edit)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; DATA DEFINITIONS

(define-struct editor (pre post))
;; An editor is a structure
;;   (make-editor String String)
;; Interpretation:
;;   (make-editor first last) is an editor
;;     first(pre) is the visible text of the editor before the cursor
;;     last(post) is the visible text of the editor after the cursor
;;     (string-append first last) is the visible text with the cursor
;;       displayed between first and last
;; TEMPLATE:
;;   editor-fn : Editor -> ??
#|
(define (editor-fn ed)
  (...
   (editor-pre ed)
   (editor-post ed)))
|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; CONSTANTS

;; size of text in editor window
(define TEXT-SIZE 16)
;; color of text in editor window
(define TEXT-COLOR "black")
;; width of editor window
(define EDITOR-WINDOW-WIDTH 200)
;; height of editor window
(define EDITOR-WINDOW-HEIGHT 20)
;; editor window in which the text is diplayed
(define EDITOR-WINDOW (empty-scene EDITOR-WINDOW-WIDTH EDITOR-WINDOW-HEIGHT))
;; cursor displayed between pre and post of editor in editor window
(define CURSOR (rectangle 1 EDITOR-WINDOW-HEIGHT "solid" "red"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; FUNCTIONS

;; render : Editor -> Image
;; GIVEN: an editor
;; RETURNS: an image of an editor with
;;   cursor in between the pre and post strings of the editor
;; EXAMPLE:
;;   (render (make-editor "Pre" "Post")) =
;;     (overlay/align "left" "center"
;;                    (beside (text "Pre" TEXT-SIZE TEXT-COLOR)
;;                            CURSOR
;;                            (text "Post" TEXT-SIZE TEXT-COLOR))
;;                    EDITOR-WINDOW)
;;   (render (make-editor "Empty Post" "")) =
;;     (overlay/align "left" "center"
;;                    (beside (text "Empty Post" TEXT-SIZE TEXT-COLOR)
;;                            CURSOR
;;                            (text "" TEXT-SIZE TEXT-COLOR))
;;                    EDITOR-WINDOW)
;; STATERGY: combine simpler functions
(define (render ed)
  (overlay/align "left" "center"
                 (beside (text (editor-pre ed) TEXT-SIZE TEXT-COLOR)
                         CURSOR
                         (text (editor-post ed) TEXT-SIZE TEXT-COLOR))
                 EDITOR-WINDOW))

;; edit : Editor KeyEvent -> Editor
;; GIVEN: an editor and a key event
;; RETURNS: an editor similar to the input editor with
;;   a single-character key event added to the end of
;;   pre field of input editor
;; EXAMPLE:
;;   (edit (make-editor "MoveL" "eft") "left") = (make-editor "Move" "Left")
;;   (edit (make-editor "Ad" "Character") "d") = (make-editor "Add" "Character")
;; STATERGY: combine simpler functions
(define (edit ed ke)
  (cond [(or (key=? ke "left")
             (key=? ke "right"))
         (move-cursor ed ke)]
        [(key=? ke "\b") (delete-character ed)]
        [(or (key=? ke "\t")
             (key=? ke "\r")
             (> (string-length ke) 1))
         ed]
        [(= (string-length ke) 1) (add-character ed ke)]))

;; move-cursor : Editor KeyEvent -> Editor
;; GIVEN: an editor and a key event
;; WHERE: key event equals "left" or "right"
;; RETURNS: an editor similar to the input editor with
;;   the same visible text but with changes in
;;   pre and post strings based on key event
;; EXAMPLES:
;;   (move-cursor (make-editor "MoveL" "eft") "left") =
;;     (make-editor "Move" "Left")
;;   (move-cursor (make-editor "Mov" "eRight") "right") =
;;     (make-editor "Move" "Right")
;; STATERGY: combine simpler functions
(define (move-cursor ed ke)
  (if (key=? ke "left")
      (if (string=? (editor-pre ed) "")
          ed
          (make-editor (string-remove-last (editor-pre ed))
                       (string-append (string-last (editor-pre ed))
                                      (editor-post ed))))
      (if (string=? (editor-post ed) "")
          ed
          (make-editor (string-append (editor-pre ed)
                                      (string-first (editor-post ed)))
                       (string-rest (editor-post ed))))))

;; string-remove-last : String -> String
;; GIVEN: a string
;; WHERE: string is not empty
;; RETURNS: a string similar to the input String with the last character removed
;; EXAMPLE:
;;   (string-remove-last "R") = ""
;;   (string-remove-last "Remove Last") = "Remove Las"
;; STATERGY: combine simpler functions
(define (string-remove-last str)
  (substring str 0 (- (string-length str) 1)))

;; string-last : String -> String
;; GIVEN: a string
;; WHERE: string is not empty
;; RETURNS: a last 1String of the input string
;; EXAMPLE:
;;   (string-last "L") = "L"
;;   (string-last "Last") = "t"
;; STATERGY: combine simpler functions
(define (string-last str)
  (string-ith str (- (string-length str) 1)))

;; string-first : String -> String
;; GIVEN: a string
;; WHERE: string is not empty
;; RETURNS: a first 1String of the input string
;; EXAMPLE:
;;   (string-first "F") = "F"
;;   (string-first "First") = "F"
;; STATERGY: combine simpler functions
(define (string-first str)
  (string-ith str 0))

;; string-rest : String -> String
;; GIVEN: a string
;; WHERE: string is not empty
;; RETURNS: a string similar to the input string with
;;   the first character removed
;; EXAMPLE:
;;   (string-rest "R") = ""
;;   (string-rest "Rest") = "est"
;; STATERGY: combine simpler functions
(define (string-rest str)
  (substring str 1))

;; delete-character : Editor -> Editor
;; GIVEN: an editor
;; RETURNS: an editor similar to the input editor after removing
;;   the last character of the pre string
;; EXAMPLE:
;;   (delete-character (make-editor "" "Empty Pre")) =
;;     (make-editor "" "Empty Pre")
;;   (delete-character (make-editor "Delete" "Character")) =
;;     (make-editor "Delet" "Character")
;; STATERGY: combine simpler functions
(define (delete-character ed)
  (if (string=? (editor-pre ed) "")
      ed
      (make-editor (string-remove-last (editor-pre ed)) (editor-post ed))))

;; add-character : Editor KeyEvent -> Editor
;; GIVEN: an editor and a key event
;; WHERE: key event is a 1String and not matching "\b" "\t" "\r"
;; RETURNS: an editor similar to the input editor after adding
;;   the key to the pre string
;; EXAMPLE:
;;   (add-character (make-editor "" "Empty Pre") "!")
;;     (make-editor "!" "Empty Pre")
;;   (add-character (make-editor "Pre" "Post") "-")
;;     (make-editor "Pre-" "Post")
;; STATERGY: combine simpler functions
(define (add-character ed ke)
  (make-editor (string-append (editor-pre ed) ke) (editor-post ed)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TESTS

;; EXAMPLES
(begin-for-test
  (check-equal? (render (make-editor "Pre" "Post"))
                (overlay/align "left" "center"
                               (beside (text "Pre" TEXT-SIZE TEXT-COLOR)
                                       CURSOR
                                       (text "Post" TEXT-SIZE TEXT-COLOR))
                               EDITOR-WINDOW))
  (check-equal? (render (make-editor "Empty Post" ""))
                (overlay/align "left" "center"
                               (beside (text "Empty Post" TEXT-SIZE TEXT-COLOR)
                                       CURSOR
                                       (text "" TEXT-SIZE TEXT-COLOR))
                               EDITOR-WINDOW))
  (check-equal? (edit (make-editor "MoveL" "eft") "left")
                (make-editor "Move" "Left"))
  (check-equal? (edit (make-editor "Ad" "Character") "d")
                (make-editor "Add" "Character"))
  (check-equal? (move-cursor (make-editor "MoveL" "eft") "left")
                (make-editor "Move" "Left"))
  (check-equal? (move-cursor (make-editor "Mov" "eRight") "right")
                (make-editor "Move" "Right"))
  (check-equal? (string-remove-last "R") "")
  (check-equal? (string-remove-last "Remove Last") "Remove Las")
  (check-equal? (string-last "L") "L")
  (check-equal? (string-last "Last") "t")
  (check-equal? (string-first "F") "F")
  (check-equal? (string-first "First") "F")
  (check-equal? (string-rest "R") "")
  (check-equal? (string-rest "Rest") "est")
  (check-equal? (delete-character (make-editor "" "Empty Pre"))
                (make-editor "" "Empty Pre"))
  (check-equal? (delete-character (make-editor "Delete" "Character"))
                (make-editor "Delet" "Character"))
  (check-equal? (add-character (make-editor "" "Empty Pre") "!")
                (make-editor "!" "Empty Pre"))
  (check-equal? (add-character (make-editor "Pre" "Post") "-")
                (make-editor "Pre-" "Post")))

;; ADDITIONAL
(begin-for-test
  (check-equal? (render (make-editor "" "Empty Pre"))
                (overlay/align "left" "center"
                               (beside (text "" TEXT-SIZE TEXT-COLOR)
                                       CURSOR
                                       (text "Empty Pre" TEXT-SIZE TEXT-COLOR))
                               EDITOR-WINDOW))
  (check-equal? (edit (make-editor "Mov" "eRight") "right")
                (make-editor "Move" "Right"))
  (check-equal? (edit (make-editor "Remove" "Character") "\b")
                (make-editor "Remov" "Character"))
  (check-equal? (edit (make-editor "Ignore" "Tab") "\t")
                (make-editor "Ignore" "Tab"))
  (check-equal? (edit (make-editor "Ignore" "Return") "\r")
                (make-editor "Ignore" "Return"))
  (check-equal? (edit (make-editor "Ignore" "MultiString") "up")
                (make-editor "Ignore" "MultiString"))
  (check-equal? (move-cursor (make-editor "" "Empty Pre") "left")
                (make-editor "" "Empty Pre"))
  (check-equal? (move-cursor (make-editor "Empty Post" "") "right")
                (make-editor "Empty Post" "")))