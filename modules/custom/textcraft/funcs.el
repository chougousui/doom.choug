;;; custom/textcraft/funcs.el -*- lexical-binding: t; -*-

(defun textcraft--parse-items (text)
  "解析 TEXT 中的元素，并移除元素两端成对的单引号或双引号"
  (mapcar
   (lambda (element)
     (if (and (> (length element) 1)
              (memq (aref element 0) '(?\" ?\'))
              (= (aref element 0) (aref element (1- (length element)))))
         (substring element 1 -1)
       element))
   (split-string text "[,，[:space:]　]+" t)))

(defun textcraft/join-items (begin end)
  "标准化选中区域中的数组数据，复制结果并插入到原内容下方"
  (interactive "r")
  (unless (use-region-p)
    (user-error "No active region"))
  (let* ((text (buffer-substring-no-properties begin end))
         (elements (textcraft--parse-items text))
         (joined (mapconcat #'identity elements ",")))
    (kill-new joined)
    (deactivate-mark)
    (goto-char end)
    (when (and (> end begin)
               (bolp)
               (eq (char-before) ?\n))
      (backward-char))
    (end-of-line)
    (insert "\n\n" joined)))

(defun textcraft/join-items-2 (begin end)
  "将选中区域中的元素加上单引号和括号，复制结果并插入到原内容下方"
  (interactive "r")
  (unless (use-region-p)
    (user-error "No active region"))
  (let* ((text (buffer-substring-no-properties begin end))
         (elements (textcraft--parse-items text))
         (joined
          (concat "("
                  (mapconcat
                   (lambda (element)
                     (format "'%s'" element))
                   elements
                   ", ")
                  ")")))
    (kill-new joined)
    (deactivate-mark)
    (goto-char end)
    (when (and (> end begin)
               (bolp)
               (eq (char-before) ?\n))
      (backward-char))
    (end-of-line)
    (insert "\n\n" joined)))

(defun textcraft/split-items ()
  "将光标所在行的逗号分隔内容逐项插入到该行下方"
  (interactive)
  (let* ((text (buffer-substring-no-properties
                (line-beginning-position)
                (line-end-position)))
         (elements (split-string text "," t "[[:space:]　]+"))
         (expanded (mapconcat #'identity elements "\n")))
    (end-of-line)
    (insert "\n\n" expanded)))
