;;; mount.el --- Mount and unmount devices in Emacs  -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Tomas Zellerin

;; Author: Tomas Zellerin <tomas@zellerin.cz>
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; Open new buffer with list of deviced (sd..) with `mount' command.

;;

;;; Code:
(defun mount-do-mount (button)
  (message "Mounting %s" (button-label button))
  (let ((dir (read-directory-name "Mount at: " "/mnt")))
    (start-process "mount" "*mount*"
		   "sudo" "mount" (button-label button) dir)
    (push (cons (button-label button) dir) mount-manual-mounts))
  (mount-insert-manual-mounts))

(defun mount-do-umount (button)
  (message "Mounting %s" (button-label button))
  (start-process "umount" "*mount*"
		 "sudo" "umount" (button-label button))
  (setq mount-manual-mounts
	(cl-remove (button-get button 'point) mount-manual-mounts
		   :key 'car :test 'equal))
  (mount-insert-manual-mounts))

(defun mount-clear-section (section)
  (goto-char 1)
  (search-forward section nil t)
  (narrow-to-page)
  (delete-region (point-min) (point-max))
  (insert section "\n"))

(defun mount-insert-devices ()
  (interactive)
  (mount-clear-section "Mounts: ")
  (dolist (dev (directory-files "/dev" t "^sd[a-z][0-9]"))
    (insert ?\^I)
    (insert-button dev
		   'action 'mount-do-mount)
    (insert "\n"))
  (widen))

(defvar mount-manual-mounts ()
  "List of manually mounted directories")

(defun mount-insert-manual-mounts ()
  (interactive)
  (goto-char 1)
  (search-forward "Mounted:" nil t)
  (narrow-to-page)
  (delete-region (point-min) (point-max))
  (insert "Mounted:\n")
  (dolist (dev mount-manual-mounts)
    (insert ?\^I)
    (insert-button (car dev)
		   'action 'mount-do-umount
		   'point (car dev))

    (insert " on ")
    (insert-button (cdr dev)
		   'action 'mount-do-umount
		   'point (car dev))
    (insert "\n"))
  (widen))

(define-derived-mode mount-mode special-mode "MOUNTS"
  (setq buffer-read-only nil))

(bind-key "I" 'mount-insert-devices mount-mode-map)
(bind-key "M" 'mount-insert-manual-mounts mount-mode-map)
(bind-key "g" 'mount-clear mount-mode-map)
(bind-key "o" 'ffap mount-mode-map)

(defun mount-clear ()
  (interactive)
  (switch-to-buffer "*mount*")
  (delete-region (point-min) (point-max))
  (insert "Mounts: \n\n")
  (insert "Mounted: \n\n")
  (mount-insert-devices)
  (mount-insert-manual-mounts))

(defun mount ()
  (interactive)
  (mount-clear)
  (mount-mode))


(provide 'mount-mode)
;;; mount.el ends here
