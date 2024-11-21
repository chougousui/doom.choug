;;; custom/go-ext/config.el -*- lexical-binding: t; -*-

(after! apheleia
  ;; 添加golines格式化器(apheleia-formatters并非autoload,只能在启动后操作)
  (add-to-list 'apheleia-formatters
               '(golines . ("golines" "-m" "120" "--base-formatter=gofumpt")))

  ;; 设置go的默认格式化器为golines(apheleia-mode-alist并非autoload,只能在启动后操作)
  (setf (alist-get 'go-mode apheleia-mode-alist) 'golines)
  (setf (alist-get 'go-ts-mode apheleia-mode-alist) 'golines)
  )

;; 提供一个交互式命令来特定使用golines
;;
;; apheleia-mode是autoload的,意味着用户第一次打开文件,在modes中看到apheleia-mode,但实际上包还没有加载
;; 上面的after中的内容也还没有加载
;; 如果将golines-format-buffer的定义放在after中,则用户第一次打开文件时,无法使用golines-format-buffer函数
;; 这样用户不得不随便使用一下什么其他方式先加载apheleia(比如先保存一下文件)才能使用函数
;;
;; 好在函数apheleia-format-buffer也是autoload的
;; 因此可以将调用该函数的逻辑定义在after外部
;; 这样当用户调用apheleia-format-buffer时
;; 1. 检测到使用,开始加载包
;; 2. 设置golines格式化器
;; 3. 设置go-mode的格式化器
;; 4. 真正运行这个函数
(defun golines-format-buffer ()
  "使用golines格式化器格式化当前buffer"
  (interactive)
  (apheleia-format-buffer 'golines))
