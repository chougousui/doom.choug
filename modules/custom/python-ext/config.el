;;; custom/python-ext/config.el -*- lexical-binding: t; -*-

(add-hook 'python-mode-hook
          (lambda ()
            (setq fill-column 120)))

(after! apheleia
  ;; 设置python的默认格式化工具为ruff
  ;; 直到第一次调用格式化功能时,这些变量才会临时计算
  (setf (alist-get 'python-mode apheleia-mode-alist) '(ruff-isort ruff))
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) '(ruff-isort ruff))
  )

(use-package! pyvenv
  :hook (python-mode . pyvenv-tracking-mode)
  :init
  (defun custom-python-ext/auto-venv ()
    "Automatically detect and activate virtualenv."
    (when-let* ((project-dir (locate-dominating-file default-directory ".venv"))
                (venv-path (expand-file-name ".venv" project-dir)))
      (when (file-directory-p venv-path)
        (pyvenv-activate venv-path))))

  :config
  (add-hook 'python-mode-hook #'custom-python-ext/auto-venv))
