;;davbiwil/emacs-from-scratch


(setq inhibit-startup-message t)

(scroll-bar-mode -1)      ;Disable visible scrollbar
(tool-bar-mode -1)        ;Disable the toolbar
(tooltip-mode -1)         ;Disable tooltips
(set-fringe-mode 10)      ;Give some breathing room

(menu-bar-mode -1)        ;Disable the menu bar

;; Set up the visible bell
(setq visible-bell t)


(set-face-attribute 'default nil
		    :family "mononoki Nerd Font"
		    :height 180
		    :weight 'normal
		    :width  'normal)

;; Set the fixed pich face
(set-face-attribute 'fixed-pitch nil
		    :font "mononoki Nerd Font Mono"
		    :height 180)
		    
;; Set the variable pitch font
(set-face-attribute 'variable-pitch nil
		    :font "Cantarell"
		    :height 190
		    :weight 'regular)


;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;;Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
       			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;;Initialize use-package on non-Linux Platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(column-number-mode)
(global-display-line-numbers-mode t)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
		term-mode-hook
		shell-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package ivy
  ;;:diminish
  :bind (("C-s" . swipter)
	 :map ivy-minibuffer-map
	 ("TAB" . ivy-alt-done)
	 ("C-l" . ivy-alt-done)
	 ("C-j" . ivy-next-line)
	 ("C-k" . ivy-previous-line)
	 :map ivy-switch-buffer-map
	 ("C-k" . ivy-previous-line)
	 ("C-l" . ivy-done)
	 ("C-d" . ivy-switch-buffer-kill)
	 :map ivy-reverse-i-search-map
	 ("C-k" . ivy-previous-line)
	 ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))


(use-package all-the-icons)

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ()) ;(doom-modeline-height 15)))

(use-package doom-themes
  :init (load-theme 'doom-acario-dark t))


(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init (which-key-mode)		
  ;;:diminish which-key-mode
  :config (setq which-key-idle-delay 0.3))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
	("C-x b" . counsel-ibuffer)
	("C-x C-f" . counsel-find-file)
	:map minibuffer-local-map
	("C-r" . 'counsel-minibuffer-history)))
 ;; :config
 ;; (setq ivy-inital-inputs-alist nil)) ;; Dont start searches with ^

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package general
  :config
  (general-create-definer rune/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (rune/leader-keys
   "t" '(:ignore t :which-key "toggles")
   "tt" '(counsel-load-theme :which-key "choose theme")))

(defun rune/evil-hook ()
  (dolist (mode '(custom-mode
		  eshell-mode
		  git-rebase-mode
		  erc-mode
		  circle-server-mode
		  circle-chat-mode
		  circle-query-mode
		  sauron-mode
		  term-mode))
    (add-to-list 'evil-emacs-state-modes mode)))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  ;(define-key evil-insert-state-map (kbd "jk") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; use visual line motions even outside of the visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package hydra)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in") 
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(rune/leader-keys
  "ts" '(hydra-text-scale/body :which-key "scale text")) 

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-sytem 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/GitRepos")
    (setq projectile-project-search-path '("~/GitRepos")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package magit
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package evil-magit
  :after magit)

(use-package forge)

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (auto-fill-mode 0)
  (visual-line-mode 1)
  (setq evil-auto-indent nil))

(use-package org
    :config
    (setq org-ellipsis " ▾")
    
(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode)
  :custom
  (org-superstar-remove-leading-stars t)
  (org-superstar-headline-bullets-list '("◉" "○" "●" "○" "●" "○" "●")))

;; Replace list hyphen with dot
(font-lock-add-keywords 'org-mode
			'(("^ *\\([-]\\) "
			   ( 0 ( prog1 () (compose-region (match-beginning 1) (match-end 1) "●"))))))

(dolist (face '((org-level-1 . 1.2)
		(org-level-2 . 1.1)
		(org-level-3 . 1.05)
		(org-level-4 . 1.0)
		(org-level-5 . 1.1)
		(org-level-6 . 1.1)
		(org-level-7 . 1.1)
		(org-level-8 . 1.1)))
  (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

;; Endsure that anything that should be fixed-pitch in Org files appears that way
(set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-piched)
(set-face-attribute 'org-code nil  :inherit '(shadow fixed-piched))
(set-face-attribute 'org-indent nil  :inherit '(shadow fixed-piched))
(set-face-attribute 'org-table nil  :inherit '(shadow fixed-piched))
;;(set-face-attribute 'org-indent nil  :inherit '(org-hide fixed-piched))
(set-face-attribute 'org-verbatim nil  :inherit '(shadow fixed-piched))
(set-face-attribute 'org-special-keyword nil  :inherit '(font-lock-comment-face fixed-piched))
(set-face-attribute 'org-meta-line nil  :inherit '(font-lock-comment-face fixed-piched))
(set-face-attribute 'org-checkbox nil  :inherit '(fixed-piched))

(require 'org-indent)





(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(counsel-describe-function-function #'helpful-callable nil nil "Customized with use-package helpful")
 '(counsel-describe-variable-function #'helpful-variable nil nil "Customized with use-package helpful")
 '(custom-safe-themes
   '("5b809c3eae60da2af8a8cfba4e9e04b4d608cb49584cb5998f6e4a1c87c057c4" "71e5acf6053215f553036482f3340a5445aee364fb2e292c70d9175fb0cc8af7" default))
 '(package-selected-packages
   '(forge evil-magit magit councel-projectile projectile hydra evil-collection evil general doom-themes helpful ivy-rich which-key rainbow-delimiters doom-modeline ivy use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

