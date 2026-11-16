;;; custom/sidebar/config.el -*- lexical-binding: t; -*-

(when (modulep! :ui treemacs)
  (after! treemacs
    ;; Doom 的 :ui treemacs 模块关闭了跟随,这里重新开启
    (treemacs-follow-mode 1)))

(when (>= emacs-major-version 31)
  ;; speedbar-prefer-window 是 Emacs 31.1 新增的选项,让 speedbar 命令打开窗口而不是独立 frame
  (setq speedbar-prefer-window t
        speedbar-window-default-width 40
        speedbar-window-max-width 60))

;; 显示 speedbar 无法识别类型的文件
(setq speedbar-show-unknown-files t)

(when (modulep! :ui window-select +numbers)
  ;; winum 不为 speedbar 窗口编号
  (after! winum
    (add-to-list 'winum-ignored-buffers " SPEEDBAR")))

(when (modulep! :ui window-select -switch-window)
  ;; ace-window 不为 speedbar 窗口编号
  (after! ace-window
    (add-to-list 'aw-ignored-buffers " SPEEDBAR")))
