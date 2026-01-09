;;; custom/dart-ext/config.el -*- lexical-binding: t; -*-

(after! lsp-dart
  (setq lsp-dart-flutter-sdk-dir "~/fvm/default/")
  (setq lsp-dart-sdk-dir "~/fvm/default/bin/cache/dart-sdk"))

;; (after! lsp-mode
;;   (setq lsp-disabled-clients '(semgrep-ls)))

;; 如果不告知stdin-name,dart format无法开始查找项目中的analysis_options.yaml文件
(after! apheleia
  (setf (alist-get 'dart-format apheleia-formatters)
        '("dart" "format" "--stdin-name" filepath)))
