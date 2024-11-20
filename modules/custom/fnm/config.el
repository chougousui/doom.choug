;;; custom/fnm/config.el -*- lexical-binding: t; -*-

;; 固定将fnm的默认路径添加到PATH和exec-path(如果以GUI方式启动)(如果路径存在)
(when (display-graphic-p)
  (let ((fnm-default-bin (expand-file-name "~/.local/share/fnm/aliases/default/bin")))
    (when (file-directory-p fnm-default-bin)
      (setenv "PATH" (concat fnm-default-bin path-separator (getenv "PATH")))
      (add-to-list 'exec-path fnm-default-bin))))
