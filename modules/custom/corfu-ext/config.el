;;; custom/corfu-ext/config.el -*- lexical-binding: t; -*-

(after! corfu
  (setq
   ;; 触发补全的debounce time,太低会造成一些性能浪费
   ;; 让gpt写了个网页测了一下,连续输入时平均间隔在120ms以下,设置一个90%场景的时间
   corfu-auto-delay 0.2

   ;; 通常是选择第一个,极少数情况会不选择第一个
   corfu-preselect 'valid

   ;; 同样是indent-for-tab-command,
   ;; spacemacs下对于已经打好的内容,光标放在后面按下tab不会补全,是正常行为(要么调整该行缩进,要么不做什么)
   ;; 但是doom放在后面,会补全
   ;; 观察describe-key Tab的帮助文档后,似乎只能修改tab-always-indent
   ;; 同时TUI模式下目前只能手动使用Tab触发补全而不能自动补全,因此保留Tab触发补全的功能
   tab-always-indent (display-graphic-p)))
