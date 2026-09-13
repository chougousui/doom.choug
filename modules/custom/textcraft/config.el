;;; custom/textcraft/config.el -*- lexical-binding: t; -*-

(load! "funcs")

(map! :leader
      :desc "Join items" "y n" #'textcraft/join-items
      :desc "Join quoted items" "y N" #'textcraft/join-items-2
      :desc "Split items" "y s" #'textcraft/split-items)
