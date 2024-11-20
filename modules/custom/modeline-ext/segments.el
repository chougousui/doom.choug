;;; custom/modeline-ext/segments.el -*- lexical-binding: t; -*-

(defun custom-modeline-ext/create-custom-segments ()
  "封装doom-modeline-def-segment venv,方便在外面调用"

  ;; 自定义名为venv的segment,用于显示python的venv名称
  (doom-modeline-def-segment venv
    (if (and (boundp 'pyvenv-virtual-env-name)
             pyvenv-virtual-env-name)
        (format "%s" pyvenv-virtual-env-name)
      ""))

  ;; 其他segment
)
