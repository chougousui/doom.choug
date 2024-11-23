;;; custom/php-ext/config.el -*- lexical-binding: t; -*-

(defun php-ext/need-cautious-formatting ()
  "判断当前文件是否需要谨慎格式化。
通过执行 `git cautious path/to/file` 判断：
- 返回状态码 0，表示需要谨慎格式化，返回 t；
- 返回其他状态码或命令执行失败，返回 nil。
"
  ;; (interactive)
  (let* ((exit-code (call-process "git" nil nil nil "cautious" (buffer-file-name))))
    ;; (message "git cautious exit code: %d" exit-code) ;; debug时可查看
    (= exit-code 0)))

(use-package! apheleia
  :defer t
  :init
  ;; 在特定条件下禁用apheleia-mode
  (defun php-ext/inhibit-apheleia-f ()
    (and (eq major-mode 'php-mode)                   ;; 如果是php-mode
         (php-ext/need-cautious-formatting)))        ;; 且借助git alias判定需要谨慎格式化, 则禁用apheleia-mode

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
