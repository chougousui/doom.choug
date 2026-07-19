;;; custom/calendar-ext/lunar.el -*- lexical-binding: t; -*-

;; 农历日期由 Emacs 内置的 cal-china.el 计算，不依赖网络数据源。
(require 'cal-china)

(defconst +calendar-ext-lunar-month-names
  ["正月" "二月" "三月" "四月" "五月" "六月"
   "七月" "八月" "九月" "十月" "冬月" "腊月"]
  "农历月份名称。")

(defconst +calendar-ext-lunar-day-names
  ["初一" "初二" "初三" "初四" "初五" "初六" "初七" "初八" "初九" "初十"
   "十一" "十二" "十三" "十四" "十五" "十六" "十七" "十八" "十九" "二十"
   "廿一" "廿二" "廿三" "廿四" "廿五" "廿六" "廿七" "廿八" "廿九" "三十"]
  "农历日期名称。")

(defun +calendar-ext--lunar-date-name (date)
  "返回公历 DATE 对应的中文农历日期名称。"
  (let* ((absolute-date (calendar-absolute-from-gregorian date))
         (chinese-date (calendar-chinese-from-absolute absolute-date))
         (month (nth 2 chinese-date))
         (day (nth 3 chinese-date)))
    (format "%s%s%s"
            (if (integerp month) "" "闰")
            (aref +calendar-ext-lunar-month-names (1- (floor month)))
            (aref +calendar-ext-lunar-day-names (1- day)))))

(defun +calendar-ext--lunar-annotations (begin end)
  "返回 BEGIN 至 END 之间每一天的农历注释。"
  (cl-loop for absolute-date
           from (calendar-absolute-from-gregorian begin)
           to (calendar-absolute-from-gregorian end)
           for date = (calendar-gregorian-from-absolute absolute-date)
           collect (cons date (+calendar-ext--lunar-date-name date))))

(defun +calendar-ext-lunar-create-source ()
  "创建中国农历 Calfw 注释数据源。"
  (make-calfw-source
   :name "Chinese Lunar Calendar"
   :data #'+calendar-ext--lunar-annotations))

(provide 'calendar-ext-lunar)
