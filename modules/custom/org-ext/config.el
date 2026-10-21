;;; custom/org-ext/config.el -*- lexical-binding: t; -*-

(load! "funcs")

;; org日期输入不完整时,缺失的月和年取默认日期,不往未来推
(setq org-read-date-prefer-future nil)

;; 用自己的日期插入命令覆盖org-timestamp的默认绑定
(map! :after org
      :map org-mode-map
      "C-c ." #'+org-ext/insert-date)
