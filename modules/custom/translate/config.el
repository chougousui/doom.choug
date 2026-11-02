;;; custom/translate/config.el -*- lexical-binding: t; -*-

(use-package! gt
  :defer-incrementally t
  :config
  ;; gt.el 把一次翻译分成三个部分：
  ;; taker  负责取得要翻译的原文，并确定源语言和目标语言
  ;; engine 负责把原文发送给翻译服务并取回译文
  ;; render 负责把译文输出到指定位置
  (setq gt-default-translator
        (gt-translator
         :taker (gt-taker
                 ;; 语言范围,gt.el尝试自动识别语言,目标语言在剩下两个中选择,交互式使用C-n/C-p来更改目标语言
                 :langs '(en zh ja)
                 ;; 取原文的范围,有选区都使用选区作为翻译目标,没有选取时选择光标所在的buffer, word, sentence, point
                 :text 'buffer
                 ;; 取到原文后是否拆成多段分别翻译
                 ;; nil: 不主动分段;
                 ;; paragraph: 按段落拆开逐段翻译,插入时每段后面各插一段译文(默认值);
                 ;; sentence: 按句子拆开逐句翻译;
                 ;; word: 按单词拆开逐词翻译,可配合 :pick-pred 过滤单词;
                 :pick nil
                 ;; 是否需要用户交互以确定翻译方向
                 :prompt t)
         ;; gt-google-engine: 选用google翻译作为后端
         ;; gt-google-summary-parser: 取回翻译结果时,不取原文音标,译文音标
         :engines (gt-google-engine :parse (gt-google-summary-parser))
         ;; gt-insert-render: 翻译结果插入到某处: after, replace
         ;; gt-postframe-pop-render: 显示在posframe中
         ;; gt-kill-ring-render: 存入kill ring
         :render (gt-insert-render :type 'after))))

(map! :leader
      (:prefix ("r" . "translate")
       :desc "Translate" "r" #'gt-translate
       :desc "Translate to English" "e" #'translate/to-english
       :desc "Translate to Japanese" "j" #'translate/to-japanese
       :desc "Translate to Chinese" "c" #'translate/to-chinese))

(defun translate/to-english ()
  "将选区（无选区时为整个 buffer）翻译为英语，译文插入到原文之后"
  (interactive)
  (translate--start 'en))

(defun translate/to-japanese ()
  "将选区（无选区时为整个 buffer）翻译为日语，译文插入到原文之后"
  (interactive)
  (translate--start 'ja))

(defun translate/to-chinese ()
  "将选区（无选区时为整个 buffer）翻译为中文，译文插入到原文之后"
  (interactive)
  (translate--start 'zh))

(defun translate--start (target-lang)
  "自动识别原文语言，翻译为 TARGET-LANG"
  (gt-start
   (gt-translator
    :taker (gt-taker :langs '(en zh ja) :text 'buffer :pick nil
                     ;; 源语言沿用自动识别的结果，目标语言替换为 TARGET-LANG
                     :then (lambda (translator)
                             (oset translator target
                                   (list (car (oref translator target)) target-lang))))
    :engines (gt-google-engine :parse (gt-google-summary-parser))
    :render (gt-insert-render :type 'after))))
