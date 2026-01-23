;;; custom/javascript-ext/lsp-oxlint.el -*- lexical-binding: t; -*-

;; 为 lsp-mode 提供 oxlint LSP 集成
;; 激活条件: major-mode 匹配 + 项目根目录有配置文件

(defun lsp-oxlint--activation-fn (filename &optional _)
  "激活条件: major-mode 匹配 + 项目根目录有配置文件"
  (and filename
       ;; 先判断 major-mode
       (seq-some (lambda (mode)
                   (provided-mode-derived-p major-mode mode))
                 '(typescript-ts-base-mode
                   js-base-mode))
       ;; 再判断项目根路径和配置文件
       (when-let ((root (doom-project-root)))
         (seq-some (lambda (config)
                     (file-exists-p (expand-file-name config root)))
                   '(".oxlintrc.json"
                     ".oxlintrc.jsonc")))))

(lsp-register-client
 (make-lsp-client
  :new-connection (lsp-stdio-connection '("oxlint" "--lsp"))
  :activation-fn #'lsp-oxlint--activation-fn
  :priority 1
  :server-id 'oxlint
  :add-on? t
  :multi-root nil))

;; 验证 lsp-oxlint 客户端配置的完整性
(lsp-consistency-check lsp-oxlint)
