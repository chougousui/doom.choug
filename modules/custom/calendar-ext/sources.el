;;; custom/calendar-ext/sources.el -*- lexical-binding: t; -*-

(defgroup calendar-ext nil
  "Doom Calendar 扩展。"
  :group 'calendar)

(defcustom +calendar-ext-enable-org-agenda t
  "是否创建 Org Agenda 数据源。"
  :type 'boolean
  :group 'calendar-ext)

(defcustom +calendar-ext-enable-china-holidays t
  "是否创建中国大陆节假日数据源。"
  :type 'boolean
  :group 'calendar-ext)

(defcustom +calendar-ext-enable-japan-holidays t
  "是否创建日本法定节假日数据源。"
  :type 'boolean
  :group 'calendar-ext)

(defcustom +calendar-ext-enable-lunar-calendar t
  "是否创建中国农历注释数据源。"
  :type 'boolean
  :group 'calendar-ext)

;; 中国大陆节假日订阅：
;; - 由 Apple 通过 calendars.icloud.com 提供
;; - 对应 Apple Calendar 内置的“中国大陆节假日”只读日历
;; - 日历内容和更新时间由 Apple 维护
(defconst +calendar-ext-china-holidays-url
  "https://calendars.icloud.com/holidays/cn_zh.ics"
  "Apple 中国大陆节假日公共 ICS 地址。")

;; 日本法定节假日订阅：
;; - 数据由日本国立天文台暦計算室维护
;; - 通过 Google Calendar 的公共 ICS 接口提供
;; - 包含国民祝日、振替休日和国民休日
(defconst +calendar-ext-japan-holidays-url
  "https://calendar.google.com/calendar/ical/2bk907eqjut8imoorgq1qa4olc%40group.calendar.google.com/public/basic.ics"
  "日本国立天文台法定节假日公共 ICS 地址。")

(defun +calendar-ext--create-contents-sources ()
  "创建已启用的日历内容数据源。"
  (delq nil
        (list
         ;; Doom 默认的 Org Agenda 数据源
         (when +calendar-ext-enable-org-agenda
           (calfw-org-create-source
            nil "org-agenda" (face-foreground 'default)))

         ;; Apple 提供的中国大陆节假日
         (when +calendar-ext-enable-china-holidays
           (calfw-ical-create-source
            +calendar-ext-china-holidays-url
            "China Public Holidays" "red"))

         ;; 国立天文台通过 Google Calendar 提供的日本法定节假日
         (when +calendar-ext-enable-japan-holidays
           (calfw-ical-create-source
            +calendar-ext-japan-holidays-url
            "Japan Public Holidays" "green")))))

(defun +calendar-ext--create-annotation-sources ()
  "创建已启用的日历注释数据源。"
  (when +calendar-ext-enable-lunar-calendar
    (list (+calendar-ext-lunar-create-source))))

(provide 'calendar-ext-sources)
