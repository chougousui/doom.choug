;;; custom/vc-ext/config.el -*- lexical-binding: t; -*-

(defun vc-blame ()
  "以 blame 的名称调用 `vc-annotate'，交互输入和前缀参数原样传递。"
  (interactive)
  (call-interactively #'vc-annotate))
