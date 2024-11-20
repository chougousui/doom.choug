;;; custom/go-ext/config.el -*- lexical-binding: t; -*-

(after! apheleia
  ;; 使用 add-to-list 将 golines 格式化器添加到 apheleia-formatters
  (add-to-list 'apheleia-formatters
               '(golines . ("golines" "-m" "120" "--base-formatter=gofumpt")))
  ;; 设置go的默认格式化器为golines
  (setf (alist-get 'go-mode apheleia-mode-alist) 'golines)
  (setf (alist-get 'go-ts-mode apheleia-mode-alist) 'golines)
  )

;; 提供一个交互式命令来特定使用golines
(defun golines-format-buffer ()
  "使用golines格式化器格式化当前buffer"
  (interactive)
  (apheleia-format-buffer 'golines))
