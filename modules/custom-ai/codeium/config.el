;;; custom/codeium/config.el -*- lexical-binding: t; -*-

(use-package! codeium
  :init
  ;; 全局配置
  (add-to-list 'completion-at-point-functions #'codeium-completion-at-point)

  :config
  ;; 不显示dialog
  (setq use-dialog-box nil)

  ;; 允许使用codeium-diagnose来显示和codeium的通信
  (setq codeium-mode-line-enable
        (lambda (api) (not (memq api '(CancelRequest Heartbeat AcceptCompletion)))))
  (add-to-list 'mode-line-format '(:eval (car-safe codeium-mode-line)) t)

  (setq codeium-api-enabled
        (lambda (api)
          (memq api '(GetCompletions Heartbeat CancelRequest GetAuthToken RegisterUser auth-redirect AcceptCompletion))))

  ;; 限制发送到服务器的字符数量(utf8长度意义下3000字符)
  (defun my-codeium/document/text ()
    (buffer-substring-no-properties (max (- (point) 3000) (point-min)) (min (+ (point) 1000) (point-max))))

  ;; 限制了字符数量,就必须修改cursor_offset
  (defun my-codeium/document/cursor_offset ()
    (codeium-utf8-byte-length
     (buffer-substring-no-properties (max (- (point) 3000) (point-min)) (point))))

  ;; 替换掉默认实现
  (setq codeium/document/text 'my-codeium/document/text)
  (setq codeium/document/cursor_offset 'my-codeium/document/cursor_offset)
  )
