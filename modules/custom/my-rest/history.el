;;; custom/my-rest/history.el -*- lexical-binding: t; -*-

(require 'eieio)
(require 'sqlite)
(require 'xdg)

;; 该文件由 use-package! verb 的 :config 加载，因此此处不再 require verb

(defgroup hc nil
  "基于 Org 和 Verb 的 HTTP client 配置"
  :group 'tools
  :prefix "hc-")

(defcustom hc-history-max-response-body-bytes 1000000
  "持久化响应 Body 时允许的最大字节数"
  :type '(integer :tag "Bytes")
  :group 'hc)

(defcustom hc-history-redacted-header-names
  '("Authorization"
    "Proxy-Authorization"
    "Cookie"
    "Set-Cookie"
    "X-API-Key"
    "API-Key")
  "持久化时隐藏值的 HTTP Header 名称，匹配时忽略大小写"
  :type '(repeat string)
  :group 'hc)

(defcustom hc-history-max-database-age-days 30
  "活动历史数据库轮转前允许保留的最大天数"
  :type '(integer :tag "Days")
  :group 'hc)

(defcustom hc-history-max-database-size-bytes 50000000
  "活动历史数据库轮转前允许达到的最大字节数"
  :type '(integer :tag "Bytes")
  :group 'hc)

(defun hc-history--directory ()
  "返回 Emacs HTTP client 历史数据库目录"
  (expand-file-name "ehc/" (xdg-state-home)))

(defun hc-history--database-file ()
  "返回活动 Verb 历史数据库文件名"
  (expand-file-name "history.sqlite3" (hc-history--directory)))

(defun hc-history--next-archive-file ()
  "返回一个当前尚未使用的历史数据库归档文件名"
  (let* ((directory (hc-history--directory))
         (timestamp (format-time-string "%Y%m%dT%H%M%SZ" nil t))
         (base-name (format "history-%s" timestamp))
         (candidate (expand-file-name (concat base-name ".sqlite3") directory))
         (suffix 1))
    (while (file-exists-p candidate)
      (setq candidate
            (expand-file-name
             (format "%s-%d.sqlite3" base-name suffix)
             directory)
            suffix (1+ suffix)))
    candidate))

(defun hc-history--initialize-schema (database)
  "在 DATABASE 中初始化 Verb 历史表结构"
  (sqlite-execute
   database
   "CREATE TABLE IF NOT EXISTS hc_history_metadata (
      key TEXT PRIMARY KEY,
      value INTEGER NOT NULL
    )")
  (sqlite-execute
   database
   "CREATE TABLE IF NOT EXISTS verb_history (
      id INTEGER PRIMARY KEY,
      received_at INTEGER NOT NULL,
      request_method TEXT NOT NULL,
      request_url TEXT NOT NULL,
      request_headers TEXT NOT NULL,
      request_body BLOB,
      response_status TEXT,
      response_headers TEXT NOT NULL,
      response_body BLOB,
      response_body_omitted INTEGER NOT NULL,
      response_duration REAL NOT NULL,
      response_body_bytes INTEGER NOT NULL
    )")
  (sqlite-execute
   database
   "INSERT OR IGNORE INTO hc_history_metadata (key, value)
    VALUES ('created_at', ?)"
   (list (floor (float-time)))))

(defun hc-history--database-created-at (database)
  "返回 DATABASE 的创建时间 Unix 时间戳"
  (caar
   (sqlite-select
    database
    "SELECT value FROM hc_history_metadata WHERE key = 'created_at'")))

(defun hc-history--rotation-needed-p (database database-file)
  "返回 DATABASE-FILE 对应的 DATABASE 当前是否需要轮转"
  (or (> (file-attribute-size (file-attributes database-file))
         hc-history-max-database-size-bytes)
      (> (- (float-time) (hc-history--database-created-at database))
         (* hc-history-max-database-age-days 86400))))

(defun hc-history--rotate-database (database-file)
  "将 DATABASE-FILE 轮转为带 UTC 时间戳的 SQLite 归档"
  (rename-file database-file (hc-history--next-archive-file)))

(defun hc-history--header-redacted-p (name)
  "返回名为 NAME 的 HTTP Header 是否需要隐藏"
  (assoc-string name hc-history-redacted-header-names t))

(defun hc-history--headers-text (headers)
  "将 HEADERS 隐藏敏感值后格式化为每行一条的文本"
  (mapconcat
   (lambda (header)
     (format "%s: %s"
             (car header)
             (if (hc-history--header-redacted-p (car header))
                 "[REDACTED]"
               (cdr header))))
   headers "\n"))

(defun hc-history--body-value (body)
  "将 BODY 转换为适合 SQLite 参数绑定的值"
  (when body
    (let ((value (copy-sequence body)))
      (when (and (not (multibyte-string-p value))
                 (> (length value) 0))
        (put-text-property 0 1 'coding-system 'binary value))
      value)))

(defun hc-history--insert-response (database response)
  "将 RESPONSE 及其请求写入 DATABASE"
  (let* ((request (oref response request))
         (response-body-bytes (oref response body-bytes))
         (response-body-omitted
          (> response-body-bytes hc-history-max-response-body-bytes)))
    (sqlite-execute
     database
     "INSERT INTO verb_history (
        received_at,
        request_method,
        request_url,
        request_headers,
        request_body,
        response_status,
        response_headers,
        response_body,
        response_body_omitted,
        response_duration,
        response_body_bytes
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
     (list (floor (float-time))
           (oref request method)
           (verb-request-spec-url-to-string request)
           (hc-history--headers-text (oref request headers))
           (hc-history--body-value (oref request body))
           (oref response status)
           (hc-history--headers-text (oref response headers))
           (unless response-body-omitted
             (hc-history--body-value (oref response body)))
           (if response-body-omitted 1 0)
           (oref response duration)
           response-body-bytes))))

(defun hc-history--store-response (response)
  "持久化 RESPONSE，并在写入前按需轮转活动数据库"
  (let* ((database-file (hc-history--database-file))
         (new-database (not (file-exists-p database-file)))
         (database (sqlite-open database-file)))
    (unwind-protect
        (progn
          (when new-database
            (hc-history--initialize-schema database))
          (when (hc-history--rotation-needed-p database database-file)
            (sqlite-close database)
            (setq database nil)
            (hc-history--rotate-database database-file)
            (setq database (sqlite-open database-file))
            (hc-history--initialize-schema database))
          (hc-history--insert-response database response))
      (when database
        (sqlite-close database)))))

(defun hc-history--record-response ()
  "将当前 Verb 响应写入历史数据库"
  (condition-case error-data
      (hc-history--store-response verb-http-response)
    (error
     (display-warning
      'hc-history
      (format "Failed to persist Verb history: %s"
              (error-message-string error-data))
      :warning))))

(defun hc-history-init ()
  "初始化 Verb 历史数据库并注册响应记录 Hook"
  (unless (sqlite-available-p)
    (user-error "This Emacs build has no SQLite support"))
  (make-directory (hc-history--directory) t)
  (let ((database (sqlite-open (hc-history--database-file))))
    (unwind-protect
        (hc-history--initialize-schema database)
      (sqlite-close database)))
  (add-hook 'verb-post-response-hook #'hc-history--record-response))

(provide 'my-rest-history)
