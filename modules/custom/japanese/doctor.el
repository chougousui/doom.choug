;;; custom/japanese/doctor.el -*- lexical-binding: t; -*-

(unless (modulep! :input chinese +rime)
  (error! ":custom japanese requires :input (chinese +rime)"))

(unless (modulep! :custom chinese-ext)
  (warn! ":custom japanese expects :custom chinese-ext to configure liberime"))

(unless (file-exists-p
         (expand-file-name "~/.config/my-rime-schema-for-emacs/kagiroi.schema.yaml"))
  (warn! "Kagiroi schema not found in ~/.config/my-rime-schema-for-emacs"))
