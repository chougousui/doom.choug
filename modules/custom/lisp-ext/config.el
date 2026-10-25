;;; custom/lisp-ext/config.el -*- lexical-binding: t; -*-

(defun lisp-ext/cleanup-whitespace-on-save ()
  "Run whitespace-cleanup if current buffer is in any Lisp mode."
  (when (derived-mode-p 'lisp-mode 'emacs-lisp-mode 'common-lisp-mode 'clojure-mode 'scheme-mode)
    (whitespace-cleanup)))

(add-hook! 'before-save-hook #'lisp-ext/cleanup-whitespace-on-save)

;; 将C-x C-e绑定为打印在当前buffer的那个函数上
(map! :map emacs-lisp-mode-map
      "C-x C-e" #'eval-print-last-sexp)
