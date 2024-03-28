;; jujutsuhsi.el --- Bring jj into your domain expansion -*- lexical-binding: t -*-

;; Copyright (©) 2024 Javier Olaechea <pirata@gmail.com>
;; Version: 0.0.1
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary

;;; Code:

(require 'cl-lib)
(require 'project)

(defgroup jujutsushi nil
  "Emacs interface to jujutsu version control system."
  :group 'tools)

;;;###autoload
(defun jj-describe ()
  ;; Use with-editor. call jj describe
  )

;;;###autoload
(defun jj-status ()
  ""
  (interactive)
  )


(provide 'jujutsushi)
