;;; custom/my-rest/config.el -*- lexical-binding: t; -*-

(use-package! verb
  :demand t
  :config
  ;; 统一配置 Verb 的 JSON 响应模式、默认请求 Header 和空响应显示行为
  (setq verb-json-use-mode #'json-mode
        verb-base-headers '(("Accept" . "application/json"))
        verb-auto-show-headers-buffer 'when-empty)

  (load! "history")
  (hc-history-init)

  (define-derived-mode hc-mode org-mode "HC"
    "使用 Org 和 Verb 编写及发送 HTTP 请求的 major mode"
    (verb-mode 1))
  (add-to-list 'auto-mode-alist
               '("\\.ehc\\'" . hc-mode))

  ;; C-t 仅在 hc-mode 中进入 Verb 命令 map
  (map! :map hc-mode-map
        :desc "Verb"
        "C-t" verb-command-map)

  ;; 进入 Verb 命令 map 后的分组快捷键
  (map! :map verb-command-map
        (:prefix ("r" . "request")
         :desc "Export request draft"
         "d" #'verb-export-request-on-point-verb
         :desc "Send request and retain focus"
         "r" #'verb-send-request-on-point-display
         :desc "Send request and focus response"
         "o" #'verb-send-request-on-point-other-window)
        (:prefix ("v" . "variables")
         :desc "List variables"
         "l" #'verb-show-vars
         :desc "Set variable"
         "s" #'verb-set-var
         :desc "Unset all variables"
         "u" #'verb-unset-vars))

  ;; 保留直接发送并聚焦 response 窗口的快捷键
  (map! :map verb-mode-map
        :desc "Send request and focus response"
        "C-c C-c" #'verb-send-request-on-point-other-window)

  ;; hc-mode 派生自 org-mode,继承了 org 链路的补全后端,在请求文件里都是干扰:
  ;; pcomplete-completions-at-point 提供 #+keyword 补全, cape-elisp-block 只用于
  ;; elisp 代码块, yasnippet-capf 把 org snippet(name -> #+name: )当候选
  (add-hook! 'hc-mode-hook
    (defun +my-rest-setup-completion-h ()
      (dolist (backend '(pcomplete-completions-at-point
                         yasnippet-capf
                         cape-elisp-block))
        (remove-hook 'completion-at-point-functions backend t))
      ;; yasnippet-capf 在 mode hook 结束后被 yas-global-mode 重新挂载,
      ;; remove-hook 拦不住,从源头禁用它在 hc buffer 内挂载
      (setq-local yas-dont-activate-functions t)
      ;; 词补全后端;
      ;; cape-dabbrev-buffer-function 默认只扫同 mode buffer,改成 doom-visible-buffers,
      ;; 扫描范围限定为显示在窗口中的 buffer,包含 json-mode 响应 buffer 等其他来源
      (setq-local cape-dabbrev-buffer-function #'doom-visible-buffers)
      ;; dabbrev-case-replace 默认会把候选改写成所打前缀的大小写(打 na 时 Name 变 name),
      ;; 置 nil 保留候选在 buffer 中的原始大小写
      (setq-local dabbrev-case-replace nil)
      (add-hook 'completion-at-point-functions #'cape-dabbrev 10 t))))
