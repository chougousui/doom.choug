;;; custom/company-ext/config.el -*- lexical-binding: t; -*-

(after! company
  (setq company-idle-delay 0.05)
  (dolist (backend '(
                     company-files      ;; 可以以系统的文件路径作为补全资料
                     company-dabbrev    ;; 以各种打开的buffer中的内容作为补全资料,无论是否代码
                     ))
    (add-to-list 'company-backends backend))
  )
