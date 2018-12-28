(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)

;; Load Evil Mode
(require 'evil)
(evil-mode t)

;; Info mode customizations (also currently used for help mode, too)
(defun mjc-info-run ()
  (define-key evil-motion-state-local-map "l" 'Info-history-back)
  (define-key evil-motion-state-local-map "\C-i" 'forward-button)
  )

(defun up-slightly () (interactive) (scroll-up 5))
(defun down-slightly () (interactive) (scroll-down 5))
(global-set-key [mouse-4] 'down-slightly)
(global-set-key [mouse-5] 'up-slightly)
(global-set-key "\C-ca" 'rename-buffer)
(global-set-key "\C-cm" 'woman)
(defun mjc-term-bash () (interactive) (shell))
(global-set-key "\C-c\C-t" 'mjc-term-bash)
(global-set-key "\C-ct" 'mjc-term-bash)
(defun mjc-other-term ()
  (interactive)
  (switch-to-buffer-other-window "*scratch*")
  (mjc-term-bash))
(global-set-key "\C-x4t" 'mjc-other-term)

(define-key isearch-mode-map [up] 'isearch-ring-retreat)
(define-key isearch-mode-map [down] 'isearch-ring-advance)

(menu-bar-mode -1)
(tool-bar-mode -1)
(auto-fill-mode 1)

(defun mjc-comint-bell-ctrl-g (&optional _string)
  "Strip `^G' characters from the current output group.
This function could be on `comint-output-filter-functions' or bound to a key."
  (interactive)
  (let ((pmark (process-mark (get-buffer-process (current-buffer)))))
    (save-excursion
      (condition-case nil
	  (goto-char
	   (if (called-interactively-p 'interactive)
	       comint-last-input-end comint-last-output-start))
	(error nil))
      (while (re-search-forward "\a" pmark t)
        (ding)
	(replace-match "" t t)))))

(add-hook 'comint-output-filter-functions 'mjc-comint-bell-ctrl-g)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(Info-mode-hook (quote (turn-on-font-lock mjc-info-run)))
 '(evil-esc-delay 0.0)
 '(explicit-shell-file-name "/bin/bash")
 '(help-mode-hook (quote (mjc-info-run)))
 '(indent-tabs-mode nil)
 '(make-backup-files nil)
 '(sentence-end-double-space nil)
 '(uniquify-buffer-name-style (quote post-forward) nil (uniquify))
 '(viper-fast-keyseq-timeout 0)
 '(viper-no-multiple-ESC t)
 '(xterm-mouse-mode t))
    
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(when (file-exists-p "~/.emacs-local")
  (load "~/.emacs-local"))
