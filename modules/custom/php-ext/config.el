;;; custom/php-ext/config.el -*- lexical-binding: t; -*-

(use-package! apheleia
  :defer t
  :init
  ;; 在特定条件下禁用apheleia-mode
  (defun php-ext/inhibit-apheleia-f ()
    (and (eq major-mode 'php-mode) ;; 如果是php-mode
         t))                       ;; 且 TODO (比如不是自己创建的文件,通过外部git alias实现), 则禁用apheleia-mode

  ;; 为方便提前定义functions的内容,apheleia autoload了这个变量
  ;; 作为占位符功能,不会在包初始化前抛出变量未定义的问题
  (add-to-list 'apheleia-inhibit-functions #'php-ext/inhibit-apheleia-f)
  )

(after! apheleia
  ;; 添加prettier格式化器
  (add-to-list 'apheleia-formatters
               '(prettier-php . ("apheleia-npx" "prettier" "--stdin-filepath" filepath
                                 "--parser=php"
                                 "--plugin=@prettier/plugin-php")))

  ;; 指定php的格式化工具为prettier-php
  (setf (alist-get 'php-mode apheleia-mode-alist) 'prettier-php)
  )
