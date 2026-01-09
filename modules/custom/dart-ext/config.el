;;; custom/dart-ext/config.el -*- lexical-binding: t; -*-

(after! lsp-dart
  (setq lsp-dart-flutter-sdk-dir "~/fvm/default/")
  (setq lsp-dart-sdk-dir "~/fvm/default/bin/cache/dart-sdk")
  ;; AI推荐的,但不知道原因
  ;; (add-to-list 'lsp-language-id-configuration '(dart-ts-mode . "dart"))
  )

;; (after! lsp-mode
;;   (setq lsp-disabled-clients '(semgrep-ls)))

;; 如果不告知stdin-name,dart format无法开始查找项目中的analysis_options.yaml文件
(after! apheleia
  (setf (alist-get 'dart-format apheleia-formatters)
        '("dart" "format" "--stdin-name" filepath)))

(after! dart-ts-mode
  ;; doom emacs官方使用的tree-sitter语法文件已经不再维护
  (setf (alist-get 'dart treesit-language-source-alist)
        ;; 设置后运行 treesit-install-language-grammar RET dart RET 可以下载语法文件
        ;; '("https://github.com/UserNobody14/tree-sitter-dart" nil nil nil nil "e81af6ab94a728ed99c30083be72d88e6d56cf9e")
        '("https://github.com/UserNobody14/tree-sitter-dart")))
