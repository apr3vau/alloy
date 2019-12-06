#|
 This file is a part of Alloy
 (c) 2019 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.alloy)

(defclass fixed-layout (layout vector-container)
  ())

(defmethod notice-bounds ((element layout-element) (layout fixed-layout))
  ;; Calculate max bound
  (let ((extent (bounds layout)))
    (destructure-extent (:x lx :y ly :w lw :h lh :to-px T) extent
      (destructure-extent (:x ex :y ey :w ew :h eh :to-px T) (bounds element)
        (let ((l (min lx ex))
              (b (min ly ey))
              (r (max (+ lx lw) (+ ex ew)))
              (u (max (+ ly lh) (+ ey eh))))
          (setf (bounds layout)
                (px-extent l b (- r l) (- u b))))))))

(defmethod suggest-bounds (extent (layout fixed-layout)))

(defmethod enter :after ((element layout-element) (layout fixed-layout) &key x y w h)
  (update element layout :x x :y y :w w :h h)
  ;; Ensure we set the layout extent to the element bounds or we would calculate
  ;; the max bound wrong.
  (when (= 1 (element-count layout))
    (setf (bounds layout) (bounds element))))

(defmethod leave :after ((element layout-element) (layout fixed-layout))
  (when (= 0 (element-count layout))
    (setf (bounds layout) (extent))))

(defmethod update :after ((element layout-element) (layout fixed-layout) &key x y w h)
  (let ((e (bounds element)))
    (with-unit-parent layout
      (setf (bounds element)
            (px-extent (or x (extent-x e))
                       (or y (extent-y e))
                       (or w (extent-w e))
                       (or h (extent-h e)))))
    element))

(defmethod ensure-visible :before ((element layout-element) (layout fixed-layout))
  ;; Find parent
  (loop until (or (eq layout (layout-parent element))
                  (eq element (layout-parent element)))
        do (setf element (layout-parent element)))
  (when (eq layout (layout-parent element))
    ;; Shuffle to ensure element is last, and thus drawn on top.
    (rotatef (aref (elements layout) (1- (length (elements layout))))
             (aref (elements layout) (position element (elements layout))))))
