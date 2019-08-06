#|
 This file is a part of Alloy
 (c) 2019 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(defpackage #:org.shirakumo.alloy
  (:use #:cl)
  ;; component.lisp
  (:export
   #:component)
  ;; container.lisp
  (:export
   #:element
   #:container
   #:enter
   #:leave
   #:update
   #:elements
   #:element-count
   #:call-with-elements
   #:do-elements
   #:vector-container
   #:element-table
   #:associate
   #:disassociate
   #:associated-element)
  ;; events.lisp
  (:export
   #:handle
   #:event
   #:decline
   #:pointer-event
   #:location
   #:pointer-move
   #:old-location
   #:pointer-down
   #:kind
   #:pointer-up
   #:kind
   #:scroll
   #:direct-event
   #:text-event
   #:text
   #:key-event
   #:key
   #:code
   #:key-down
   #:key-up
   #:focus-event
   #:focus-next
   #:focus-prev
   #:focus-up
   #:focus-down
   #:activate
   #:exit)
  ;; focus-tree.lisp
  (:export
   #:focus-element
   #:focus-tree
   #:parent
   #:focus
   #:exit
   #:activate
   #:notice-focus
   #:index
   #:focused
   #:element-index
   #:focus-next
   #:focus-prev
   #:focus-up
   #:focus-down
   #:root
   #:focus-element
   #:focus-entry
   #:focus-chain
   #:focus-list
   #:focus-grid
   #:focus-tree)
  ;; geometry.lisp
  (:export
   #:x
   #:y
   #:w
   #:h
   #:contained-p
   #:point
   #:point-p
   #:copy-point
   #:point-x
   #:point-y
   #:point=
   #:size
   #:size-p
   #:copy-size
   #:size-w
   #:size-h
   #:size=
   #:extent
   #:copy-extent
   #:extent-p
   #:extent-x
   #:extent-y
   #:extent-w
   #:extent-h
   #:extent=
   #:destructure-extent
   #:with-extent)
  ;; layout.lisp
  (:export
   #:layout-tree
   #:bounds
   #:layout-element
   #:notice-bounds
   #:suggest-bounds
   #:layout-element
   #:layout-entry
   #:component
   #:layout
   #:layout-tree)
  ;; renderer
  (:export
   #:allocate
   #:allocated-p
   #:deallocate
   #:register
   #:render-needed-p
   #:mark-for-render
   #:render
   #:maybe-render
   #:renderer
   #:renderable)
  ;; ui.lisp
  (:export
   #:extent-for
   #:focus-for
   #:clipboard
   #:cursor
   #:ui
   #:layout-tree
   #:focus-tree))

(defpackage #:org.shirakumo.alloy.renderer.simple
  (:use #:cl)
  (:local-nicknames
   (#:alloy #:org.shirakumo.alloy))
  ;; protocol.lisp
  (:export
   #:push-transforms
   #:pop-transforms
   #:clip
   #:translate
   #:scale
   #:rotate
   #:push-styles
   #:pop-styles
   #:fill-color
   #:line-width
   #:fill-mode
   #:composite-mode
   #:font
   #:font-size
   #:line
   #:rectangle
   #:ellipse
   #:polygon
   #:text
   #:image
   #:clear
   #:wrap-text
   #:request-font
   #:request-image
   #:color
   #:color-p
   #:copy-color
   #:r
   #:g
   #:b
   #:a
   #:font
   #:image
   #:simple-renderer
   #:with-pushed-transforms
   #:with-pushed-styles)
  ;; transforms.lisp
  (:export
   #:matrix
   #:matrix-identity
   #:mat*
   #:transform
   #:clip-mask
   #:transform-matrix
   #:add-matrix
   #:simple-transformed-renderer
   #:make-default-transform)
  ;; style.lisp
  (:export
   #:style
   #:simple-styled-renderer
   #:make-default-style))
