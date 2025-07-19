;;; modules/custom/json-ext/config.el -*- lexical-binding: t; -*-

;; 为 JSONC 文件扩展名添加 jsonc-mode
(add-to-list 'auto-mode-alist '("\\.jsonc\\'" . jsonc-mode))

;; 处理常见的配置文件,这些文件本应使用 jsonc 后缀但实际上通常使用 json 后缀,因此使用 jsonc-mode 打开
(add-to-list 'auto-mode-alist '("tsconfig\\.json\\'" . jsonc-mode))
(add-to-list 'auto-mode-alist '("\\.vscode/.*\\.json\\'" . jsonc-mode))
(add-to-list 'auto-mode-alist '("jsconfig\\.json\\'" . jsonc-mode))