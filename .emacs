(define-key esc-map "G" 'goto-line)             ; Esc-G runs the goto-line
                                                ; function.

(define-key ctl-x-map "t" 'transpose-lines)     ; Ctrl-x t runs the
                                                ; transpose-lines function.
 
(setq require-final-newline t)                  ; Make sure file always
                                                ; ends with a newline.
;(x-set-font "-adobe-courier-medium-r-*-*-20-*-*-*-*-*-*-*")

;(setq default-major-mode 'text-mode)            ; Default mode is text-mode.

(setq text-mode-hook                            ; Enable auto-fill-mode
 '(lambda () (auto-fill-mode 1)))               ; whenever using text-mode.

(setq delete-auto-save-files t)                 ; Delete unnecessary
                                                ; auto-save files.

(defun my-exit-from-emacs()
  (interactive)
  ( if (yes-or-no-p "Do you want to exit ")
      (save-buffers-kill-emacs)))
(global-set-key "\C-x\C-c" 'my-exit-from-emacs)

(defun small-font()
  (interactive)
  (x-set-font "-adobe-courier-bold-r-*-*-12-*-*-*-*-*-*-*"))

(defun large-font()
  (interactive)
  (x-set-font "-adobe-courier-medium-r-*-*-14-*-*-*-*-*-*-*"))




(defun adjust-window-up()
  (interactive)
  (scroll-up 2))

(defun adjust-window-down()
  (interactive)
  (scroll-down 2))

; John Carr <jfc@athena.mit.edu>, Feb 1989
; On both vax and rt the function keys emit "ESC [ # ~"
; The keys map to values of "#" as follows:
; F1            11
; ...
; F5            15
; F6            17
; ...
; F10           21
; F11           23      (RT only; this is "escape" on the vax)
; F12 24
; F13           25      (Vax only; no such key on RT)
; F14           26      (Vax only; no such key on RT)

; First, define an empty keymap to hold the bindings
(defvar fnkey-map (make-sparse-keymap) "Keymap for function keys")

; Second, bind it to ESC-[ (which is the prefix used on the function keys.
(define-key esc-map "[" fnkey-map)

; Third, bind functions to the keys.  Note that you must use the internal
; emacs-lisp function names, which are usually, but not always, the same as
; the name used to invoke the command via M-x.

; One key is bound to a non-standard function: "mail-sig".  This ; is a
; keyboard macro I have defined to sign my mail with a single keystroke.
; When a keyboard macro is invoked, the effects are as if you had typed all
; the characters that make up its definition.  To define a keyboard macro,
; do something like this:

(fset 'mail-sig
  " Lois Bennett <lois@athena.mit.edu>")
                                                 
; The "^M" is a control character, type C-q C-m to insert it.
; This macro can be invoked by typing M-x and its name, or with F2.

(defun set-dir-switch-n()
(interactive)
(setq dired-listing-switches "-Al")) 

(defun set-dir-switch-t()
(interactive)
(setq dired-listing-switches "-Alt"))


(define-key fnkey-map "11~" 'fixup-whitespace)      ; F1
(define-key fnkey-map "12~" 'undo)  ; F2
(define-key fnkey-map "13~" 'what-line) ; F3 Tell current line number
(define-key fnkey-map "14~" 'goto-line)        ; F4
(define-key fnkey-map "15~" 'compile)       ; F5 Run compiler in emacs...
(define-key fnkey-map "17~" 'next-error)    ; F6..and move cursor to next
                                            ; compilation error.
(define-key fnkey-map "18~" 'save-buffer)             ; F7
(define-key fnkey-map "19~" 'exchange-point-and-mark) ; F8
(define-key fnkey-map "20~" 'kill-region)             ; F9 Kill region
(define-key fnkey-map "21~" 'mh-rmail)                      ; F10
(define-key fnkey-map "23~" nil)                      ; F11 ESC
(define-key fnkey-map "24~" 'adjust-window-up)        ; F12
(define-key fnkey-map "25~" 'adjust-window-down)      ; F13
(define-key fnkey-map "26~" 'large-font)             ; F14
(define-key fnkey-map "28~" 'apropos)           ; Help KEY
(define-key fnkey-map "29~" 'yank-pop)                ; Do key
(define-key fnkey-map "1~" 'isearch-forward)          ; Find key
(define-key fnkey-map "2~" 'yank)                     ; Insert Here Key
(define-key fnkey-map "4~" 'set-mark-command )        ; Select key
(define-key fnkey-map "31~" 'small-font)                      ; F17
(define-key fnkey-map "32~" 'set-dir-switch-n)        ; F18
(define-key fnkey-map "33~" 'set-dir-switch-t)        ; F19
(define-key fnkey-map "34~" 'dired)                   ; F20

; A function "nil" does nothing, and acts only as a placeholder for
; convenience in adding new functions later.  The function "beep" does
; the obvious.  (Note: "nil" is a constant and so does not need to be
; quoted; "beep" is the name of a function and needs to be put after
; a single quote (').  All added functions should be quoted in this
; manner.
(global-set-key "OD" 'backward-char)
(global-set-key "OC" 'forward-char)
(global-set-key "OA" 'previous-line)
(global-set-key "OB" 'next-line)
(global-set-key "m" 'mh-smail)


;; sbm customization

;(load-library "shell")
(setq explicit-shell-file-name "/usr/bin/zsh")









