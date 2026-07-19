;;; custom/calendar-ext/config.el -*- lexical-binding: t; -*-

(when (modulep! :app calendar)
  (load! "lunar")
  (load! "sources")

  (after! calfw
    ;; 禁用 Emacs 内置节假日层，只显示明确配置的数据源
    (setq calfw-display-calendar-holidays nil)

    (defun +calendar-ext/open-calendar (&rest args)
      "打开包含 Org、中日节假日和中国农历的日历。"
      (interactive)
      (apply #'calfw-open-calendar-buffer
             :contents-sources
             (+calendar-ext--create-contents-sources)

             ;; 使用 Emacs 内置算法在日期格中显示中国农历
             :annotation-sources
             (+calendar-ext--create-annotation-sources)

             :custom-map calfw-org-schedule-map
             :sorter #'calfw-org--schedule-sorter
             args)
      (calfw-navi-goto-today-command))

    ;; 使用合并后的日历视图替换 Doom 默认的 Calendar 打开函数
    (setq +calendar-open-function #'+calendar-ext/open-calendar)

    ;; 将 `g' 改为跳转到指定日期，不再用于刷新日历
    (define-key calfw-calendar-mode-map
                (kbd "g")
                #'calfw-navi-goto-date-command)))
