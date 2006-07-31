;;; auto-overlay-word.el --- automatic overlays for single "words"

;; Copyright (C) 2005 Toby Cubitt

;; Author: Toby Cubitt
;; Version: 0.1
;; Keywords: automatic, overlays, word

;; This file is part of the Emacs Automatic Overlays package.
;;
;; The Emacs Automatic Overlays package is free software; you can
;; redistribute it and/or modify it under the terms of the GNU
;; General Public License as published by the Free Software
;; Foundation; either version 2 of the License, or (at your option)
;; any later version.
;;
;; The Emacs Automatic Overlays package is distributed in the hope
;; that it will be useful, but WITHOUT ANY WARRANTY; without even the
;; implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with the Emacs Automatic Overlays package; if not, write
;; to the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
;; Boston, MA 02111-1307 USA


;;; Change Log:
;;
;; Version 0.1:
;; * initial version separated off from auto-overlays.el



;;; Code:


(require 'auto-overlays)
(provide 'auto-overlay-word)


;; register word overlay parsing and suicide functions
(assq-delete-all 'word auto-overlay-functions)
(push (list 'word 'auto-o-parse-word-match
	    (lambda (o) (auto-o-delete-overlay (overlay-get o 'parent))))
      auto-overlay-functions)



(defun auto-o-parse-word-match (o-match)
  ;; Create a new word overlay for new word match
  (let ((o-new (make-overlay (overlay-get o-match 'delim-start)
			     (overlay-get o-match 'delim-end)
			     nil nil 'rear-advance)))
    
    ;; give overlays appropriate properties
    (overlay-put o-new 'auto-overlay t)
    (overlay-put o-new 'set (overlay-get o-match 'set))
    (overlay-put o-new 'type (overlay-get o-match 'type))
    (overlay-put o-new 'start o-match)
    (overlay-put o-match 'parent o-new)
    ;; bundle properties inside list if not already, then update set overlay
    ;; properties
    (let ((props (auto-o-props o-match)))
      (when (symbolp (car props)) (setq props (list props)))
      (dolist (p (auto-o-props o-match))
	(overlay-put o-new (car p) (cdr p))))
    
    ;; if new overlay is exclusive, delete lower priority overlays within it
    (when (and (overlay-get o-new 'exclusive)
	       (/= (overlay-start o-new) (overlay-end o-new)))
      (auto-o-update-exclusive (overlay-get o-new 'set)
			       (overlay-start o-new) (overlay-end o-new)
			       nil (overlay-get o-new 'priority)))
    
    ;; return new overlay
    o-new)
)


;; auto-overlay-word.el ends here
