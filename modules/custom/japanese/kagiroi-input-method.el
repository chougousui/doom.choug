;;; custom/japanese/kagiroi-input-method.el -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'subr-x)

(declare-function liberime-clear-composition "liberime")
(declare-function liberime-commit-composition "liberime")
(declare-function liberime-get-commit "liberime")
(declare-function liberime-get-context "liberime")
(declare-function liberime-get-input "liberime")
(declare-function liberime-get-status "liberime")
(declare-function liberime-load "liberime")
(declare-function liberime-process-event "liberime")
(declare-function liberime-select-schema "liberime")
(declare-function liberime-workable-p "liberime")
(declare-function posframe-hide "posframe")
(declare-function posframe-show "posframe")
(declare-function posframe-workable-p "posframe")

(defvar liberime-current-schema)
(defvar liberime-select-schema-timer)

(defgroup +japanese-kagiroi nil
  "Kagiroi input method backed by liberime."
  :group 'leim
  :prefix "+japanese-kagiroi-")

(defcustom +japanese-kagiroi-schema "kagiroi"
  "Rime schema ID used by the Kagiroi input method."
  :type 'string
  :group '+japanese-kagiroi)

(defcustom +japanese-kagiroi-candidate-display 'echo-area
  "Where to display the Kagiroi preedit and candidates.
Use `posframe' for a child frame, `echo-area' for the echo area, or nil to
hide them.  Posframe display falls back to the echo area when unavailable."
  :type '(choice (const :tag "Child frame" posframe)
                 (const :tag "Echo area" echo-area)
                 (const :tag "Hidden" nil))
  :group '+japanese-kagiroi)

(defvar +japanese-kagiroi--posframe-buffer
  " *japanese-kagiroi-posframe*"
  "Buffer used for the Kagiroi candidate child frame.")

(defvar-local +japanese-kagiroi--previous-schema nil
  "Rime schema active before Kagiroi was enabled in this buffer.")

(defun +japanese-kagiroi--cancel-schema-timer ()
  "Cancel a pending asynchronous liberime schema selection."
  (when (and (boundp 'liberime-select-schema-timer)
             (timerp liberime-select-schema-timer))
    (cancel-timer liberime-select-schema-timer)
    (setq liberime-select-schema-timer nil)))

(defun +japanese-kagiroi--select-schema (schema &optional noerror)
  "Select SCHEMA synchronously.
When NOERROR is non-nil, return nil instead of reporting failure."
  (+japanese-kagiroi--cancel-schema-timer)
  (let ((selected (ignore-errors (liberime-select-schema schema))))
    (if selected
        (progn
          (setq liberime-current-schema schema)
          t)
      (unless noerror
        (user-error "Cannot select Rime schema %S; deploy Kagiroi first" schema))
      nil)))

(defun +japanese-kagiroi--current-schema ()
  "Return the schema ID used by the current liberime session."
  (alist-get 'schema_id (ignore-errors (liberime-get-status))))

(defun +japanese-kagiroi--ensure-liberime ()
  "Load liberime and verify that its dynamic module is available."
  (unless (require 'liberime nil t)
    (user-error "Liberime is not installed"))
  (unless (liberime-workable-p)
    (liberime-load))
  (unless (liberime-workable-p)
    (user-error "Liberime dynamic module is unavailable")))

(defun +japanese-kagiroi--ensure-ready ()
  "Load liberime and synchronously select Kagiroi."
  (+japanese-kagiroi--ensure-liberime)
  (unless (equal (+japanese-kagiroi--current-schema)
                 +japanese-kagiroi-schema)
    (+japanese-kagiroi--select-schema +japanese-kagiroi-schema)))

(defun +japanese-kagiroi--initial-key-p (key)
  "Return non-nil when KEY may start a Kagiroi composition."
  (and (integerp key)
       (or (and (>= key ?a) (<= key ?z))
           (and (>= key ?!) (<= key ?~)
                (not (or (and (>= key ?0) (<= key ?9))
                         (and (>= key ?A) (<= key ?Z))))))))

(defun +japanese-kagiroi--composing-p ()
  "Return non-nil while liberime has an active composition."
  (let ((input (ignore-errors (liberime-get-input))))
    (and (stringp input) (not (string-empty-p input)))))

(defun +japanese-kagiroi--take-commit ()
  "Return and consume the latest non-empty liberime commit."
  (let ((commit (ignore-errors (liberime-get-commit))))
    (and (stringp commit) (not (string-empty-p commit)) commit)))

(defun +japanese-kagiroi--candidate-string (menu)
  "Format the candidate list in MENU for the echo area."
  (let ((highlighted (alist-get 'highlighted-candidate-index menu)))
    (mapconcat
     (lambda (entry)
       (pcase-let ((`(,candidate . ,index) entry))
         (let ((label (format "%d.%s" index
                              (substring-no-properties candidate))))
           (if (eq (1- index) highlighted)
               (format "[%s]" label)
             label))))
     (cl-loop for candidate in (alist-get 'candidates menu)
              for index from 1
              collect (cons candidate index))
     " ")))

(defun +japanese-kagiroi--prompt ()
  "Return the current Kagiroi preedit and candidates as a prompt."
  (let* ((context (ignore-errors (liberime-get-context)))
         (composition (alist-get 'composition context))
         (preedit (alist-get 'preedit composition))
         (menu (alist-get 'menu context))
         (candidates (and menu
                          (+japanese-kagiroi--candidate-string menu))))
    (string-join (delq nil (list preedit
                                 (and (not (string-empty-p
                                            (or candidates "")))
                                      candidates)))
                 "  ")))

(defun +japanese-kagiroi--hide-candidates ()
  "Hide the Kagiroi candidate child frame, if present."
  (when (featurep 'posframe)
    (posframe-hide +japanese-kagiroi--posframe-buffer)))

(defun +japanese-kagiroi--read-event ()
  "Read one composition event while displaying the current candidates."
  (let ((prompt (+japanese-kagiroi--prompt)))
    (pcase +japanese-kagiroi-candidate-display
      ('posframe
       (if (and (require 'posframe nil t)
                (posframe-workable-p))
           (progn
             (posframe-show
              +japanese-kagiroi--posframe-buffer
              :string prompt
              :position (point)
              :min-width 20
              :background-color (face-background 'tooltip nil t)
              :foreground-color (face-foreground 'tooltip nil t)
              :border-width 1
              :border-color (face-foreground 'shadow nil t))
             (read-event))
         (read-event prompt)))
      ('echo-area (read-event prompt))
      (_ (read-event)))))

(defun +japanese-kagiroi--commit-composition ()
  "Commit the current composition and return its text."
  (when (+japanese-kagiroi--composing-p)
    (ignore-errors (liberime-commit-composition)))
  (+japanese-kagiroi--take-commit))

(defun +japanese-kagiroi--composition-loop ()
  "Read and process events until Kagiroi finishes its composition."
  (let (result done)
    (unwind-protect
        (while (and (not done) (+japanese-kagiroi--composing-p))
          (let* ((inhibit-quit t)
                 (event (+japanese-kagiroi--read-event))
                 (handled (and event
                               (ignore-errors
                                 (liberime-process-event event))))
                 (commit (+japanese-kagiroi--take-commit)))
            (cond
             (commit
              (setq result commit
                    done t))
             ((not handled)
              (setq result (+japanese-kagiroi--commit-composition)
                    done t)
              (when event
                (setq unread-command-events
                      (cons event unread-command-events))))
             ((not (+japanese-kagiroi--composing-p))
              (setq done t)))))
      (ignore-errors (liberime-clear-composition))
      (+japanese-kagiroi--hide-candidates))
    (and result (string-to-list result))))

(defun +japanese-kagiroi-input-method (key)
  "Process KEY through the Kagiroi schema in liberime."
  (cond
   ((null key) nil)
   ((not (+japanese-kagiroi--initial-key-p key))
    (list key))
   (t
    (condition-case error-data
        (progn
          (+japanese-kagiroi--ensure-ready)
          (liberime-clear-composition)
          (let ((handled (liberime-process-event key))
                (commit (+japanese-kagiroi--take-commit)))
            (cond
             (commit (string-to-list commit))
             ((and handled (+japanese-kagiroi--composing-p))
              (+japanese-kagiroi--composition-loop))
             (t
              (liberime-clear-composition)
              (list key)))))
      (error
       (ignore-errors (liberime-clear-composition))
       (message "Kagiroi input error: %s" (error-message-string error-data))
       (list key))))))

(defun +japanese-kagiroi-activate (_name)
  "Activate the Kagiroi input method."
  (+japanese-kagiroi--ensure-liberime)
  (let ((schema (+japanese-kagiroi--current-schema)))
    (setq-local +japanese-kagiroi--previous-schema
                (unless (equal schema +japanese-kagiroi-schema)
                  schema)))
  (+japanese-kagiroi--select-schema +japanese-kagiroi-schema)
  (setq-local input-method-function #'+japanese-kagiroi-input-method)
  (setq-local deactivate-current-input-method-function
              #'+japanese-kagiroi-deactivate))

(defun +japanese-kagiroi-deactivate ()
  "Deactivate Kagiroi and restore the preceding Rime schema."
  (ignore-errors (liberime-clear-composition))
  (+japanese-kagiroi--hide-candidates)
  (when +japanese-kagiroi--previous-schema
    (+japanese-kagiroi--select-schema
     +japanese-kagiroi--previous-schema t))
  (setq +japanese-kagiroi--previous-schema nil)
  (kill-local-variable 'input-method-function)
  (kill-local-variable 'deactivate-current-input-method-function))

;;;###autoload
(defun +japanese/toggle-kagiroi ()
  "Toggle the Kagiroi input method in the current buffer."
  (interactive)
  (if (equal current-input-method "kagiroi")
      (deactivate-input-method)
    (set-input-method "kagiroi")))

;;;###autoload
(register-input-method "kagiroi" "Japanese"
                       #'+japanese-kagiroi-activate "日"
                       "Kagiroi Japanese input via liberime")

(provide '+japanese-kagiroi-input-method)
