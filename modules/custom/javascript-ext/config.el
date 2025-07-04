;;; custom/javascript-ext/config.el -*- lexical-binding: t; -*-

(use-package! lsp-biome
  :after lsp-mode
  :config
  (setq lsp-biome-organize-imports-on-save t
        lsp-biome-autofix-on-save t
        lsp-biome-format-on-save t)
  (add-to-list 'lsp-biome-active-file-types (rx "." (or "sass" "scss") eos)))

;; lsp-biome 的激活函数依赖 apheleia-formatters 变量存在
;; 但不巧的是 apheleia 不知道什么原因没有给它设置autoload
;; 不得不完整加载 apheleia
(add-hook 'web-mode-hook
          (lambda ()
            (unless (boundp 'apheleia-formatters)
              (require 'apheleia))
            (apheleia-mode 1)))
