;;; custom/format-ext/config.el -*- lexical-binding: t; -*-

(when (modulep! :editor format)
  (after! apheleia
    ;; 将Oxfmt支持的模式从Prettier切换为Oxfmt
    (dolist (mode '(css-mode
                    css-ts-mode
                    graphql-mode
                    html-mode
                    html-ts-mode
                    js3-mode
                    js-json-mode
                    js-mode
                    js-ts-mode
                    json-mode
                    json-ts-mode
                    scss-mode
                    svelte-mode
                    tsx-ts-mode
                    typescript-mode
                    typescript-ts-mode
                    web-mode
                    yaml-mode
                    yaml-ts-mode))
      (setf (alist-get mode apheleia-mode-alist) 'oxfmt))))
