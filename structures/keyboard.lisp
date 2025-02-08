(in-package #:org.shirakumo.alloy)

(defvar *keyboard-specs* (make-hash-table :test 'eql))

(defparameter *keyboard-short-map*
  '(("_" NIL)
    ("|" separator)
    ("⎋" :ESCAPE)
    ("$" :SECTION)
    ("-" :MINUS)
    ("=" :EQUAL)
    ("⌫" :BACKSPACE)
    ("↹" :TAB)
    ("[" :LEFT-BRACKET)
    ("]" :RIGHT-BRACKET)
    ("↵" :ENTER)
    ("⇪" :CAPS-LOCK)
    (";" :SEMICOLON)
    ("'" :APOSTROPHE)
    ("\\" :BACKSLASH)
    ("L⇧" :LEFT-SHIFT)
    ("," :COMMA)
    ("." :PERIOD)
    ("/" :SLASH)
    ("R⇧" :RIGHT-SHIFT)
    ("L⌃" :LEFT-CONTROL)
    ("L⌘" :LEFT-SUPER)
    ("L⌥" :LEFT-ALT)
    ("R⌥" :RIGHT-ALT)
    ("R⌘" :RIGHT-SUPER)
    ("R⌃" :RIGHT-CONTROL)
    ("␣" :SPACE)
    ("⇱" :HOME)
    ("⇲" :END)
    ("⌦" :DELETE)
    ("⌤" :INSERT)
    ("⇞" :PAGE-UP)
    ("⇟" :PAGE-DOWN)
    ("↑" :UP)
    ("↓" :DOWN)
    ("←" :LEFT)
    ("→" :RIGHT)
    ("⎙" :PRINT-SCREEN)
    ("⇳" :SCROLL-LOCK)
    ("⎉" :PAUSE)
    ("⇭" :NUM-LOCK)
    ("K0" :KP-0)
    ("K1" :KP-1)
    ("K2" :KP-2)
    ("K3" :KP-3)
    ("K4" :KP-4)
    ("K5" :KP-5)
    ("K6" :KP-6)
    ("K7" :KP-7)
    ("K8" :KP-8)
    ("K9" :KP-9)
    ("K/" :KP-DIVIDE)
    ("K*" :KP-MULTIPLY)
    ("K-" :KP-SUBTRACT)
    ("K+" :KP-ADD)
    ("K↵" :KP-ENTER)
    ("K." :KP-DECIMAL)))

(defun map-short-key (key)
  (let ((extended NIL))
    (when (char= #\_ (char key (1- (length key))))
      (setf extended T)
      (setf key (subseq key 0 (1- (length key)))))
    (values (or (second (assoc key *keyboard-short-map* :test #'string-equal))
                (intern (string-upcase key) "KEYWORD"))
            extended)))

(defun parse-keyboard-spec (spec)
  (with-input-from-string (s spec)
    (loop for line = (read-line s NIL NIL)
          for trimmed = (string-trim " " line)
          while line
          when (string/= "" trimmed)
          collect (loop for start = 0 then (position-if-not (lambda (c) (char= #\Space c)) line :start end)
                        for end = (or (position #\Space line :start start)
                                      (length line))
                        for key = (subseq line start end)
                        when (string/= "" key)
                        collect (multiple-value-list (map-short-key key))
                        until (<= (length line) end)))))

(defun keyboard-spec (name &optional (errorp T))
  (or (gethash name *keyboard-specs*)
      (when errorp (error "No such keyboard spec ~s" name))))

(defun (setf keyboard-spec) (value name)
  (setf (gethash name *keyboard-specs*)
        (etypecase value
          (string (parse-keyboard-spec value))
          (cons value))))

(defun ensure-keyboard-spec (thing)
  (etypecase thing
    (cons thing)
    (string (parse-keyboard-spec thing))
    (symbol (keyboard-spec thing))))

(defmacro define-keyboard-spec (name &rest spec)
  `(setf (keyboard-spec ',name) (progn ,@spec)))

(define-keyboard-spec :100%
  "⎋ _ F1 F2 F3 F4 _ F5 F6 F7 F8 _ F9 F10 F11 F12 | ⎙ ⇳ ⎉ | F13 F14 F15 F16
   $  1  2  3  4  5  6  7  8  9  0  -  =   ⌫_ | ⌤ ⇱ ⇞ | ⇭ K/ K* K-
   ↹_  Q  W  E  R  T  Y  U  I  O  P  [  ]  ↵_ | ⌦ ⇲ ⇟ | K7 K8 K9 K+
   ⇪_   A  S  D  F  G  H  J  K  L  ;  '  \ ↵_ | _ _ _ | K4 K5 K6 K+
   L⇧_   Z  X  C  V  B  N  M  ,  .  /     R⇧_ | _ ↑ _ | K1 K2 K3 K↵
   L⌃ L⌘ L⌥           ␣_             R⌥ R⌘ R⌃ | ← ↓ → | K0_   K. K↵")

(define-keyboard-spec :80%
  "⎋ _ F1 F2 F3 F4 _ F5 F6 F7 F8 _ F9 F10 F11 F12 | ⎙ ⇳ ⎉
   $  1  2  3  4  5  6  7  8  9  0  -  =   ⌫_ | ⌤ ⇱ ⇞
   ↹_  Q  W  E  R  T  Y  U  I  O  P  [  ]  ↵_ | ⌦ ⇲ ⇟
   ⇪_   A  S  D  F  G  H  J  K  L  ;  '  \ ↵_ | _ _ _
   L⇧_   Z  X  C  V  B  N  M  ,  .  /     R⇧_ | _ ↑ _
   L⌃ L⌘ L⌥           ␣_             R⌥ R⌘ R⌃ | ← ↓ →")

(define-keyboard-spec :75%
  "⎋ F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12 ⎙ ⇳ ⎉
   $  1  2  3  4  5  6  7  8  9  0  -  =   ⌫_ ⇱
   ↹_  Q  W  E  R  T  Y  U  I  O  P  [  ]  ↵_ ⇞
   ⇪_   A  S  D  F  G  H  J  K  L  ;  '  \ ↵_ ⇟
   L⇧_   Z  X  C  V  B  N  M  ,  .  /   R⇧_ ↑ ⇲
   L⌃ L⌘ L⌥          ␣_          R⌥ R⌘ R⌃ ← ↓ →")

(define-keyboard-spec :65%
  "⎋  1  2  3  4  5  6  7  8  9  0  -  =   ⌫_ $
   ↹_  Q  W  E  R  T  Y  U  I  O  P  [  ]  ↵_ ⌦
   ⇪_   A  S  D  F  G  H  J  K  L  ;  '  \ ↵_ ⇞
   L⇧_   Z  X  C  V  B  N  M  ,  .  /   R⇧_ ↑ ⇟
   L⌃ L⌘ L⌥          ␣_          R⌥ R⌘ R⌃ ← ↓ →")

(define-keyboard-spec :60%
  "⎋  1  2  3  4  5  6  7  8  9  0  -  =   ⌫_
   ↹_  Q  W  E  R  T  Y  U  I  O  P  [  ]  ↵_
   ⇪_   A  S  D  F  G  H  J  K  L  ;  '  \ ↵_
   L⇧_   Z  X  C  V  B  N  M  ,  .  /     R⇧_
   L⌃ L⌘ L⌥          ␣_              R⌥ R⌘ R⌃")

(define-keyboard-spec :40%
  "⎋_  Q  W  E  R  T  Y  U  I  O  P  -  =  ⌫_
   ↹_   A  S  D  F  G  H  J  K  L  ;  '  \ ↵_
   L⇧_   Z  X  C  V  B  N  M  ,  .  /     R⇧_
   L⌃ L⌘ L⌥          ␣_              R⌥ R⌘ R⌃")

(defclass virtual-key (direct-value-component button)
  ((keyboard :initarg :keyboard :accessor keyboard)))

(defmethod text ((key virtual-key))
  (or (key-text (value key) (ui key))
      (first (find (value key) *keyboard-short-map* :key #'second))
      (string (value key))))

(defmethod key-text ((key virtual-key) (ui ui))
  (let ((text (key-text (value key) ui))
        (mods (modifiers (keyboard key))))
    (when text
      (let ((caps (member :caps-lock mods))
            (shift (member :shift mods)))
        (if (and (or caps shift)
                   (not (and caps shift)))
            (string-upcase text)
            text)))))

(defun key-modifier (value)
  (case value
    ((:caps-lock :scroll-lock :num-lock)
     value)
    ((:left-shift :right-shift)
     :shift)
    ((:left-alt :right-alt)
     :alt)
    ((:left-control :right-control)
     :control)))

(defmethod activate ((key virtual-key))
  (let ((ui (ui key))
        (value (value key))
        (mods (modifiers (keyboard key)))
        (target (target (keyboard key))))
    (let ((mod (key-modifier value)))
      (when mod
        (cond ((find mod mods)
               (setf (modifiers (keyboard key)) (setf mods (remove mod mods)))
               (setf (pressed key) NIL))
              (T
               (setf (modifiers (keyboard key)) (setf mods (list* mod mods)))
               (setf (pressed key) T)))))
    (when target
      (handle (make-instance 'key-down :key value :code 0 :modifiers mods) target)
      (handle (make-instance 'key-up :key value :code 0 :modifiers mods) target)
      (let ((text (key-text key ui)))
        (when text (handle (make-instance 'text-event :text text) target))))))

(defmethod handle ((event key-down) (key virtual-key))
  (when (eq (value key) (key event))
    (setf (pressed key) T)))

(defmethod handle ((event key-up) (key virtual-key))
  (when (eq (value key) (key event))
    (setf (pressed key) NIL)))

(defclass virtual-keyboard (structure)
  ((modifiers :initform () :accessor modifiers)
   (target :initform NIL :initarg :target :accessor target)))

(defmethod initialize-instance :after ((keyboard virtual-keyboard) &key (keyboard-spec :100%))
  (let ((layout (make-instance 'vertical-linear-layout))
        (focus (make-instance 'visual-focus-manager)))
    (loop for row in (ensure-keyboard-spec keyboard-spec)
          for cols = (loop for (_ extended-p) in row
                           collect (if extended-p T 20))
          for lay = (make-instance 'grid-layout :col-sizes cols :row-sizes '(T))
          do (loop for (key) in row
                   do (make-instance 'virtual-key :value key
                                                  :keyboard keyboard
                                                  :layout-parent lay
                                                  :focus-parent focus)))
    (finish-structure keyboard layout focus)))

(defmethod (setf modifiers) :after (mods (keyboard virtual-keyboard))
  (do-elements (key (focus-element keyboard))
    (let ((mod (key-modifier (value key))))
      (when mod (setf (pressed key) (member mod mods))))))
