;;; custom/kotlin-ext/config.el -*- lexical-binding: t; -*-

;; 1. 只有当 lsp-mode 加载后才加载并注册我们的自定义 LSP Client
(after! lsp-mode
  (load! "lsp-kotlin-official"))

;; 2. 配置 apheleia 使用 ktfmt 格式化 Kotlin 代码
(after! apheleia
  ;; 定义 ktfmt 格式化器
  ;; 注意 filepath 这个内部变量,由于延迟求值的问题,不能用于拼接路径
  (add-to-list 'apheleia-formatters
               '(ktfmt "ktfmt.sh"
                 (concat "--stdin-name=" (or (apheleia-formatters-local-buffer-file-name)
                                             (buffer-file-name)
                                             "stdin.kt"))
                 "-"))

  ;; 绑定 kotlin 相关的 mode 到 ktfmt
  (setf (alist-get 'kotlin-mode apheleia-mode-alist) 'ktfmt)
  (setf (alist-get 'kotlin-ts-mode apheleia-mode-alist) 'ktfmt))
