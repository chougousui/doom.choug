;;; custom/choug/funcs.el -*- lexical-binding: t; -*-

;; 基于doom自定义的+vertico/project-search改写自己的函数
(defun choug/project-search-dwim (&optional arg initial-query directory)
  "项目内搜索，使用光标处内容或选中文本。前缀参数 ARG 用于搜索所有文件（含隐藏文件）。"
  (interactive "P")
  (let ((initial-input (or initial-query (doom-thing-at-point-or-region 'symbol))))
    (+vertico/project-search arg initial-input directory)))

(defun choug/delete-word (arg)
  "Delete characters forward until encountering the end of a word.
With argument ARG, do this that many times."
  (interactive "p")
  (delete-region (point) (progn (forward-word arg) (point))))

(defun choug/backward-delete-word (arg)
  "Delete characters backward until encountering the beginning of a word.
With argument ARG, do this that many times."
  (interactive "p")
  (choug/delete-word (- arg)))

(defun choug/backward-delete-word-or-region (&optional arg)
  "M-DEL时仅删除,不复制"
  (interactive "p")
  (if (region-active-p)
      (call-interactively #'delete-region)
    (choug/backward-delete-word arg)))

(defun choug/minify ()
  "从光标所在位置,至匹配的括号处,将选定的内容合并为一行"
  (interactive)
  (let ((start (point)))
    (save-excursion
      (forward-list)
      (delete-indentation nil start (point)))))

(defun choug/align-comment-dwim ()
  "对齐一个区域内的注释,
   若已经指定区域,则直接调用,
   否则将光标所在括号范围作为区域"
  (interactive)
  ;; 获取注释符号用comment-start,可能为nil
  ;; let声明多个变量时不能有依赖关系,但let*可以
  (let* ((comment-start-char (or comment-start "//"))
         (align-pattern (concat "\\(\\s-*\\)" comment-start-char)))
    (if (region-active-p)
        (align-regexp (region-beginning) (region-end) align-pattern)
      (save-excursion
        (backward-up-list)
        (let ((start (point)))
          (forward-list)
          (align-regexp start (point) align-pattern))))))
