;;; custom/doom-dashboard-ext/config.el -*- lexical-binding: t; -*-

;; 一个还不错的设计
;; https://github.com/doomemacs/doomemacs/issues/2204

(load! "ascii-logo")

(when (modulep! :ui doom-dashboard)
  ;; 自定义banner的色彩等
  ;; 各种继承都不成功,只能直接指定和font-lock-comment-face一样的fg
  (custom-set-faces! '(doom-dashboard-banner :foreground "#008787" :background nil))
  (custom-set-faces! '(doom-dashboard-loaded :foreground "#008787" :background nil))

  ;; 定义新的居中函数，在两边都添加空格
  (defun +doom-dashboard--center (width string)
    "Center a STRING in a space of WIDTH by adding spaces on both sides."
    (let* ((padding (max 0 (/ (- width (length string)) 2)))
           ;; 如果宽度减去字符串长度是奇数，右边会多一个空格
           (padding-right (if (= (mod (- width (length string)) 2) 0)
                              padding
                            (1+ padding))))
      (concat (make-string padding ? )   ; 左边的空格
              string                     ; 原字符串
              (make-string padding-right ? )))) ; 右边的空格

  (defun doom-dashboard-draw-ascii-banner-fn ()
    (let* ((banner +my-dashboard-banner)
           (longest-line (apply #'max (mapcar #'length banner))))
      (put-text-property
       (point)
       (dolist (line banner (point))
         (insert (+doom-dashboard--center
                  +doom-dashboard--width
                  (concat
                   line (make-string (max 0 (- longest-line (length line)))
                                     32)))
                 "\n"))
       'face 'doom-dashboard-banner)))
  )
