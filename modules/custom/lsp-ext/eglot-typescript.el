;;; custom/lsp-ext/eglot-typescript.el -*- lexical-binding: t; -*-

;; TS7的tsc用Go重写,内置了语言服务器,可以直接`tsc --lsp --stdio'启动。
;;
;; 不能把tsc和typescript-language-server一起交给`set-eglot-client!'让`eglot-alternatives'择一:
;; 它只按`executable-find'判断命令在不在,而TS7以下的tsc同样存在、同样会被选中,
;; 却不认`--lsp',结果是启动即失败。版本探测因此只能自己做。
;;
;; 环境里不再可能出现TS7以下的tsc后,可删除本文件,改回一行`set-eglot-client!'。

(when (modulep! :tools lsp +eglot)
  (set-eglot-client!
   ;; Eglot缺省把mode名去掉`-ts-mode'后缀当languageId,`js-ts-mode'会得到"js"、
   ;; `tsx-ts-mode'会得到"tsx",都不是服务器认识的值,所以逐个显式指定
   '((js-ts-mode :language-id "javascript")
     (tsx-ts-mode :language-id "typescriptreact")
     (typescript-ts-mode :language-id "typescript")
     (typescript-mode :language-id "typescript"))
   ;; tsc主版本号大于6才用它自带的LSP,否则回落到typescript-language-server
   (lambda (_interactive _project)
     (let* ((tsc (executable-find "tsc"))
            (major-version (and tsc (my/js-tsc-major-version tsc))))
       (if (and major-version (> major-version 6))
           (list tsc "--lsp" "--stdio")
         '("typescript-language-server" "--stdio"))))))

(defun my/js-tsc-major-version (tsc)
  "取TSC的主版本号,取不到返回nil。
`process-lines'在tsc跑不起来时会抛错,这里咽掉以便回落到别的服务器。"
  (let ((output (ignore-errors (car (process-lines tsc "--version")))))
    ;; 输出形如`Version 7.0.2'或`Version 6.0.3',取第一个数字段
    (when (and output (string-match "\\([0-9]+\\)\\." output))
      (string-to-number (match-string 1 output)))))
