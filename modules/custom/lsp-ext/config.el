;;; custom/lsp-ext/config.el -*- lexical-binding: t; -*-

(after! lsp-mode
  (setq lsp-file-watch-threshold 1500      ;; 酌情调大lsp监控的文件数量
        lsp-enable-on-type-formatting t    ;; 打字时就允许格式化
        lsp-before-save-edits t            ;; ?暂时不清楚意图
        lsp-headerline-breadcrumb-enable t ;; 在headerline显示面包屑
        )
  (setq lsp-imenu-sort-methods '(kind position))) ;; lsp-ui-imenu出现后的排序

(load! "biome-lsp-mode")
(load! "oxlint-lsp-mode")
(load! "eglot-angular")
(load! "eglot-typescript")

(when (modulep! :tools lsp +eglot)
  ;; JavaScript和TSX文件不会属于Angular项目,不需要动态选择客户端
  (set-eglot-client!
   '((js-ts-mode :language-id "javascript")
     (tsx-ts-mode :language-id "typescriptreact"))
   (lambda (interactive-p)
     (funcall
      (eglot-alternatives
       (lsp-ext/typescript-server-alternatives))
      interactive-p)))

  ;; TypeScript 7.0内置了原生LSP Server; Angular项目使用ngserver作为备选客户端
  (set-eglot-client!
   '((typescript-ts-mode :language-id "typescript")
     (typescript-mode :language-id "typescript"))
   (lambda (interactive-p project)
     (funcall
      (eglot-alternatives
       (append
        (lsp-ext/typescript-server-alternatives)
        (lsp-ext/angular-server-alternatives project)))
      interactive-p project)))

  ;; HTML文件优先使用完整的HTML语言服务器; Angular项目将ngserver作为备选客户端
  (set-eglot-client!
   '((html-mode :language-id "html")
     (html-ts-mode :language-id "html")
     (web-mode :language-id "html"))
   (lambda (interactive-p project)
     (funcall
      (eglot-alternatives
       (append
        '(("vscode-html-language-server" "--stdio")
          ("html-languageserver" "--stdio"))
        (lsp-ext/angular-server-alternatives project)))
      interactive-p project)))

  ;; json-mode派生自js-mode,将Eglot已有的JSON客户端移到JavaScript客户端之前
  (after! eglot
    (when-let ((client
                (assoc '(js-json-mode json-mode json-ts-mode jsonc-mode)
                       eglot-server-programs)))
      (setq eglot-server-programs
            (cons client (delq client eglot-server-programs)))))

  ;; Eglot没有内置breadcrumb,启用Eglot作者提供的第三方包
  (use-package! breadcrumb
    :config
    (breadcrumb-mode 1)

    ;; Org源码编辑buffer没有buffer-file-name,需要显式启用breadcrumb
    (add-hook! 'org-src-mode-hook
      (defun +lsp-ext-enable-breadcrumb-in-json-org-src-h ()
        (when (derived-mode-p 'json-mode 'json-ts-mode 'jsonc-mode)
          ;; Org将退出提示作为字符串放在header-line-format中,breadcrumb-local-mode要求header-line-format为列表
          (unless (listp header-line-format)
            (setq header-line-format (list header-line-format)))
          (breadcrumb-local-mode 1))))))
