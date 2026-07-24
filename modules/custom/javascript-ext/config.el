;;; custom/javascript-ext/config.el -*- lexical-binding: t; -*-

;; web-mode中没有设置非web-mode相关(比如typescript-mode)的内容
;; 但typescript-mode的内容影响tsx文件中的行为
(setq typescript-indent-level 2
      web-mode-css-indent-offset 2
      ;; 虽然这个归css-mode管,不关javascript module的事
      ;; 但是为了体验统一,也要一起修改
      css-indent-offset 2
      )

;; 根据项目配置文件动态选择格式化器
(load! "formatter-detect")
