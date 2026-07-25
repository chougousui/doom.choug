;;; custom/lsp-ext/eglot-angular.el -*- lexical-binding: t; -*-

(defun lsp-ext/angular-project-p (project)
  "判断是否为angular项目"
  (and project
       (file-exists-p
        (expand-file-name "angular.json" (project-root project)))))

(defun lsp-ext/angular-server-command (project)
  "构造启动angular-lsp的命令行字符串"
  (list "ngserver"
        "--stdio"
        "--tsProbeLocations"
        (expand-file-name "node_modules" (project-root project))
        "--ngProbeLocations"
        (expand-file-name
         "~/.local/share/mise/installs/node/lts/lib/node_modules")))

(defun lsp-ext/angular-server-alternatives (project)
  "根据情况构造可用lsp列表,如果是angular项目,则返回[ngserver],否则返回[]"
  (when (lsp-ext/angular-project-p project)
    (list (lsp-ext/angular-server-command project))))
