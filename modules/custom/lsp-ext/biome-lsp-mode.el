;;; custom/lsp-ext/biome-lsp-mode.el -*- lexical-binding: t; -*-

;; 为 lsp-mode 提供 Biome LSP 集成
;; 激活条件: major-mode 匹配 + 项目根目录有配置文件

(after! lsp-mode
  (defun biome--activation-fn (filename &optional _)
    "激活条件: major-mode 匹配 + 项目根目录有配置文件。"
    (and filename
         (seq-some (lambda (mode)
                     (provided-mode-derived-p major-mode mode))
                   '(typescript-ts-base-mode
                     typescript-mode
                     js-base-mode
                     js2-mode
                     js3-mode
                     json-mode
                     json-ts-mode
                     css-mode
                     web-mode))
         (when-let ((root (doom-project-root)))
           (seq-some (lambda (config)
                       (file-exists-p (expand-file-name config root)))
                     '("biome.json"
                       "biome.jsonc")))))

  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection '("biome" "lsp-proxy"))
    :activation-fn #'biome--activation-fn
    :priority 10                    ;; 数字越大，优先级越高
    :server-id 'biome
    :add-on? t
    :multi-root nil))

  (lsp-consistency-check biome))
