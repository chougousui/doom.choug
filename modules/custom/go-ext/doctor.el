;;; custom/go-ext/doctor.el -*- lexical-binding: t; -*-

(unless (modulep! :lang go)
  (warn! "need enable lang/go first"))
