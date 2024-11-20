;;; custom/fcitx/config.el -*- lexical-binding: t; -*-

;; 不知道为什么,仅仅在GUI模式下,fcitx才有效
(use-package! fcitx
  :config
  (setq fcitx-use-dbus 'fcitx5
        fcitx-remote-command (executable-find "fcitx5-remote"))
  (fcitx-aggressive-setup)
  (fcitx-prefix-keys-add "M-m" "M-RET" "C-h" "C-c" "C-x" "C-M-s")
  )
