;;; custom/chinese-ext/init.el -*- lexical-binding: t; -*-

(use-package-hook! liberime
  :post-init
  (setq liberime-user-data-dir (expand-file-name "~/.config/emacs-liberime/"))
  ;; Linux：推荐系统包管理器安装 librime；无需指定模块和共享数据路径，也无需禁止gcc编译
  (when (eq system-type 'windows-nt)
    (let ((liberime-root (expand-file-name "~/.local/opt/liberime/")))
      (setq liberime-module-file (expand-file-name "bin/liberime-core.dll" liberime-root))
      (setq liberime-shared-data-dir (expand-file-name "share/rime-data/" liberime-root))
      (setq liberime-auto-build nil))) ; Windows 使用预编译 DLL，禁止调用 GCC 自动编译
  t)
