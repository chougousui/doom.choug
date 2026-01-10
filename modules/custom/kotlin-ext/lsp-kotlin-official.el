;;; custom/kotlin-ext/lsp-kotlin-official.el -*- lexical-binding: t; -*-

(defgroup lsp-kotlin-official nil
  "Official Kotlin LSP support for lsp-mode"
  :group 'lsp-mode
  :link '(url-link "https://github.com/Kotlin/kotlin-lsp"))

(defcustom lsp-kotlin-official-version "261.13587.0"
  "Version of the Kotlin LSP to use."
  :group 'lsp-kotlin-official
  :type 'string)

(defun lsp-kotlin-official--download-url ()
  "Construct the download URL for the current platform and version."
  (let* ((ver lsp-kotlin-official-version)
         (system (pcase system-type
                   ('gnu/linux "linux-x64")
                   ('darwin "mac-x64")
                   ('windows-nt "win-x64")
                   (_ (error "Unsupported system: %s" system-type)))))
    (format "https://download-cdn.jetbrains.com/kotlin-lsp/%s/kotlin-lsp-%s-%s.zip"
            ver ver system)))

(defun lsp-kotlin-official--install-dir ()
  "Return the directory where kotlin-lsp should be installed."
  (expand-file-name "kotlin-lsp-official" lsp-server-install-dir))

(defun lsp-kotlin-official--executable ()
  "Return the path to the kotlin-lsp executable."
  (let ((base (lsp-kotlin-official--install-dir))
        (script-name (if (eq system-type 'windows-nt) "kotlin-lsp.cmd" "kotlin-lsp.sh")))
    ;; 官方包解压后直接在根目录下包含脚本
    (expand-file-name script-name base)))

(defun lsp-kotlin-official--download-server (client callback error-callback update?)
  "Download and install the official Kotlin LSP."
  (let* ((url (lsp-kotlin-official--download-url))
         (install-dir (lsp-kotlin-official--install-dir))
         (zip-file (make-temp-file "kotlin-lsp" nil ".zip"))
         (buffer (get-buffer-create "*kotlin-lsp-install*")))

    (lsp-log "Downloading Kotlin LSP from %s..." url)

    ;; 1. 下载
    (let ((proc (start-process "kotlin-lsp-download" buffer "curl" "-L" "-o" zip-file url)))
      (set-process-sentinel
       proc
       (lambda (p event)
         (if (not (string= (string-trim event) "finished"))
             (funcall error-callback (format "Download failed: %s" event))
           (lsp-log "Download complete. Extracting...")

           ;; 2. 准备目录
           (when (file-exists-p install-dir)
             (delete-directory install-dir t))
           (make-directory install-dir t)

           ;; 3. 解压
           ;; 不使用 -j，保留 bin/ 和 lib/ 结构，确保启动脚本能找到 jar 包
           (let ((unzip-proc (start-process "kotlin-lsp-unzip" buffer "unzip" "-o" zip-file "-d" install-dir)))
             (set-process-sentinel
              unzip-proc
              (lambda (p event)
                (if (not (string= (string-trim event) "finished"))
                    (funcall error-callback (format "Unzip failed: %s" event))
                  (delete-file zip-file)

                  ;; 4. 验证安装 (用户偏好使用 bash 显式调用，无需 +x 权限)
                  (let ((exec-path (lsp-kotlin-official--executable)))
                    (if (file-exists-p exec-path)
                        (progn
                          (lsp-log "Kotlin LSP installed at %s" exec-path)
                          (funcall callback))
                      (funcall error-callback (format "Executable not found at %s. Check extraction structure." exec-path))))))))))))))

;; 注册 Client
(lsp-register-client
 (make-lsp-client :new-connection (lsp-stdio-connection
                                   (lambda ()
                                     (let ((exec (lsp-kotlin-official--executable)))
                                       (if (eq system-type 'windows-nt)
                                           exec
                                         (list "bash" exec)))))
                  :activation-fn (lsp-activate-on "kotlin")
                  :major-modes '(kotlin-mode kotlin-ts-mode)
                  :priority 10 ;; 确保优先级高于其他 kotlin lsp
                  :server-id 'kotlin-lsp-official
                  :download-server-fn #'lsp-kotlin-official--download-server
                  :notification-handlers (lsp-ht)))
