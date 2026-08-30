;;; custom/velocity-script/config.el -*- lexical-binding: t; -*-

;; 为 Apache Velocity 模板提供语法支持
;; velocity-script-mode 继承自 web-mode, web-mode 由 :lang (web +lsp +tree-sitter) 提供,
;; 不在本模块重复声明 package
(add-to-list 'auto-mode-alist '("\\.\\(vm\\|vtl\\)\\'" . velocity-script-mode))

(load! "velocity-script")

;; 使用自定义工具vtlfmt来做格式化
(when (modulep! :editor format)
  (after! apheleia
    (setf (alist-get 'vtlfmt apheleia-formatters)
          '("vtlfmt" "--stdin-filepath" filepath))
    (setf (alist-get 'velocity-script-mode apheleia-mode-alist) 'vtlfmt)))
