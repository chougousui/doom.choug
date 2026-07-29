;;; custom/chinese-ext/init.el -*- lexical-binding: t; -*-

(use-package-hook! liberime
  :post-init
  (setq liberime-user-data-dir
        (expand-file-name "~/.config/emacs-liberime"))
  t)
