;; -*- no-byte-compile: t; -*-
;;; custom-ai/claude-code/packages.el

(package! claude-code
  :recipe (:type git
           :host github
           :repo "stevemolitor/claude-code.el"
           :branch "main"
           :files ("*.el" (:exclude "demo.gif"))
           )
  )
