;;; custom/php-ext/config.el -*- lexical-binding: t; -*-

(after! apheleia
  ;; 添加prettier格式化器
  (add-to-list 'apheleia-formatters
               '(prettier-php . ("apheleia-npx" "prettier" "--stdin-filepath" filepath
                                 "--parser=php"
                                 "--plugin=@prettier/plugin-php")))

  ;; 指定php的格式化工具为prettier-php
  (setf (alist-get 'php-mode apheleia-mode-alist) 'prettier-php)
  )
