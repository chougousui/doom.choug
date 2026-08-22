;;; custom/format-ext/config.el -*- lexical-binding: t; -*-

(when (modulep! :editor format)
  (after! apheleia
    ;; 覆盖上游的inplace模式(临时文件原地重写),改用stdin管道:
    ;; 最低要求oxfmt 0.47.0(--stdin-filepath支持嵌套配置解析与ignore匹配)
    (setf (alist-get 'oxfmt apheleia-formatters)
          '("apheleia-npx" "oxfmt" "--stdin-filepath" filepath))

    ;; 将Oxfmt支持的模式从Prettier切换为Oxfmt
    (dolist (mode '(css-mode
                    css-ts-mode
                    graphql-mode
                    html-mode
                    html-ts-mode
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
