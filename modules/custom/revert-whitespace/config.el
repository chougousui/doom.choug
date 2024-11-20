;;; custom/revert-whitespace/config.el -*- lexical-binding: t; -*-

;; 撤销 ~/.config/emacs/lisp/doom-ui.el 对whitespace的自定义
(use-package whitespace
  :config
  (setq
   whitespace-line-column 120           ;; 默认80,doom-ui设置为nil,这里稍微修改一下
   whitespace-style '(face
                      tabs spaces trailing lines space-before-tab newline
                      indentation empty space-after-tab
                      space-mark tab-mark newline-mark
                      missing-newline-at-eof)
   whitespace-display-mappings '(
                                 (space-mark   ?\     [?·]     [?.])            ; space - middle dot
                                 (space-mark   ?\xA0  [?¤]     [?_])            ; hard space - currency sign
                                 (newline-mark ?\n    [?$ ?\n])                         ; eol - dollar sign
                                 (tab-mark     ?\t    [?» ?\t] [?\\ ?\t])       ; tab - right guillemet
                                 )
   ))

;; 撤销doom-ui.el中添加的hook(doom-highlight-non-default-indentation-h根据一些模式修改hook内容)
(add-hook 'window-setup-hook
          (lambda ()
            (remove-hook 'after-change-major-mode-hook #'doom-highlight-non-default-indentation-h))
          -99)  ;; 比 doom-init-ui-h 晚执行
