;;; custom/modeline-ext/config.el -*- lexical-binding: t; -*-

;; 加载自定义segments的函数
(load! "segments")

(after! doom-modeline
  (setq
   doom-modeline-buffer-encoding t      ;; 总是显示文件的编码和换行风格
   doom-modeline-env-version nil        ;; 不要在major mode显示语言的全局版本(没有意义)
   )
  ;; 此时生成自定义的segment
  (custom-modeline-ext/create-custom-segments)

  ;; 定义modeline显示项目
  (doom-modeline-def-modeline 'main
    ;; 左边
    '(eldoc bar workspace-name window-number modals follow matches buffer-info remote-host major-mode vcs)
    ;; 右边
    '(venv check input-method indent-info buffer-encoding selection-info buffer-position)))
