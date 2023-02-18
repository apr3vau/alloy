#|
 This file is a part of Alloy
 (c) 2019 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.alloy)

(defclass border-layout (layout container)
  ((l :initform NIL :accessor l)
   (u :initform NIL :accessor u)
   (r :initform NIL :accessor r)
   (b :initform NIL :accessor b)
   (c :initform NIL :accessor c)
   (padding :initarg :padding :initform (margins) :accessor padding)))

(defun border-place-slot (place)
  (ecase place
    (:west 'l)
    (:north 'u)
    (:east 'r)
    (:south 'b)
    (:center 'c)))

(defmethod enter ((element layout-element) (layout border-layout) &key (place :center) size)
  (let ((slot (border-place-slot place)))
    (when (and (slot-value layout slot) (not (eq element (first (slot-value layout slot)))))
      (cerror "Replace the element" 'place-already-occupied
              :bad-element element :place place :layout layout :existing (slot-value layout slot)))
    (setf (slot-value layout slot) (list element size))))

(defmethod leave ((element layout-element) (layout border-layout))
  (flet ((test (slot)
           (when (eq element (car (slot-value layout slot)))
             (setf (slot-value layout slot) NIL))))
    (mapc #'test '(l u r b c))
    element))

(defmethod update ((element layout-element) (layout border-layout) &key place size)
  (let ((slot (border-place-slot place)))
    (when (and (slot-value layout slot) (not (eq element (first (slot-value layout slot)))))
      (cerror "Replace the element" 'place-already-occupied
              :bad-element element :place place :layout layout :existing (slot-value layout slot)))
    (flet ((test (slot)
             (when (eq element (car (slot-value layout slot)))
               (unless size (setf size (second (slot-value layout slot))))
               (setf (slot-value layout slot) NIL))))
      (mapc #'test '(l u r b c)))
    (setf (slot-value layout slot) (list element size))))

(defmethod element-count ((layout border-layout))
  (loop for i in '(l u r b c)
        sum (if (slot-value layout i) 1 0)))

(defmethod elements ((layout border-layout))
  (let ((elements ()))
    (flet ((test (slot)
             (when (slot-value layout slot)
               (push (car (slot-value layout slot)) elements))))
      (mapc #'test '(l u r b c))
      elements)))

(defmethod element-index ((element layout-element) (layout border-layout))
  (cond ((eq element (car (slot-value layout 'l))) :west)
        ((eq element (car (slot-value layout 'u))) :north)
        ((eq element (car (slot-value layout 'r))) :east)
        ((eq element (car (slot-value layout 'b))) :south)
        ((eq element (car (slot-value layout 'c))) :center)))

(defmethod index-element (index (layout border-layout))
  (ecase index
    (:west (car (slot-value layout 'l)))
    (:north (car (slot-value layout 'u)))
    (:east (car (slot-value layout 'r)))
    (:south (car (slot-value layout 'b)))
    (:center (car (slot-value layout 'c)))))

(defmethod call-with-elements (function (layout border-layout) &key start end from-end)
  (declare (ignore start end))
  (flet ((test (slot)
           (when (slot-value layout slot)
             (funcall function (car (slot-value layout slot))))))
    (if from-end
        (mapc #'test '(c b r u l))
        (mapc #'test '(l u r b c)))))

(defmethod clear ((layout border-layout))
  (flet ((test (slot) (setf (slot-value layout slot) NIL)))
    (mapc #'test '(l u r b c))
    layout))

(defmethod refit ((layout border-layout))
  (macrolet ((with-border ((slot dim) &body body)
               `(destructuring-bind (&optional element size) (slot-value layout ',slot)
                  (when element
                    (let ((size (or size (,dim element))))
                      ,@body)))))
    (with-unit-parent layout
      (let* ((extent (bounds layout))
             (w (pxw extent)) (h (pxh extent)) (x 0) (y 0)
             (p (padding layout)))
        ;;(incf x (pxl p))
        ;;(incf y (pxb p))
        ;;(decf w (+ (pxl p) (pxr p)))
        ;;(decf h (+ (pxb p) (pxu p)))
        (with-border (b pxh)
          (let* ((size (umin h size))
                 (diff (umax size (pxh (suggest-size (px-size w size) element)))))
            (setf (bounds element) (px-extent x y w diff))
            (decf h diff)
            (incf y diff)))
        (with-border (u pxh)
          (let* ((size (umin h size))
                 (diff (umax size (pxh (suggest-size (px-size w size) element)))))
            (setf (bounds element) (px-extent x (+ y (- h diff)) w diff))
            (decf h diff)))
        (setf h (umax 0 h))
        (with-border (l pxw)
          (let* ((size (umin w size))
                 (diff (umax size (pxw (suggest-size (px-size size h) element)))))
            (setf (bounds element) (px-extent x y diff h))
            (decf w diff)
            (incf x diff)))
        (with-border (r pxw)
          (let* ((size (umin w size))
                 (diff (umax size (pxw (suggest-size (px-size size h) element)))))
            (setf (bounds element) (px-extent (+ x (- w diff)) y diff h))
            (decf w diff)))
        (setf w (umax 0 w))
        (with-border (c pxh)
          (declare (ignore size))
          (setf (bounds element) (px-extent (+ x (if (slot-value layout 'l) (pxl p) 0))
                                            (+ y (if (slot-value layout 'b) (pxb p) 0))
                                            (- w (if (slot-value layout 'l) (pxl p) 0)
                                               (if (slot-value layout 'r) (pxr p) 0))
                                            (- h (if (slot-value layout 'b) (pxb p) 0)
                                               (if (slot-value layout 'u) (pxu p) 0)))))))))

(defmethod notice-size ((element layout-element) (layout border-layout))
  ;; FIXME: this is slow. Should only update as necessary by the change.
  (refit layout))

(defmethod suggest-size (new-size (layout border-layout))
  (macrolet ((with-border ((slot dim) &body body)
               `(destructuring-bind (&optional element size) (slot-value layout ',slot)
                  (when element
                    (let ((size (or size (,dim element))))
                      ,@body)))))
    (with-unit-parent layout
      (let ((w 0) (h 0) (x 0) (y 0))
        (with-border (b pxh)
          (incf h (pxh (suggest-size (px-size (w new-size) size) element)))
          (incf y h))
        (with-border (l w)
          (let ((bounds (suggest-size (px-size size (- (pxh new-size) h)) element)))
            (incf w (pxw bounds))
            (incf x (pxw bounds))
            (setf h (max h (+ y (pxh bounds))))))
        (with-border (c w)
          (let ((size (suggest-size (px-size size (- (pxh new-size) h)) element)))
            (incf w (pxw size))
            (incf x (pxw size))
            (setf h (max h (+ y (pxh size))))))
        (with-border (r w)
          (let ((size (suggest-size (px-size size (- (pxh new-size) h)) element)))
            (incf w (pxw size))
            (incf x (pxw size))
            (setf h (max h (+ y (pxh size))))))
        (setf y h)
        (with-border (u pxh)
          (incf h (pxh (suggest-size (px-size (w new-size) size) element)))
          (incf y h))
        (px-size w h)))))

(defmethod (setf bounds) :after (extent (layout border-layout))
  (refit layout))
