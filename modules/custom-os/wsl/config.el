;;; custom-os/wsl/config.el -*- lexical-binding: t; -*-

;; 解决wslg中粘贴后出现乱码的问题:
;; wslg下应用(emacs)粘贴时,需要从wslg提供的多个剪贴板格式中选择一个,
;; 默认会优先选择STRING格式,其内容会被按非utf-8编码解析,导致乱码,
;; 因此改为优先请求utf-8格式
(setq x-select-request-type
      '(text/plain\;charset=utf-8 UTF8_STRING COMPOUND_TEXT STRING))
