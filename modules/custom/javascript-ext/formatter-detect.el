;;; custom/javascript-ext/formatter-detect.el -*- lexical-binding: t; -*-

;; 根据项目配置文件动态选择格式化器

(defvar my/js-formatter-config-files
  '((oxfmt . (".oxfmtrc.json" ".oxfmtrc.jsonc"))
    (biome . ("biome.json" "biome.jsonc"))
    (prettier-typescript . (".prettierrc" ".prettierrc.json" ".prettierrc.yaml"
                            ".prettierrc.yml" ".prettierrc.js" "prettier.config.js"
                            ".prettierrc.cjs" "prettier.config.cjs"
                            ".prettierrc.mjs" "prettier.config.mjs")))
  "格式化器及其配置文件的映射，按优先级排序")

(defun my/detect-js-formatter ()
  "根据项目配置文件检测格式化器"
  (when-let ((root (doom-project-root)))
    (seq-some (lambda (entry)
                (when (seq-some (lambda (file)
                                  (file-exists-p (expand-file-name file root)))
                                (cdr entry))
                  (car entry)))
              my/js-formatter-config-files)))

(defun my/set-js-formatter-h ()
  "为当前 buffer 设置格式化器"
  (when-let ((formatter (my/detect-js-formatter)))
    (setq-local apheleia-formatter formatter)))

(dolist (hook '(typescript-ts-mode-hook
                tsx-ts-mode-hook
                js-ts-mode-hook
                typescript-mode-hook))
  (add-hook hook #'my/set-js-formatter-h))
