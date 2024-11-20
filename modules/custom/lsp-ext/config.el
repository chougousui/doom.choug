;;; custom/lsp-ext/config.el -*- lexical-binding: t; -*-

(after! lsp-mode
  (setq lsp-file-watch-threshold 1500      ;; 酌情调大lsp监控的文件数量
        lsp-enable-on-type-formatting t    ;; 打字时就允许格式化
        lsp-before-save-edits t            ;; ?暂时不清楚意图
        lsp-headerline-breadcrumb-enable t ;; 在headerline显示面包屑
        ))
