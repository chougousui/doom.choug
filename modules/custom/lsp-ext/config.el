;;; custom/lsp-ext/config.el -*- lexical-binding: t; -*-

(after! lsp-mode
  (setq lsp-file-watch-threshold 1500      ;; 酌情调大lsp监控的文件数量
        lsp-enable-on-type-formatting t    ;; 打字时就允许格式化
        lsp-before-save-edits t            ;; ?暂时不清楚意图
        lsp-headerline-breadcrumb-enable t ;; 在headerline显示面包屑
        )
  (setq lsp-imenu-sort-methods '(kind position)) ;; lsp-ui-imenu出现后的排序
  )

(when (modulep! :tools lsp +eglot)
  ;; TypeScript 7.0 内置了原生LSP Server, tsc --lsp --stdio,其他保持eglot-server-programs里面的其他默认值
  (set-eglot-client!
   '((js-mode :language-id "javascript")
     (js-ts-mode :language-id "javascript")
     (tsx-ts-mode :language-id "typescriptreact")
     (typescript-ts-mode :language-id "typescript")
     (typescript-mode :language-id "typescript"))
   '("tsc" "--lsp" "--stdio")
   '("rass ts")
   '("typescript-language-server" "--stdio"))

  ;; 让web-mode使用与html-mode相同的语言服务器,并发送正确的languageId
  (set-eglot-client!
   '(web-mode :language-id "html")
   '("vscode-html-language-server" "--stdio")
   '("html-languageserver" "--stdio"))

  ;; Eglot没有内置breadcrumb,启用Eglot作者提供的第三方包
  (use-package! breadcrumb
    :config
    (breadcrumb-mode 1)))
