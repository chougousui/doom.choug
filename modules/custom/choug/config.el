;;; custom/choug/config.el -*- lexical-binding: t; -*-

;; 加载该模块文件夹下,定义在funcs.el文件中的一些函数,比如choug/swiper-dwim
(load! "funcs")

;; 配置英文字体
(setq doom-font (font-spec :family "JetBrains Mono" :size 13.0))

;; 设置中文字体
;; 不知道为什么必须在hook中设置,直接设置无效
;; 必须在GUI模式下设置,否则会报错无法识别tty
(add-hook 'after-setting-font-hook
          (lambda ()
            (when (display-graphic-p)
              (dolist (charset '(kana han cjk-misc bopomofo))
                (set-fontset-font (frame-parameter nil 'font) charset
                                  (font-spec :family "KaiTi" :size 15.0))))))

;; anti-doom
(setq doom-leader-alt-key "M-m" ;; 重新配置emacs风格下的leader key
      doom-leader-key "M-m"     ;; 保险起见evil模式下的也一并配置
      confirm-kill-emacs nil    ;; 退出emacs前不要烦人地确认
      ;; +default-want-RET-continue-comments nil ;; 不要在回车时接续注释
      )
(setq-default truncate-lines nil                    ;; 在屏幕不够宽时,不要截断文本,而是换行显示
              word-wrap nil                         ;; 不要根据空格等直接换行,看起来有大段空格
              )

;; anti-old-defaults
(setq fill-column 120                   ;; 现在屏幕大,改到120
      warning-fill-column 118
      message-fill-column 112
      )
(map! :map global-map
      "C-t" nil         ;; 禁用Ctrl-t交换两个字符的功能
      )

;; 改用全局的leader key作为projectile-command-map的前缀
(after! projectile
  ;; 可以禁用原先的C-c p方式
  (map! :map projectile-mode-map
        "C-c p" nil)
  (map! :leader
        :desc "project" "p" projectile-command-map))

;; 常用搜索功能
(map! "C-s" #'+default/search-buffer
      "C-S-s" #'+vertico/search-symbol-at-point
      "C-M-s" #'choug/project-search-dwim
      )

;; buffer相关绑定
(map! :leader
      "TAB" #'mode-line-other-buffer   ;; TODO 自定义一个其他函数
      "b b" #'switch-to-buffer
      "b s" #'doom/switch-to-scratch-buffer
      )

;; smartparens-mode-map比全局mode-map优先级更高,需要先解绑
;; 或者直接绑定新的
(map! :after smartparens
      :map smartparens-mode-map
      "C-M-n" #'forward-list
      "C-M-p" #'backward-list
      "C-M-u" #'backward-up-list
      )

;; 修改winum默认键盘绑定
(map! :after winum
      :map winum-keymap
      "M-1" #'winum-select-window-1
      "M-2" #'winum-select-window-2
      "M-3" #'winum-select-window-3
      "M-4" #'winum-select-window-4
      "M-5" #'winum-select-window-5
      "M-6" #'winum-select-window-6
      "M-7" #'winum-select-window-7
      "M-8" #'winum-select-window-8
      "M-9" #'winum-select-window-9
      )

;; 附加一些常用按键
(map! :prefix "M-RET"
      "g g" #'+lookup/definition
      )

;; 删除快捷键
(map! "M-DEL" #'choug/backward-delete-word-or-region
      "C-DEL" #'choug/backward-delete-word-or-region
      )

;; 自定义常用函数和快捷键绑定
(map! :leader
      (:prefix ("y" . "choug")
       :desc "Align comments" "a" #'choug/align-comment-dwim
       :desc "Minify code" "m" #'choug/minify))
