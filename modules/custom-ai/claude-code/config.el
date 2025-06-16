;;; custom-ai/claude-code/config.el -*- lexical-binding: t; -*-

(use-package! claude-code
  :bind-keymap ("C-c c" . claude-code-command-map)
  :config (claude-code-mode)
  )
