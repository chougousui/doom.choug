;;; custom/org-ext/funcs.el -*- lexical-binding: t; -*-

;; 参照org-timestamp改写,沿用org-read-date的日期输入,输出改为"Wed 2026-10-21"格式
;; 该格式不会被Org识别为时间戳,所以去掉了替换已有时间戳、日期范围和重复器的分支
(defun +org-ext/insert-date (&optional arg)
  "提示输入日期,以 \"Wed 2026-10-21\" 格式插入,minibuffer预览也使用该格式。
带两个 \\[universal-argument] 前缀时不提示,直接插入今天。"
  (interactive "P")
  ;; org-read-date没有autoload,org未加载时需要先加载
  (require 'org)
  (let* ((date-format "%a %F")
         ;; 星期固定用英文缩写,不随locale变化,预览和插入都生效
         (system-time-locale "C")
         (time (if (equal arg '(16))
                   (current-time)
                 ;; 预览由org-read-date-display经org-time-stamp-format取格式,
                 ;; 只在本次读日期期间替换成同一格式,不影响C-c .
                 (cl-letf (((symbol-function 'org-time-stamp-format)
                            (lambda (&rest _) date-format)))
                   (org-read-date nil t)))))
    (insert (format-time-string date-format time))))
