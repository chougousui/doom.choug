;;; custom/japanese/config.el -*- lexical-binding: t; -*-

(load! "kagiroi-input-method")

(when (modulep! +childframe)
  (setq +japanese-kagiroi-candidate-display 'posframe))
