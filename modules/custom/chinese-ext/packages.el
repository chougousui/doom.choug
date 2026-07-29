;; -*- no-byte-compile: t; -*-
;;; custom/chinese-ext/packages.el

(package! liberime
  :recipe (:host github
           :repo "chougousui/liberime"
           :branch "fix/pyim-search")
  :pin nil)
