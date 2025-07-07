;;; custom/javascript-ext/config.el -*- lexical-binding: t; -*-

;; web-mode中没有设置非web-mode相关(比如typescript-mode)的内容
;; 但typescript-mode的内容影响tsx文件中的行为
(setq typescript-indent-level 2
      web-mode-css-indent-offset 2
      ;; 虽然这个归css-mode管,不关javascript module的事
      ;; 但是为了体验统一,也要一起修改
      css-indent-offset 2
      )

;; lsp-biome在检测到 biome.json(c) 的时候会启动
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
(dolist (hook '(web-mode-hook typescript-mode-hook js2-mode-hook css-mode-hook))
  (add-hook hook (lambda ()
                   (unless (boundp 'apheleia-formatters)
                     (require 'apheleia))
                   (apheleia-mode 1))))
