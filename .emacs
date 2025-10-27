(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(require 'facemenu)

(tool-bar-mode -1)
(menu-bar-mode -1)
(setq header-line-format nil)
(setq visible-bell t)

(setq make-backup-files nil)


;; (scroll-bar-mode -1)
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")

;; Function to unload all themes
(defun unload-all-themes ()
  "Unload all active themes."
  (mapcar #'disable-theme custom-enabled-themes))


(defun load-my-theme-interactively ()
  "Unload all themes, then prompt for and load a selected theme."
  (interactive)
  (unload-all-themes)  ;; Unload all active themes
  (let ((theme (intern (completing-read "Choose a theme: "
                                       (mapcar #'symbol-name (custom-available-themes))))))
    (load-theme theme t)))  ;; Load the selected theme

(defun theme-current-print ()
  "Display the currently enabled themes."
  (interactive)
  (if custom-enabled-themes
      (message "Current theme(s): %s" (mapconcat #'symbol-name custom-enabled-themes ", "))
    (message "No theme is currently enabled.")))

(global-set-key (kbd "C-x M-n") 'next-buffer)
(global-set-key (kbd "C-x M-p") 'previous-buffer)

(global-set-key (kbd "C-c t") 'load-my-theme-interactively)
(global-set-key (kbd "C-<tab>") 'eglot-format)

(global-set-key (kbd "M-n") 'flymake-goto-next-error)
(global-set-key (kbd "M-p") 'flymake-goto-prev-error)

(global-set-key (kbd "C-c C-b") 'flymake-show-buffer-diagnostics)
(global-set-key (kbd "C-c C-p") 'flymake-show-project-diagnostics)

(global-set-key (kbd "C-c C-r") 'eglot-rename)


(global-set-key (kbd "C-c M-n") 'windmove-down)
(global-set-key (kbd "C-c M-p") 'windmove-up)
(global-set-key (kbd "C-c M-a") 'windmove-left)
(global-set-key (kbd "C-c M-e") 'windmove-right)

;; go setup start

(require 'project)

(defun project-find-go-module (dir)
  (when-let ((root (locate-dominating-file dir "go.mod")))
    (cons 'go-module root)))

(cl-defmethod project-root ((project (head go-module)))
  (cdr project))

(add-hook 'project-find-functions #'project-find-go-module)

;; Optional: load other packages before eglot to enable eglot integrations.
(require 'company)
(require 'yasnippet)

(add-hook 'dart-mode-hook 'company-mode)


(require 'go-mode)

(add-hook 'go-mode-hook 'company-mode)

(require 'eglot)

(setq eglot-events-buffer-size 0)


;; doesn't seem to work
;; (setq jsonrpc-log-level 'warn)
;; (add-hook 'go-mode-hook 'eglot-ensure)

;; Optional: install eglot-format-buffer as a save hook.
;; The depth of -10 places this before eglot's willSave notification,
;; so that that notification reports the actual contents that will be saved.
(defun eglot-format-buffer-before-save ()
  (add-hook 'before-save-hook #'eglot-format-buffer -10 t))
(add-hook 'go-mode-hook #'eglot-format-buffer-before-save)

(setq-default eglot-workspace-configuration
    '((:gopls .
        ((staticcheck . t)
         (matcher . "CaseSensitive")))))


(setq-default eglot-workspace-configuration
    '((:gopls .
        ((staticcheck . t)
         (matcher . "CaseSensitive")))))

;; go setup end
(require 'multiple-cursors)
(global-set-key (kbd "C-;") 'mc/edit-lines)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(eglot-ignored-server-capabilities
   '(:documentOnTypeFormattingProvider :foldingRangeProvider
				       :inlayHintProvider
				       ))
 '(package-selected-packages
   '(
			company
			dart-mode
			ef-themes
			go-mode gradle-mode
			magit
			multiple-cursors
			yaml-mode yasnippet
			)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:background nil)))))



(defun json-minify-region (start end)
  "Minify JSON in region using the 'jq' command-line tool.
Replaces the region with its minified JSON representation."
  (interactive "r")
  (unless (executable-find "jq")
    (user-error "jq command not found. Please install jq first."))
  (let ((json-input (buffer-substring-no-properties start end)))
    (delete-region start end)
    (insert (shell-command-to-string (format "echo %s | jq -c ." (shell-quote-argument json-input))))))

(setq gofmt-command "goimports")
(add-hook 'before-save-hook 'gofmt-before-save)
(put 'upcase-region 'disabled nil)


(defun copy-pwd-to-kill-ring ()
  "Copy the current buffer's directory to the kill ring."
  (interactive)
  (kill-new default-directory)
  (message "Copied directory: %s" default-directory))
