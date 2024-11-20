;; -*- no-byte-compile: t; -*-
;;; custom/python-ext/packages.el

;; 一个package!宏只能写一个package
;; 使用ruff格式化后不需要isort了
(package! py-isort :disable t)

;; 目前暂时不需要test支持
(package! nose :disable t)
(package! python-pytest :disable t)
