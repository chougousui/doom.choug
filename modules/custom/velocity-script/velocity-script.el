;;; custom/velocity-script/velocity-script.el -*- lexical-binding: t; -*-

;; Apache Velocity(.vm/.vtl)模板 major mode, 继承自 web-mode。
;; C-c C-n: 行首为 #foreach 或 #end 时改用纯语法层面的配对跳转
;; (web-mode 原生的 web-mode-navigate 依赖 fontification 产生的 block 文本属性,
;; 属性缺失或不完整时 foreach/end 无法配对), 其余情况沿用 web-mode 原生逻辑。
;; 配对按嵌套深度计数, 与缩进无关; 限制在行粒度: 一行多个指令时只识别第一个。
;; 文件布局: 入口在前, 被调用的函数按调用顺序排在后面。

(define-derived-mode velocity-script-mode web-mode "Velocity"
  "基于 web-mode 的 Apache Velocity 模板 major mode。")

(define-key velocity-script-mode-map (kbd "C-c C-n") #'velocity-script-navigate)

(defconst velocity-script-directive-line-regexp
  "^[ \t]*#[ \t]*\\([A-Za-z]+\\)"
  "匹配行首 VTL 指令, 第 1 组为指令名。
匹配示例:
  \"#foreach($item in $items)\" 捕获 \"foreach\"
  \"  #end\"                   捕获 \"end\"
  \"#macro(card $t)\"          捕获 \"macro\"
不匹配示例:
  \"<li #if($x)a#end>\" 行内指令
  \"##end\"             行注释")

(defun velocity-script-navigate ()
  "行首 #foreach/#end 行用语法配对跳转, 其余沿用 web-mode-navigate。"
  (interactive)
  (let ((target (and (member (velocity-script--line-directive (thing-at-point 'line t))
                             '("foreach" "end"))
                     (velocity-script-block-navigate))))
    (if target
        (goto-char target)
      (web-mode-navigate))))

(defun velocity-script-block-navigate ()
  "在当前行的 VTL 指令与其配对的 #end 之间跳转, 返回目标位置或 nil。"
  (pcase (velocity-script--line-kind (thing-at-point 'line t))
    (`open (velocity-script--scan-matching +1 1))
    (`end (velocity-script--scan-matching -1 1))
    (_ nil)))

(defun velocity-script--scan-matching (step depth)
  "从当前行沿 STEP(+1 向下/-1 向上)扫描配对指令, 返回目标位置或 nil。
DEPTH 为起始深度, 开指令与闭指令处均为 1, 命中深度归零的行。"
  (let (found)
    (save-excursion
      (while (and (not found) (zerop (forward-line step)))
        (let ((kind (velocity-script--line-kind (thing-at-point 'line t))))
          (cond ((eq kind 'open) (setq depth (+ depth step)))
                ((eq kind 'end) (setq depth (- depth step)))))
        (when (zerop depth)
          (setq found (progn (back-to-indentation) (point)))))
      found)))

(defun velocity-script--line-kind (line)
  "返回 LINE 的种类: open/end, 非指令行返回 nil。
open 清单必须包含全部由 #end 闭合的指令, 否则 foreach 内层的
#if...#end 会错误抵消深度; 该清单只用于计数, 不决定接管范围。"
  (let ((name (velocity-script--line-directive line)))
    (cond ((member name '("foreach" "for" "if" "macro" "define" "def")) 'open)
          ((equal name "end") 'end))))

(defun velocity-script--line-directive (line)
  "返回 LINE(字符串)行首的指令名, 非指令行返回 nil。"
  (and (stringp line)
       (string-match velocity-script-directive-line-regexp line)
       (match-string 1 line)))
