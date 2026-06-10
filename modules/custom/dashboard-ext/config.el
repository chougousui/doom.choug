;;; custom/dashboard-ext/config.el -*- lexical-binding: t; -*-

;; 一个还不错的设计
;; https://github.com/doomemacs/doomemacs/issues/2204

(load! "ascii-logo")

(when (modulep! :ui dashboard)
  ;; 自定义banner的色彩等
  ;; 各种继承都不成功,只能直接指定和font-lock-comment-face一样的fg
  (custom-set-faces! '(+dashboard-banner :foreground "#008787" :background unspecified))
  (custom-set-faces! '(+dashboard-loaded :foreground "#008787" :background unspecified))

  ;; 新版模块的banner函数只需返回带face属性的字符串
  ;; 居中由+dashboard-widget-banner根据+dashboard-anchor统一处理,不再需要手动填充空格
  (defun +my-dashboard-draw-ascii-banner-fn ()
    (propertize (string-join +my-dashboard-banner "\n")
                'face '+dashboard-banner))

  (setq +dashboard-ascii-banner-fn #'+my-dashboard-draw-ascii-banner-fn))
