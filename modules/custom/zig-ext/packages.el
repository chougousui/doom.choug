;; -*- no-byte-compile: t; -*-
;;; custom/zig-ext/packages.el

(when (and (modulep! :lang zig +tree-sitter) (treesit-available-p))
  ;; doom官方的给 zig-ts-mode 使用的 3898b70d6f72da688e086323fa2922f1542d1318 版本,
  ;; 无法兼容tree-sitter-grammars/tree-sitter-zig的最新语法
  ;; 但zig-ts-mode已经在一个更新的版本中兼容tree-sitter-grammars/tree-sitter-zig的最新语法
  (package! zig-ts-mode :pin "89b52c865c64d4f887c94445e3283486cf358782"))
