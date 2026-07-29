;;; custom/chinese-ext/config.el -*- lexical-binding: t; -*-

(declare-function liberime-search-context "liberime")

(after! pyim
  ;; Emacs 中的标点由 pyim 处理，而不是由 Rime schema 的 `ascii_punct' 开关处理。
  ;; pyim 通过 `make-variable-buffer-local' 将此变量声明为自动 buffer-local；普通 `setq' 只会修改加载配置时所在的 buffer，其他 buffer 仍可能保留 `(auto yes no)'。
  ;; `setq-default' 修改所有尚未建立局部值的现有 buffer 以及以后新建 buffer 所继承的默认值。
  ;; 只保留 `no' 状态，使 pyim 始终跳过全角标点转换，且 `pyim-punctuation-toggle' 也无法轮换到其他状态。
  (setq-default pyim-punctuation-translate-p '(no))
  ;; 配置加载前使用过 pyim 的 buffer 可能已经保存旧的局部值；删除局部绑定后，这些 buffer 会立即回退到上面的默认值。
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (local-variable-p 'pyim-punctuation-translate-p)
        (kill-local-variable 'pyim-punctuation-translate-p)))))

;; 从 emacs-rime/liberime#74 开始，`liberime-search' 在临时会话中运行，不再改变默认输入会话。
;; `pyim-liberime--get-code' 仍假设 `liberime-get-preedit' 描述的是刚完成的搜索，因此可能把 nil 传给 `split-string'。
;; fork 新增的 `liberime-search-context' 会从同一个临时会话返回候选词和 preedit，同时保持默认会话不变。
(defun +chinese-ext--pyim-liberime-get-code-a (fn &rest args)
  "使用同一隔离搜索会话中的候选词和 preedit 调用 FN。"
  (let ((search-active-p nil)
        search-preedit
        ;; 第一次搜索之前，pyim 必须继续从当前默认输入会话读取 preedit。
        (get-default-preedit (symbol-function #'liberime-get-preedit)))
    ;; 将函数替换限制在本次 `pyim-liberime--get-code' 调用期间。
    (cl-letf (((symbol-function #'liberime-search)
               (lambda (&rest search-args)
                 ;; 保持 `liberime-search' 的公开返回格式，同时保存对应临时会话的 preedit。
                 (let ((context
                        (apply #'liberime-search-context search-args)))
                   (setq search-active-p t
                         search-preedit (alist-get 'preedit context))
                   (alist-get 'candidates context))))
              ((symbol-function #'liberime-get-preedit)
               (lambda ()
                 (if search-active-p
                     ;; `pyim-liberime--get-code' 会把此值传给 `split-string'；即使 Rime 没有产生 preedit，也必须返回字符串。
                     (or search-preedit "")
                   (funcall get-default-preedit)))))
      (apply fn args))))

(after! pyim-liberime
  ;; 兼容没有新接口的旧版 liberime，并避免重新加载配置后重复添加 advice。
  (when (and (fboundp 'liberime-search-context)
             (not (advice-member-p
                   #'+chinese-ext--pyim-liberime-get-code-a
                   #'pyim-liberime--get-code)))
    (advice-add #'pyim-liberime--get-code
                :around #'+chinese-ext--pyim-liberime-get-code-a)))
