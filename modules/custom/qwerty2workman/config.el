;;; custom/qwerty2workman/config.el -*- lexical-binding: t; -*-

(require 'cl-lib)

;; 重载时先由旧版本恢复状态，再替换函数和映射表。
(when (fboundp 'my-wm--restore-state)
  (my-wm--restore-state))

(defconst my-wm-keys
  '((?q ?Q ?q ?Q) (?w ?W ?d ?D) (?e ?E ?r ?R) (?r ?R ?w ?W)
    (?t ?T ?b ?B) (?y ?Y ?j ?J) (?u ?U ?f ?F) (?i ?I ?u ?U)
    (?o ?O ?p ?P) (?p ?P ?\; ?:)
    (?a ?A ?a ?A) (?s ?S ?s ?S) (?d ?D ?h ?H) (?f ?F ?t ?T)
    (?g ?G ?g ?G) (?h ?H ?y ?Y) (?j ?J ?n ?N) (?k ?K ?e ?E)
    (?l ?L ?o ?O) (?\; ?: ?i ?I)
    (?z ?Z ?z ?Z) (?x ?X ?x ?X) (?c ?C ?m ?M) (?v ?V ?c ?C)
    (?b ?B ?v ?V) (?n ?N ?k ?K) (?m ?M ?l ?L))
  "每项依次为 QWERTY 下档、上档和对应的 Workman 下档、上档。")

(defconst my-wm--modifier-kinds '(alt control hyper meta super))
(defconst my-wm--tty-ambiguous-events '(8 9 10 13)
  "文本终端中与 BS、TAB、LFD、RET 无法区分的 Ctrl 字符。")

(defun my-wm--make-event-map ()
  "生成保留修饰键的 QWERTY 到 Workman 事件映射。"
  (let ((table (make-hash-table :test #'eql)))
    (dotimes (mask 32)
      (let (modifiers)
        (dotimes (index (length my-wm--modifier-kinds))
          (unless (zerop (logand mask (ash 1 index)))
            (push (nth index my-wm--modifier-kinds) modifiers)))
        (dolist (key my-wm-keys)
          (dotimes (upper 2)
            (let ((source (event-convert-list
                           (append modifiers (list (nth upper key)))))
                  (target (event-convert-list
                           (append modifiers (list (nth (+ upper 2) key))))))
              (unless (eql source target)
                (puthash source target table)))))))
    table))

(defconst my-wm--event-map (my-wm--make-event-map))
(defvar my-workman--enabled nil
  "非 nil 表示 Workman 转换已启用；模块加载时默认停用。")
(defvar my-wm--terminals nil
  "各 terminal 的 (TERMINAL ORIGINAL-TABLE WORKMAN-TABLE) 状态。")
(defvar my-wm--saved-special-map nil)
(defvar my-wm--special-layer nil)

(defun my-wm--make-keyboard-layer (original graphic-p)
  "继承 ORIGINAL，为字符事件建立输入法之前的转换层。
GRAPHIC-P 为 nil 时保留文本终端中无法区分的 Ctrl 字符。"
  (let ((table (make-char-table 'keyboard-translate-table nil)))
    (cond
     ((char-table-p original)
      (set-char-table-parent table original))
     ((or (stringp original) (vectorp original))
      ;; Emacs 仍接受旧式字符串或向量；保留其中与本模块无关的转换。
      (let ((parent (make-char-table 'keyboard-translate-table nil)))
        (dotimes (index (length original))
          (aset parent index (aref original index)))
        (set-char-table-parent table parent)))
     (original
      (error "Unsupported keyboard-translate-table: %S" (type-of original))))
    (maphash
     (lambda (source target)
       (when (and (characterp source)
                  (or graphic-p (not (memq source my-wm--tty-ambiguous-events))))
         (aset table source target)))
     my-wm--event-map)
    table))

(defun my-workman--enable-terminal (&optional frame)
  "为 FRAME 所属的 terminal 启用字符转换，同一 terminal 只启用一次。"
  (let* ((frame (or frame (selected-frame)))
         (terminal (frame-terminal frame)))
    (unless (assq terminal my-wm--terminals)
      (with-selected-frame frame
        (let* ((original keyboard-translate-table)
               (table (my-wm--make-keyboard-layer original (display-graphic-p frame))))
          (setq keyboard-translate-table table)
          (push (list terminal original table) my-wm--terminals))))))

(defun my-wm--translate-modified-event ()
  "转换不能存入字符表的原始组合键，并把逻辑事件重新入队。"
  (interactive)
  (let* ((event last-input-event)
         (frame (if (and (framep last-event-frame) (frame-live-p last-event-frame))
                    last-event-frame
                  (selected-frame)))
         (target (if (and my-workman--enabled
                          (display-graphic-p frame)
                          (assq (frame-terminal frame) my-wm--terminals))
                     (gethash event my-wm--event-map event)
                   event)))
    ;; 此处理发生在输入法和按键记录之前。重新入队的事件跳过原始键盘转换阶段；t 保证前缀键序列和宏记录包含转换后的事件。
    (setq unread-command-events
          (cons (cons t target) unread-command-events))))

(defun my-wm--make-special-layer (original)
  "继承 ORIGINAL，在原始事件入口处理非字符组合键。"
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map original)
    (maphash
     (lambda (source _target)
       (unless (characterp source)
         (define-key map (vector source) #'my-wm--translate-modified-event)))
     my-wm--event-map)
    map))

(defun my-wm--without-layer (current layer original)
  "从 CURRENT 的父链移除 LAYER，根层被移除时恢复 ORIGINAL。"
  (if (eq current layer)
      original
    (let* ((character-layer-p (char-table-p layer))
           (layer-p (if character-layer-p #'char-table-p #'keymapp))
           (get-parent (if character-layer-p #'char-table-parent #'keymap-parent))
           (set-parent (if character-layer-p #'set-char-table-parent #'set-keymap-parent))
           (cursor current))
      (while (funcall layer-p cursor)
        (let ((parent (funcall get-parent cursor)))
          (if (eq parent layer)
              (progn
                (funcall set-parent cursor (funcall get-parent layer))
                (setq cursor nil))
            (setq cursor parent)))))
    current))

(defun my-wm--restore-state ()
  "移除本模块的转换层和 hook，保留原有及后来叠加的配置。"
  (remove-hook 'after-make-frame-functions #'my-workman--enable-terminal)
  (dolist (state my-wm--terminals)
    (let* ((terminal (nth 0 state))
           (frame (cl-find-if (lambda (frame) (eq (frame-terminal frame) terminal))
                             (frame-list))))
      (when frame
        (with-selected-frame frame
          (setq keyboard-translate-table
                (my-wm--without-layer keyboard-translate-table
                                      (nth 2 state) (nth 1 state)))))))
  (when my-wm--special-layer
    (setq special-event-map
          (my-wm--without-layer special-event-map
                                my-wm--special-layer my-wm--saved-special-map)))
  (setq my-workman--enabled nil
        my-wm--terminals nil
        my-wm--special-layer nil
        my-wm--saved-special-map nil))

(defun my-workman-enable ()
  "启用 Workman 字符和组合键转换；已启用时不做任何操作。"
  (interactive)
  (unless my-workman--enabled
    (condition-case error-data
        (progn
          (setq my-wm--saved-special-map special-event-map
                my-wm--special-layer (my-wm--make-special-layer special-event-map)
                special-event-map my-wm--special-layer)
          (dolist (frame (frame-list))
            (my-workman--enable-terminal frame))
          (add-hook 'after-make-frame-functions #'my-workman--enable-terminal)
          (setq my-workman--enabled t))
      (error
       (my-wm--restore-state)
       (signal (car error-data) (cdr error-data))))))

(defun my-workman-disable ()
  "停用 Workman 转换，恢复每个 terminal 的原有字符表；已停用时不做任何操作。"
  (interactive)
  (when my-workman--enabled
    (my-wm--restore-state)))
