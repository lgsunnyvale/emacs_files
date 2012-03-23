(set-default-font "-apple-monaco-medium-r-normal--11-0-72-72-m-0-iso10646-1")

;;; This was installed by package-install.el.
;;; This provides support for the package system and
;;; interfacing with ELPA, the package archive.
;;; Move this code earlier if you want to reference
;;; packages in your .emacs.
(when
    (load
     (expand-file-name "~/.emacs.d/site-lisp/package.el"))
  (package-initialize))
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))


(menu-bar-mode 0)
(setq inhibit-startup-message t)
(setq visible-bell 1)
(setq ring-bell-function 
      (lambda ()
	(unless (memq this-command
		      '(isearch-abort abort-recursive-edit exit-minibuffer keyboard-quit))
	  (ding))))
(recentf-mode 1)
(show-paren-mode 1)

(delete-selection-mode t)
(set-default 'indicate-empty-lines t)
(setq backup-directory-alist '(("."."~/.emacs.d/backups")))
(add-to-list 'load-path "~/emacs.d/site-lisp")
(let ((default-directory "~/.emacs.d/"))
  (normal-top-level-add-to-load-path '("."))
  (normal-top-level-add-subdirs-to-load-path))

(transient-mark-mode 1)
(defun select-current-line ()
  "Select the current line"
  (interactive)
  (end-of-line) ; move to end of line
  (set-mark (line-beginning-position)))
(global-set-key (kbd "C-M-l") 'select-current-line)

(setq version-control t)
(setq kept-new-versions 3)
(setq delete-old-versions t)
(setq kept-old-versions 2)
(setq dired-kept-versions 1)

(setq user-full-name "Leo Guo")
(setq user-mail-address "lkahtz@gmail.com")

(setq outline-minor-mode-prefix [(control o)])

; loads ruby mode when a .rb file is opened.
(autoload 'ruby-mode "ruby-mode" "Major mode for editing ruby scripts." t)
(setq auto-mode-alist  (cons '(".rb$" . ruby-mode) auto-mode-alist))
(setq auto-mode-alist  (cons '(".rhtml$" . html-mode) auto-mode-alist))
(global-font-lock-mode 1)
(recentf-mode 1)

(set-language-environment "utf-8")
(add-to-list 'load-path "~/slime/")
(add-to-list 'load-path "/usr/local/share/emacs/site-lisp")
(add-to-list 'load-path "~/.emacs.d/vendor")

(require 'slime)
(global-set-key (kbd "C-c q") 'slime-close-all-parens-in-sexp)
(global-set-key (kbd "M-s") 'save-buffer)

(setq muse-project-alist
      '(("merryhackingwiki"
         ("~/wiki/" :default "index")
         (:base "html" :path "~/wiki/publish"))))

(when (fboundp 'winner-mode)
  (winner-mode)
  (windmove-default-keybindings))


; sort ido filelist by mtime instead of alphabetically
(ido-mode t)
(setq ido-enable-prefix nil
      ido-enable-flex-matching t
      ido-create-new-buffer 'always
      ido-use-filename-at-point t
      ido-max-prospects 10)
(add-hook 'ido-make-file-list-hook 'ido-sort-mtime)
(add-hook 'ido-make-dir-list-hook 'ido-sort-mtime)
(defun ido-sort-mtime ()
  (setq ido-temp-list
	(sort ido-temp-list 
	      (lambda (a b)
		(let ((ta (nth 5 (file-attributes (concat ido-current-directory a))))
		      (tb (nth 5 (file-attributes (concat ido-current-directory b)))))
		  (if (= (nth 0 ta) (nth 0 tb))
		      (> (nth 1 ta) (nth 1 tb))
		    (> (nth 0 ta) (nth 0 tb)))))))
  (ido-to-end ;; move . files to end (again)
   (delq nil (mapcar
	      (lambda (x) (if (string-equal (substring x 0 1) ".") x))
	      ido-temp-list))))
 

(set-default 'indent-tabs-mode nil)
(defalias 'yes-or-no-p 'y-or-n-p)

(defun goto-match-paren (arg)
  "Go to the matching  if on (){}[], similar to vi style of % "
  (interactive "p")
  ;; first, check for "outside of bracket" positions expected by forward-sexp, etc.
  (cond ((looking-at "[\[\(\{]") (forward-sexp))
        ((looking-back "[\]\)\}]" 1) (backward-sexp))
        ;; now, try to succeed from inside of a bracket
        ((looking-at "[\]\)\}]") (forward-char) (backward-sexp))
        ((looking-back "[\[\(\{]" 1) (backward-char) (forward-sexp))
        (t nil)))
(global-set-key (kbd "C-}")  'goto-match-paren)

(defun backward-up-sexp (arg)
  (interactive "p")
  (let ((ppss (syntax-ppss)))
    (cond ((elt ppss 3)
           (goto-char (elt ppss 8))
           (backward-up-sexp (1- arg)))
          ((backward-up-list arg)))))
(global-set-key [remap backward-up-list] 'backward-up-sexp)

;;mode-compile
(require 'mode-compile)
(autoload 'mode-compile "mode-compile"
  "Command to compile current buffer file based on the major mode" t)
(global-set-key "\C-cc" 'mode-compile)
(autoload 'mode-compile-kill "mode-compile"
  "Command to kill a compilation launched by 'mode-compile'" t)

(global-set-key "\C-ck" 'mode-compile-kill)

(add-to-list 'load-path "~/.emacs.d/vendor/textmate.el")
(require 'textmate)
(add-to-list 'load-path "~/.emacs.d/vendor/zenburn-emacs")

;;(require 'color-theme-zenburn)
;;(color-theme-zenburn)

(add-hook 'ruby-mode-hook (lambda() (linum-mode 1)(textmate-mode 1) ))

(defun describe-last-function() 
  (interactive) 
  (describe-function last-command))

(global-set-key [(control z)] 'undo)
(global-set-key [(control _)] 'eval-region)
(global-set-key [(super w)] 'ido-kill-buffer)

(put 'dired-find-alternate-file 'disabled nil)

(defun enclose-with-tag-lines (b e tag)
  "'tag' every line in the region with a tag"
  (interactive "r\nMTag for line: ")
  (save-restriction
    (narrow-to-region b e)
    (save-excursion
      (goto-char (point-min))
      (while (< (point) (point-max))
        (beginning-of-line)
        (insert (format "<%s>" tag))
        (end-of-line)
        (insert (format "</%s>" tag))
        (forward-line 1)))))

(defun enclose-with-tag-region (b e tag)
  "'tag' a region"
  (interactive "r\nMTag for region: ")
  (save-excursion
    (goto-char e)
    (insert (format "</%s>" tag))
    (goto-char b)
    (insert (format "<%s>" tag))))

 (defun transpose-windows (arg)
   "Transpose the buffers shown in two windows."
   (interactive "p")
   (let ((selector (if (>= arg 0) 'next-window 'previous-window)))
     (while (/= arg 0)
       (let ((this-win (window-buffer))
             (next-win (window-buffer (funcall selector))))
         (set-window-buffer (selected-window) next-win)
         (set-window-buffer (funcall selector) this-win)
         (select-window (funcall selector)))
       (setq arg (if (plusp arg) (1- arg) (1+ arg))))))

 (define-key ctl-x-4-map (kbd "t") 'transpose-windows)

;; system specific 
(when (eq system-type 'darwin)
  ;; Work around a bug on OS X where system-name is FQDN
  (setq system-name (car (split-string system-name "\\."))))

(defun copy-line (&optional arg)
 "Save current line into Kill-Ring without mark the line"
 (interactive "P")
 (let ((beg (line-beginning-position)) 
	(end (line-end-position arg)))
 (copy-region-as-kill beg end))
)
(global-set-key (kbd "\C-cl") 'copy-line)

(defun copy-word (&optional arg)
 "Copy words at point"
 (interactive "P")
 (let ((beg (progn (if (looking-back "[a-zA-Z0-9]" 1) (backward-word 1)) (point))) 
	(end (progn (forward-word arg) (point))))
 (copy-region-as-kill beg end))
)

(defun copy-paragraph (&optional arg)
  "Copy paragraphes at point"
  (interactive "P")
  (let ((beg (progn (backward-paragraph 1) (point))) 
	(end (progn (forward-paragraph arg) (point))))
    (copy-region-as-kill beg end)))
  
(defun yank-with-newline ()
  "Yank, appending a newline if the yanked text doesn't end with one."
  (yank)
  (when (not (string-match "\n$" (current-kill 0)))
    (newline-and-indent)))

(defun yank-as-line-above ()
  "Yank text as a new line above the current line.

Also moves point to the beginning of the text you just yanked."
  (interactive)
  (let ((lnum (line-number-at-pos (point))))
    (beginning-of-line)
    (yank-with-newline)
    (goto-line lnum)))

(defun yank-as-line-below ()
  "Yank text as a new line below the current line.

Also moves point to the beginning of the text you just yanked."
  (interactive)
  (let* ((lnum (line-number-at-pos (point)))
         (lnum (g) (not (bolp)))
        (newline-and-indent)
      (forward-line 1))
    (yank-with-newline)
    (goto-line lnum)))

(put 'upcase-region 'disabled nil)

(if window-system
    (scroll-bar-mode 0)
    (tool-bar-mode 0))

(defun my-mark-word (N)
  (interactive "p")
  (if (and 
       (not (eq last-command this-command))
       (not (eq last-command 'my-mark-word-backward)))
      (set-mark (point)))
  (forward-word N))

(defun my-mark-word-backward (N)
  (interactive "p")
  (if (and
       (not (eq last-command this-command))
       (not (eq last-command 'my-mark-word)))
      (set-mark (point)))
  (backward-word N))

(defun kill-start-of-line ()
  "kill from point to start of line"
  (interactive)
  (kill-line 0)
  )

(defun textmate-next-line ()
  "Inserts an indented newline after the current line and moves the point to it."
  (interactive)
  (end-of-line)
  (newline-and-indent))
(global-set-key (kbd "M-RET") 'textmate-next-line)

(global-set-key (kbd "\C-c RET") 'cua-mode)
 	
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)

(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)

(add-hook 'LaTeX-mode-hook 'turn-on-reftex)
(setq reftex-plug-into-AUCTeX t)
(setq TeX-PDF-mode t)

(require 'magit)
(custom-set-variables
 '(magit-git-executable "/usr/local/bin/git")
 '(truncate-partial-width-windows nil))
(global-set-key (kbd "\C-xg") 'magit-status)

(global-hl-line-mode 0)

(setq truncate-partial-width-windows t)


(defun eshell-maybe-bol ()
  (interactive)
  (let ((p (point)))
    (eshell-bol)
    (if (= p (point))
        (beginning-of-line))))
(add-hook 'eshell-mode-hook
          '(lambda () (define-key eshell-mode-map "\C-a" 'eshell-maybe-bol)))

(global-set-key "\C-cy" '(lambda ()
   (interactive)
   (popup-menu 'yank-menu)))

;; fix indenting for "if" forms in Lisp
(put 'if 'lisp-indent-function nil)

(require 'erc)
(blink-cursor-mode 0)
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

(defun x-selection-value (type)
  (let ((data-types '(public.file-url
                       public.utf16-plain-text
                       com.apple.traditional-mac-plain-text))
    text)
    (while (and (null text) data-types)
      (setq text (condition-case nil
             (x-get-selection type (car data-types))
           (error nil)))
      (setq data-types (cdr data-types)))
    (if text
    (remove-text-properties 0 (length text) '(foreign-selection nil)
text))
    text))

(add-hook 'shell-mode-hook
          (lambda ()
            (local-set-key (kbd "M-k") 'erase-buffer)))

(add-hook 'text-mode-hook
          (lambda ()
            (local-set-key (kbd "M-s") 'save-buffer)
            (longlines-mode)))

(setq ansi-color-names-vector ; better contrast colors
      ["black" "red4" "green4" "yellow4"
       "blue3" "magenta4" "cyan4" "white"])
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(add-hook 'shell-mode-hook 
     '(lambda () (toggle-truncate-lines 1)))

(require 'erc)
(erc-autojoin-mode t)
(setq erc-autojoin-channels-alist
  '((".*\\.freenode.net" "#emacs" "#clojure" "#chicken")
     (".*\\.gimp.org" "#unix" "#gtk+")))

(defun srb-adaptive-indent (beg end)
"Indent the region between BEG and END with adaptive filling."
(goto-char beg)
(while
(let ((lbp (line-beginning-position))
(lep (line-end-position)))
(put-text-property lbp lep 'wrap-prefix (fill-context-prefix lbp lep))
(search-forward "\n" end t))))

(define-minor-mode srb-adaptive-wrap-mode
  "Wrap the buffer text with adaptive filling."
  :lighter ""
  (save-excursion
    (save-restriction
      (widen)
      (let ((buffer-undo-list t)
            (inhibit-read-only t)
            (mod (buffer-modified-p)))
        (if srb-adaptive-wrap-mode
            (progn
              (setq word-wrap t)
              (unless (member '(continuation) fringe-indicator-alist)
                (push '(continuation) fringe-indicator-alist))
              (jit-lock-register 'srb-adaptive-indent))
            (jit-lock-unregister 'srb-adaptive-indent)
            (remove-text-properties (point-min) (point-max) '(wrap-prefix pref))
            (setq fringe-indicator-alist
                  (delete '(continuation) fringe-indicator-alist))
            (setq word-wrap nil))
        (restore-buffer-modified-p mod)))))

(add-to-list 'load-path "~/.emacs.d/vendor/coffee-mode")
(require 'coffee-mode)
(add-to-list 'auto-mode-alist '("\\.coffee$" . coffee-mode))
(add-to-list 'auto-mode-alist '("Cakefile" . coffee-mode))

(require 'textmate)
(textmate-mode t)

(defun replace-matching-parens-to-brackets ()  (interactive)  
  (save-excursion
    (let((end-point (point)))
      (backward-list)      
      (let((start-point (point)))        
        (goto-char end-point)        
        (re-search-backward ")"nil t)        
        (replace-match "\]"nil nil)        
        (goto-char start-point)        
        (re-search-forward "("nil t)        
        (replace-match "\["nil nil)))))

(defun replace-matching-parens-to-curly-brakcets ()  (interactive)  
  (save-excursion
    (let((end-point (point)))
      (backward-list)      
      (let((start-point (point)))        
        (goto-char end-point)        
        (re-search-backward ")"nil t)        
        (replace-match "\}"nil nil)        
        (goto-char start-point)        
        (re-search-forward "("nil t)        
        (replace-match "\{"nil nil)))))

(global-set-key "\C-x]" 'replace-matching-parens-to-brackets)
(global-set-key "\C-x}" 'replace-matching-parens-to-curly-brakcets)
(define-key input-decode-map "\e\eOA" [(meta up)])
(define-key input-decode-map "\e\eOB" [(meta down)])
(global-set-key [(meta up)] 'backward-paragraph)
(global-set-key [(meta down)] 'forward-paragraph)
(global-set-key "\M-p" 'backward-paragraph)
(global-set-key "\M-n" 'forward-paragraph)

;;(require 'maxframe)
;;(add-hook 'window-setup-hook 'maximize-frame t)

(global-set-key [s-return] 'textmate-next-line)
(require 'doc-view)

(add-to-list 'load-path "~/.emacs.d/site-lisp/tuareg-mode")
(autoload 'tuareg-mode "tuareg" "Major mode for editing Caml code" t)
(autoload 'camldebug "camldebug" "Run the Caml debugger" t)
(autoload 'tuareg-imenu-set-imenu "tuareg-imenu" 
  "Configuration of imenu for tuareg" t) 
(add-hook 'tuareg-mode-hook 'tuareg-imenu-set-imenu)
(setq auto-mode-alist 
      (append '(("\\.ml[ily]?$" . tuareg-mode)
                ("\\.topml$" . tuareg-mode))
              auto-mode-alist))

(add-hook 'tuareg-mode-hook 'imenu-add-menubar-index)
(autoload 'tuareg-imenu-set-imenu "tuareg-imenu" "Configuration of imenu for tuareg" t)
(add-hook 'tuareg-mode-hook 'tuareg-imenu-set-imenu)
(put 'erase-buffer 'disabled nil)
