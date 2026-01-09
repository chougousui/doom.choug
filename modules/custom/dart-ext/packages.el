;; -*- no-byte-compile: t; -*-
;;; custom/dart-ext/packages.el

(when (and (modulep! :lang dart +tree-sitter) (treesit-available-p))
  (package! dart-ts-mode
    ;; doom官方使用的dart-ts-mode很久不维护,font-lock无法跟进grammar的最新状态
    :recipe (:host github :repo "msrocka/dart-ts-mode")))
