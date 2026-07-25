;;; custom/lsp-ext/eglot-angular.el -*- lexical-binding: t; -*-

;; TODO: 给Angular项目下的ts文件注册一个调用ngserver的Eglot客户端,
;; 作为TypeScript客户端之外的追加项,不覆盖它。

(defun lsp-ext/angular-project-p (project)
  "PROJECT是Angular项目时返回非nil,判断依据是根目录下有`angular.json'。
PROJECT是`project-current'返回的对象,可能为nil。"
  (and project
       (file-exists-p
        (expand-file-name "angular.json" (project-root project)))))
