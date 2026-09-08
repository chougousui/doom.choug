;;; modules/custom/json-ext/functions.el -*- lexical-binding: t; -*-

(defun json-ext--value-node-at-point ()
  "返回光标所在 JSON 值节点,key 上返回其对应的值节点"
  (when-let* ((node (treesit-node-at (point)))
              ((<= (treesit-node-start node)
                   (point)
                   (1- (treesit-node-end node))))
              (node-type (treesit-node-type node))
              (parent (treesit-node-parent node))
              (current-node
               (cond ((member node-type
                              '("string" "number" "true" "false"
                                "null" "array" "object"))
                      node)
                     ((member (treesit-node-type parent)
                              '("string" "array" "object"))
                      parent)))
              (owner (treesit-node-parent current-node)))
    (if (and (string= (treesit-node-type owner) "pair")
             (treesit-node-eq
              current-node
              (treesit-node-child-by-field-name owner "key")))
        (treesit-node-child-by-field-name owner "value")
      current-node)))

(defun json-ext--field-value-node-at-point ()
  "返回光标所在最近字段的值节点"
  (let ((node (treesit-node-at (point))))
    (while (and node (not (string= (treesit-node-type node) "pair")))
      (setq node (treesit-node-parent node)))
    (when node
      (treesit-node-child-by-field-name node "value"))))

(defun json-ext--deletable-node-at-point ()
  "返回光标所在的可删除 JSON 节点"
  (let ((node (treesit-node-at (point)))
        target)
    (when (and node
               (<= (treesit-node-start node)
                   (point)
                   (1- (treesit-node-end node)))
               (not (string= (treesit-node-type node) ",")))
      (while (and node (not target))
        (let ((parent (treesit-node-parent node)))
          (when (or (string= (treesit-node-type node) "pair")
                    (and parent
                         (member (treesit-node-type parent)
                                 '("array" "document"))
                         (member (treesit-node-type node)
                                 '("string" "number" "true" "false"
                                   "null" "array" "object"))))
            (setq target node))
          (setq node parent))))
    target))

(defun json-ext--node-deletion-range (node)
  "返回删除 NODE 及相邻必要逗号的范围"
  (let ((next (treesit-node-next-sibling node))
        (next-named (treesit-node-next-sibling node t))
        (previous (treesit-node-prev-sibling node)))
    (cond ((and next
                next-named
                (string= (treesit-node-type next) ","))
           (cons (treesit-node-start node)
                 (treesit-node-start next-named)))
          ((and previous (string= (treesit-node-type previous) ","))
           (cons (treesit-node-start previous)
                 (treesit-node-end node)))
          (t (cons (treesit-node-start node)
                   (treesit-node-end node))))))

(defun json-ext-delete-node ()
  "删除光标所在的 JSON 节点"
  (interactive)
  (when-let* ((node (json-ext--deletable-node-at-point))
              (range (json-ext--node-deletion-range node)))
    (delete-region (car range) (cdr range))
    (goto-char (car range))))

(defun json-ext-nullify-node ()
  "将光标所在 JSON 值或 key 对应的值替换为 null"
  (interactive)
  (when-let* ((value-node (json-ext--value-node-at-point)))
    (unless (string= (treesit-node-type value-node) "null")
      (let* ((original-point (point))
             (start (treesit-node-start value-node))
             (end (treesit-node-end value-node))
             (point-on-value (<= start original-point (1- end))))
        (delete-region start end)
        (goto-char start)
        (insert "null")
        (unless point-on-value
          (goto-char original-point))))))

(defun json-ext-copy-value ()
  "复制光标所在字段的值且不移动光标"
  (interactive)
  (save-excursion
    (when-let* ((value-node (or (json-ext--field-value-node-at-point)
                                (json-ext--value-node-at-point)))
                (text (treesit-node-text value-node t))
                (value (if (string= (treesit-node-type value-node) "string")
                           (json-parse-string text)
                         text)))
      (kill-new value)
      (message "Copied JSON value to clipboard")
      value)))
