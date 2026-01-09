;;; custom/zig-ext/config.el -*- lexical-binding: t; -*-

(after! treesit
  (add-to-list 'treesit-language-source-alist
               '(zig "https://github.com/tree-sitter-grammars/tree-sitter-zig")))
