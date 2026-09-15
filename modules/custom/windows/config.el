;;; custom/windows/config.el -*- lexical-binding: t; -*-

;; 非英语系统的windows(如中文系统)上,emacs默认按系统代码页解码外部程序输出,
;; 而全局搜索等工具(rg等)实际输出utf-8,导致搜索结果出现乱码,
;; 强制所有读取统一使用utf-8解码,覆盖从操作系统继承的编码
(setq coding-system-for-read 'utf-8)

;; 强制默认编码为utf-8-unix,保证文件写盘和新buffer使用LF换行
(setq-default buffer-file-coding-system 'utf-8-unix)

(defun reveal-in-folder ()
  "在系统文件管理器中打开当前文件所在目录,目前仅支持windows"
  (interactive)
  (if (featurep :system 'windows)
      (w32-shell-execute "open" (file-name-directory buffer-file-name))
    (message "Not supported yet")))
