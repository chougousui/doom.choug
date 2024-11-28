;;; custom/plantuml-ext/config.el -*- lexical-binding: t; -*-

;; plantuml-mode是autoload的,可以放在after外面
;; 默认只有plantuml,pum,plu会打开
(add-to-list 'auto-mode-alist '("\\.\\(plantuml\\|pum\\|plu\\|puml\\)\\'" . plantuml-mode))

(after! plantuml-mode-hook
  (setq
   ;; 本地渲染
   platuml-exec-mode 'jar
   ;; plantuml默认会将文件下载到emacs附属路径下,但考虑到版本等维护工作,还是由系统下载了
   plantuml-jar-path "/usr/share/java/plantuml/plantuml.jar"))
