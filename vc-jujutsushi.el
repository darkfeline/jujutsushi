;; jujutsuhsi-vc.el --- Teach vc about jujutsu projects -*- lexical-binding: t -*-

;; Copyright (©) 2024 Javier Olaechea <pirata@gmail.com>
;; Version: 0.0.1
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary

;; TODO: List all the functions that we might want to implement from vc.el

;;; Code:

(require 'cl-lib)
(require 'vc)

(defgroup vc-jujutsu nil
  "VC JJ backend."
  :group 'vc)

;; put into
vc-handled-backends

(defun vc-jj-root (file)
  (vc-find-root file ".jj"))


(defun vc-jj-create-repo ()
  ;; TODO: Implement this. We need to call `jj init default-default-directory'
  ;; (vc-jj-command "init")
  )

(provide 'jujutsushi-vc)
