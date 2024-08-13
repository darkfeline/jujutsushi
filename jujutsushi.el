;; jujutsuhsi.el --- Bring jj into your domain expansion -*- lexical-binding: t -*-

;; Copyright (©) 2024 Javier Olaechea <pirata@gmail.com>
;; Version: 0.0.1
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;;; Code:

(require 'cl-lib)
(require 'project)
(require 'with-editor)

(defgroup jujutsushi nil
  "Emacs interface to jujutsu version control system."
  :group 'tools)

;;;###autoload
(defun jj-describe ()
  "Open a buffer to describe the current revision."
  ;; TODO: Allow passing the revision to describe as a parameter.
  ;; TODO: Default revision-at-point, default to @ if there is no revision
  (interactive)
  (with-editor-async-shell-command
   (mapconcat #'shell-quote-argument
              (list "jj" "describe" "-r" "@") " ")
   ;; Set JJ_EDITOR so that we override the ui.editor setting.
   nil nil "JJ_EDITOR"))

;;;###autoload
(defun jj-status ()
  ""
  (interactive)
  "IOU")

;;;###autoload
(defun jj-dashboard ()
  "Opens and refreshes the project's jj dashboard.

The dashboard shows the combined output of jj status, jj log and jj branch list."
  (interactive)
  "IOU")


(provide 'jujutsushi)
