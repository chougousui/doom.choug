;;; custom/qwerty2workman/config.el -*- lexical-binding: t; -*-
;;; 需要 Emacs 29 或更高。 ;;; 版本要求

;; Workman 键盘布局：
;;
;;   Q D R W B J F U P ;
;;    A S H T G Y N E O I
;;     Z X M C V K L , . /

(defconst my-wm-keys ; 定义 QWERTY 物理键与 Workman 字符
  '((?q ?Q ?q ?Q) (?w ?W ?d ?D) (?e ?E ?r ?R) (?r ?R ?w ?W) ; 第一排
    (?t ?T ?b ?B) (?y ?Y ?j ?J) (?u ?U ?f ?F) (?i ?I ?u ?U) ; 第一排
    (?o ?O ?p ?P) (?p ?P ?\; ?:) ; 第一排
    (?a ?A ?a ?A) (?s ?S ?s ?S) (?d ?D ?h ?H) (?f ?F ?t ?T) ; 第二排
    (?g ?G ?g ?G) (?h ?H ?y ?Y) (?j ?J ?n ?N) (?k ?K ?e ?E) ; 第二排
    (?l ?L ?o ?O) (?\; ?: ?i ?I) ; 第二排
    (?z ?Z ?z ?Z) (?x ?X ?x ?X) (?c ?C ?m ?M) (?v ?V ?c ?C) ; 第三排
    (?b ?B ?v ?V) (?n ?N ?k ?K) (?m ?M ?l ?L))) ; 第三排

(defconst my-wm--clash-bases '(?h ?i ?j ?m)) ; 标记与 BS、TAB、LFD、RET 同码的 Ctrl 基键

(defconst my-wm--modifier-kinds '(alt control hyper meta super)) ; Shift 通过上下档字符表示

(defun my-wm--modifier-sets () ; 生成五种非 Shift 修饰键的全部组合
  (let (sets) ; 保存组合
    (dotimes (mask 32) ; 遍历三十二种组合
      (let (modifiers) ; 保存当前组合
        (dotimes (index 5) ; 遍历五种修饰键
          (when (/= 0 (logand mask (ash 1 index))) ; 判断当前修饰键是否启用
            (push (nth index my-wm--modifier-kinds) modifiers))) ; 加入当前修饰键
        (push (nreverse modifiers) sets))) ; 保存当前组合
    (nreverse sets))) ; 返回全部组合

(defun my-wm--event (modifiers character) ; 按 Emacs 规则构造事件
  (event-convert-list (append modifiers (list character)))) ; 正确处理 Ctrl、大小写及其他修饰位

(defun my-wm--make-entries () ; 生成全部映射条目
  (let ((serial 0) entries) ; 保存中间事件编号和映射结果
    (dolist (modifiers (my-wm--modifier-sets)) ; 遍历修饰键组合
      (dolist (key my-wm-keys) ; 遍历物理键
        (dotimes (upper-index 2) ; 分别处理下档和上档
          (let* ((source-char (nth upper-index key)) ; 取得 QWERTY 来源字符
                 (target-char (nth (+ upper-index 2) key)) ; 取得 Workman 目标字符
                 (source-event (my-wm--event modifiers source-char)) ; 构造来源事件
                 (target-event (my-wm--event modifiers target-char)) ; 构造目标事件
                 (decode-p (and (memq 'control modifiers) ; 判断是否含有 Ctrl
                                (memq (nth 0 key) my-wm--clash-bases)))) ; 判断是否存在特殊键冲突
            (unless (eql source-event target-event) ; 跳过不需要转换的事件
              (setq serial (1+ serial)) ; 分配中间事件编号
              (push (list (if decode-p 'decode 'translation) ; 保存处理阶段
                          (vector source-event) ; 保存来源键序列
                          (vector target-event) ; 保存目标键序列
                          (and decode-p ; 仅冲突事件需要中间事件
                               (make-symbol (format "my-wm--bridge-%d" serial)))) ; 创建不可冲突的私有事件
                    entries)))))) ; 保存当前条目
    (nreverse entries))) ; 返回全部条目

(defconst my-wm--entries (my-wm--make-entries)) ; 缓存全部映射条目

(defun my-wm--make-translation-layer (parent) ; 构造最终转换层
  (let ((map (make-sparse-keymap))) ; 创建独立 keymap
    (set-keymap-parent map parent) ; 继承原有 key-translation-map
    (dolist (entry my-wm--entries) ; 遍历全部条目
      (if (eq (nth 0 entry) 'decode) ; 判断是否为冲突条目
          (define-key map (vector (nth 3 entry)) (nth 2 entry)) ; 将私有事件转换为最终事件
        (define-key map (nth 1 entry) (nth 2 entry)))) ; 普通事件直接转换
    map)) ; 返回转换层

(defun my-wm--make-decode-layer (parent) ; 构造冲突事件解码层
  (let ((map (make-sparse-keymap))) ; 创建独立 keymap
    (set-keymap-parent map parent) ; 继承原有 input-decode-map
    (dolist (entry my-wm--entries) ; 遍历全部条目
      (when (eq (nth 0 entry) 'decode) ; 仅处理冲突条目
        (define-key map (nth 1 entry) (vector (nth 3 entry))))) ; 来源事件只转换为私有事件
    map)) ; 返回解码层

(defun my-wm--make-direct-table () ; 构造直接读取函数使用的转换表
  (let ((table (make-hash-table :test #'eql))) ; 创建事件哈希表
    (dolist (entry my-wm--entries) ; 遍历全部条目
      (puthash (aref (nth 1 entry) 0) ; 取得来源事件
               (aref (nth 2 entry) 0) ; 取得最终事件
               table)) ; 保存映射
    table)) ; 返回转换表

(defun my-wm--make-decode-event-table () ; 构造文本终端冲突事件集合
  (let ((table (make-hash-table :test #'eql))) ; 创建事件集合
    (dolist (entry my-wm--entries) ; 遍历全部条目
      (when (eq (nth 0 entry) 'decode) ; 找出冲突事件
        (puthash (aref (nth 1 entry) 0) t table))) ; 将来源事件加入集合
    table)) ; 返回事件集合

(defconst my-wm--direct-table (my-wm--make-direct-table)) ; 缓存直接转换表

(defconst my-wm--decode-event-table (my-wm--make-decode-event-table)) ; 缓存冲突事件集合

(defvar my-wm--installed nil) ; 记录安装状态

(defvar my-wm--saved-translation-map nil) ; 保存原 key-translation-map

(defvar my-wm--translation-layer nil) ; 保存当前转换层

(defvar my-wm--saved-decode nil) ; 保存各图形终端的解码状态

(defun my-wm--without-layer (current layer original) ; 从 keymap 父链移除指定层
  (if (eq current layer) ; 判断指定层是否位于父链根部
      original ; 直接恢复原 keymap
    (let ((cursor current) parent done) ; 准备遍历父链
      (while (and (keymapp cursor) (not done)) ; 沿父链查找指定层
        (setq parent (keymap-parent cursor)) ; 取得父 keymap
        (cond ((eq parent layer) ; 判断是否找到指定层
               (set-keymap-parent cursor original) ; 将上层直接连接到原 keymap
               (setq done t)) ; 停止查找
              ((keymapp parent) ; 判断父链是否还能继续
               (setq cursor parent)) ; 移动到父 keymap
              (t ; 处理父链结束
               (setq done t)))) ; 停止查找
      current))) ; 保留后来添加的上层 keymap

(defun my-wm--frame-on-terminal (terminal) ; 查找指定终端的现存 frame
  (catch 'found ; 允许立即返回
    (dolist (frame (frame-list)) ; 遍历全部 frame
      (when (eq (frame-terminal frame) terminal) ; 判断终端是否相同
        (throw 'found frame))) ; 返回找到的 frame
    nil)) ; 未找到时返回 nil

(defun my-wm-install-decode (&optional frame) ; 为图形终端安装冲突事件解码
  (let ((frame (or frame (selected-frame)))) ; 默认使用当前 frame
    (when (display-graphic-p frame) ; 文本终端无法区分 Ctrl 同码键
      (let ((terminal (frame-terminal frame))) ; 取得 frame 所属终端
        (unless (assq terminal my-wm--saved-decode) ; 同一终端只安装一次
          (with-selected-frame frame ; 切换到目标终端
            (let* ((original input-decode-map) ; 保存原解码表
                   (layer (my-wm--make-decode-layer original))) ; 完整构造新解码层
              (setq input-decode-map layer) ; 启用新解码层
              (push (list terminal original layer) my-wm--saved-decode)))))))) ; 保存卸载状态

(defun my-wm--restore-decode-layers () ; 恢复各图形终端的解码表
  (dolist (state my-wm--saved-decode) ; 遍历终端状态
    (let* ((terminal (nth 0 state)) ; 取得终端
           (original (nth 1 state)) ; 取得原解码表
           (layer (nth 2 state)) ; 取得本配置的解码层
           (frame (my-wm--frame-on-terminal terminal))) ; 查找现存 frame
      (when frame ; 只处理仍然存在的终端
        (with-selected-frame frame ; 切换到目标终端
          (setq input-decode-map ; 更新该终端的解码表
                (my-wm--without-layer input-decode-map layer original)))))) ; 仅移除本配置的解码层
  (setq my-wm--saved-decode nil)) ; 清空终端状态

(defun my-wm--translate-direct-event (event) ; 转换直接读取的事件
  (if (or (not my-wm--installed) ; 未安装时不转换
          (and (not (display-graphic-p)) ; 判断当前是否为文本终端
               (gethash event my-wm--decode-event-table))) ; 判断事件是否无法区分
      event ; 保留无法安全转换的事件
    (gethash event my-wm--direct-table event))) ; 转换其他事件

(defun my-wm--around-direct-read (original &rest arguments) ; 包装直接读取函数
  (my-wm--translate-direct-event (apply original arguments))) ; 读取并转换一次

(defun my-wm-install () ; 安装 Workman 映射
  (interactive) ; 允许通过 M-x 调用
  (when my-wm--installed ; 阻止重复安装
    (user-error "workman: 已装载")) ; 报告重复安装
  (let ((original key-translation-map) layer) ; 保存原转换表
    (condition-case error-data ; 安装失败时执行回滚
        (progn ; 开始安装
          (setq layer (my-wm--make-translation-layer original)) ; 完整构造转换层
          (setq my-wm--saved-translation-map original) ; 保存原转换表
          (setq my-wm--translation-layer layer) ; 保存新转换层
          (setq key-translation-map layer) ; 启用新转换层
          (my-wm-install-decode) ; 安装当前图形终端的解码层
          (add-hook 'after-make-frame-functions #'my-wm-install-decode) ; 处理以后创建的图形 frame
          (dolist (function '(read-event read-char read-char-exclusive)) ; 遍历直接读取入口
            (advice-add function :around #'my-wm--around-direct-read)) ; 安装直接读取转换
          (setq my-wm--installed t)) ; 全部成功后标记为已安装
      (error ; 捕获安装错误
       (remove-hook 'after-make-frame-functions #'my-wm-install-decode) ; 移除 frame hook
       (dolist (function '(read-event read-char read-char-exclusive)) ; 遍历直接读取入口
         (advice-remove function #'my-wm--around-direct-read)) ; 移除 advice
       (my-wm--restore-decode-layers) ; 恢复终端解码表
       (when layer ; 判断转换层是否已经创建
         (setq key-translation-map ; 更新全局转换表
               (my-wm--without-layer key-translation-map layer original))) ; 移除转换层
       (setq my-wm--saved-translation-map nil) ; 清除原表状态
       (setq my-wm--translation-layer nil) ; 清除转换层状态
       (setq my-wm--installed nil) ; 恢复未安装状态
       (signal (car error-data) (cdr error-data)))))) ; 重新抛出原错误

(defun my-wm-uninstall () ; 卸载 Workman 映射
  (interactive) ; 允许通过 M-x 调用
  (unless my-wm--installed ; 阻止重复卸载
    (user-error "workman: 未装载")) ; 报告未安装
  (setq my-wm--installed nil) ; 停止直接读取转换
  (remove-hook 'after-make-frame-functions #'my-wm-install-decode) ; 移除 frame hook
  (dolist (function '(read-event read-char read-char-exclusive)) ; 遍历直接读取入口
    (advice-remove function #'my-wm--around-direct-read)) ; 移除 advice
  (my-wm--restore-decode-layers) ; 恢复终端解码表
  (setq key-translation-map ; 更新全局转换表
        (my-wm--without-layer key-translation-map ; 移除本配置转换层
                              my-wm--translation-layer ; 指定转换层
                              my-wm--saved-translation-map)) ; 指定原转换表
  (setq my-wm--saved-translation-map nil) ; 清除原表状态
  (setq my-wm--translation-layer nil)) ; 清除转换层状态

(unless my-wm--installed ; 避免重复安装
  (my-wm-install)) ; 首次加载时启用布局
