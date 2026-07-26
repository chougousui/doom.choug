;;; custom/lsp-ext/eglot-typescript.el -*- lexical-binding: t; -*-

(defun lsp-ext/tsc-major-version (tsc)
  "取TSC的主版本号,取不到返回nil。
`process-lines'在tsc跑不起来时会抛错,这里咽掉以便回落到别的服务器。"
  (let ((output (ignore-errors (car (process-lines tsc "--version")))))
    ;; 输出形如`Version 7.0.2'或`Version 6.0.3',取第一个数字段
    (when (and output (string-match "\\([0-9]+\\)\\." output))
      (string-to-number (match-string 1 output)))))

(defun lsp-ext/typescript-server-alternatives ()
  "构造用于typescript的可用lsp列表.
tsc版本大于等于7: 返回[tsc, typescript-language-server]
否则返回[typescript-language-server]"
  (let* ((tsc (executable-find "tsc"))
         (major-version
          (and tsc (lsp-ext/tsc-major-version tsc))))
    (append
     (when (and major-version (>= major-version 7))
       (list (list tsc "--lsp" "--stdio")))
     '(("typescript-language-server" "--stdio")))))

;; overwrite: 固定使用TypeScript 7自带的LSP Server
(defun lsp-ext/typescript-server-alternatives ()
  (list
   (list
    (expand-file-name "~/.local/share/mise/installs/node/lts/bin/tsc")
    "--lsp"
    "--stdio")))
