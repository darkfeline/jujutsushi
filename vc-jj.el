;;; vc-jj.el --- Teach vc about jujutsu projects -*- lexical-binding: t -*-

;; Copyright (C) 2024 Javier Olaechea <pirata@gmail.com>

;; Version: 0.1.0
;; Package-Requires: ((emacs "29.3"))
;; Keywords: vc, tools
;; URL: https://github.com/darkfeline/jujutsushi
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Status Legend:
;; - ✔: Done
;; - DNA does not apply: The decision is that we won't
;; - ?: Not done. It has yet to be decided whether or not it should be implemented
;;
;;  Some of the functions are mandatory (marked with a `*'), others are optional
;; (`-').
;;
;; BACKEND PROPERTIES
;;
;; * revision-granularity: ✔
;; - update-on-retrieve-tag: ✔
;;
;; STATE-QUERYING FUNCTIONS
;;
;; * registered (file): ✔
;; * state (file): ✔
;; - dir-status-files (dir files update-function)
;; - dir-extra-headers (dir)
;; - dir-printer (fileinfo)
;; - status-fileinfo-extra (file)
;; * working-revision (file): ✔
;; * checkout-model (files): ✔
;; - mode-line-string (file)
;;
;; STATE-CHANGING FUNCTIONS
;;
;; * create-repo (): ✔
;; * register (files &optional comment)
;; - responsible-p (file): ✔
;; - receive-file (file rev)
;; - unregister (file)
;; * checkin (files comment &optional rev)
;; - checkin-patch (patch-string comment)
;; * find-revision (file rev buffer)
;; * checkout (file &optional rev)
;; * revert (file &optional contents-done)
;; - merge-file (file &optional rev1 rev2)
;; - merge-branch ()
;; - merge-news (file)
;; - pull (prompt)
;; - steal-lock (file &optional revision)
;; - modify-change-comment (files rev comment)
;; - mark-resolved (files)
;; - find-admin-dir (file)
;;
;; HISTORY FUNCTIONS
;;
;; * print-log (files buffer &optional shortlog start-revision limit)
;; * log-outgoing (buffer remote-location)
;; * log-incoming (buffer remote-location)
;; - log-search (buffer pattern)
;; - log-view-mode ()
;; - show-log-entry (revision)
;; - comment-history (file)
;; - update-changelog (files)
;; * diff (files &optional rev1 rev2 buffer async)
;; - revision-completion-table (files)
;; - annotate-command (file buf &optional rev)
;; - annotate-time ()
;; - annotate-current-time ()
;; - annotate-extract-revision-at-line ()
;; - region-history (file buffer lfrom lto)
;; - region-history-mode ()
;; - mergebase (rev1 &optional rev2)
;; - last-change (file line)
;;
;; TAG/BRANCH SYSTEM
;;
;; - create-tag (dir name branchp)
;; - retrieve-tag (dir name update)
;;
;; MISCELLANEOUS
;;
;; - make-version-backups-p (file)
;; - root (file)
;; - ignore (file &optional directory remove)
;; - ignore-completion-table (directory)
;; - find-ignore-file (file): ✔
;; - previous-revision (file rev)
;; - file-name-changes (rev)
;; - next-revision (file rev)
;; - log-edit-mode ()
;; - check-headers ()
;; - delete-file (file)
;; - rename-file (old new)
;; - find-file-hook ()
;; - extra-menu ()
;; - extra-dir-menu ()
;; - conflicted-files (dir)
;; - repository-url (file-or-dir &optional remote-name)
;; - prepare-patch (rev)
;; - clone (remote directory rev)

;;; Code:

(require 'cl-lib)
(require 'vc)

(defgroup vc-jj nil
  "VC jujutsu backend."
  :group 'vc)

(defcustom vc-jj-program "jj"
  "Name of the jujutsu executable."
  :type 'string)

(defun vc-jj-revision-granularity () 'repository)
(defun vc-jj-checkout-model (_files) 'implicit)
(defun vc-jj-update-on-retrieve-tag () nil)

(defun vc-jj-root (file)
  (vc-find-root file ".jj"))

;; jujutsu uses .gitignore
(defun vc-jj-find-ignore-file (file)
  "Return the git ignore file that controls FILE."
  (expand-file-name ".gitignore"
                    (vc-git-root file)))

(defun vc-jj-command (buffer okstatus file-or-list &rest flags)
  "A wrapper around `vc-do-command' for use in vc-jujutsu.el"
  ;; TODO: Should I pass `--color never' to flags as well?
  (apply #'vc-do-command (or buffer "*vc*") okstatus vc-jj-program (cons "--no-pager" flags)))

(defun vc-jj-create-repo ()
  (vc-jj-command "init"))

(defun vc-jj-root (file)
  "Return t if FILE is under version control with jujutsu."
  (vc-find-root file ".jj"))

(defalias 'vc-jj-responsible-p #'vc-jj-root)

(defun vc-jj-registered (file)
  "Check whether FILE is registered with jujutsu."
  (when-let ((dir (vc-jj-root file)))
    (with-temp-buffer
      ;; If something is output then the file is registered.
      (not (string= "" (shell-command-to-string (format "jj file list %s" file)))))))

;; The possible states are exhaustively listed in `vc-state'. For
;; jujutsu the ones that make sense are:
;;
;; - up-to-date
;; - edited
;; - added
;; - removed
;; - conflict
(defun vc-jj-state (file)
  ;; = Current implementation strategy
  ;;
  ;; We run jj show -r @ -s. Search for the file list. We do that by
  ;; looking for the line after the second empty line. The file list
  ;; will be printed as follows:
  ;;
  ;; A foo.el -- added
  ;; M foo.el -- edited
  ;; D foo.el -- removed
  ;;
  ;; If the file is not mentioned then it is `up-to-date'
  ;;
  ;; TODO: How do we detect conflicts?
  ;; TODO: Evaluate if we can use templates to enable structured output that it is easier to parse.
  ;; TODO: Setup test cases using jj op log

  (with-temp-buffer
    (call-process "jj" nil t nil "show" "-r" "@" "-s")
    (goto-char (point-max))
    (forward-line -2)
    ;; Check that we are looking at an empty line
    (when (looking-at "^$")
      (forward-line 1)
      (pcase (string-to-char (buffer-substring-no-properties (point) (1+ (point))))
        (?A 'added)
        (?M 'edited)
        (?D 'removed)))))

;; = Current implementation
;;
;; We need to run `jj st' and look for a line that starts with Working copy : $change-id
;; $ jj st
;; The working copy is clean
;; Working copy : qrumvnvn 31fe04cc (empty) (no description set)
;; Parent commit: lvzwqkuy 3a103eef default | Implement vc-jj-state
(defun vc-jj-working-revision (_file)
  (with-temp-buffer
    (call-process "jj" nil t nil "st")
    (goto-char (point-min))
    (when (re-search-forward "Working copy : \\([^ \t\n]+\\)" nil t)
      (match-string 1))))

;;;###autoload
(add-to-list 'vc-handled-backends 'jj)

;;;###autoload
(add-to-list 'vc-directory-exclusion-list ".jj")

(provide 'vc-jj)
;; vc-jj ends here
