;;; custom/lua-ext/config.el -*- lexical-binding: t; -*-

(after! apheleia
  ;; 添加格式化工具
  (add-to-list 'apheleia-formatters
               '(styluas . ("stylua" "-s" "-")))

  ;; 设置lua的默认格式化器为styluas(apheleia-mode-alist并非autoload,只能在启动后操作)
  (setf (alist-get 'lua-mode apheleia-mode-alist) 'styluas)
  )
