;;; custom/syntax-ext/config.el -*- lexical-binding: t; -*-

;; flycheck配置
(when (modulep! :checkers syntax -flymake)
  ;; 重新绑定flycheck的一些快捷键
  (after! flycheck
    (map! :leader
          :desc "flycheck" "e" flycheck-command-map)))

;; flymake配置
(when (modulep! :checkers syntax +flymake )
  (after! flymake
    ;; 猜测:config/default将e绑定为一个函数,而不是prefix
    ;; 而之后想要绑定为一个prefix,需要先解绑函数
    (map! :leader
          "e" nil)
    (map! :leader
          (:prefix ("e" . "flymake")
           :desc "list buffer errors" "l" #'flymake-show-buffer-diagnostics
           :desc "list project errors" "L" #'flymake-show-project-diagnostics
           :desc "goto next error" "n" #'flymake-goto-next-error
           :desc "goto previous error" "p" #'flymake-goto-prev-error))))
