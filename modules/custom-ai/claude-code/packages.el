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

(package! eat
  :recipe (:type git
           :host codeberg
           :repo "akib/emacs-eat"
           :files ("*.el" ("term" "term/*.el") "*.texi"
                   "*.ti" ("terminfo/e" "terminfo/e/*")
                   ("terminfo/65" "terminfo/65/*")
                   ("integration" "integration/*")
                   (:exclude ".dir-locals.el" "*-tests.el"))))
