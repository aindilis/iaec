(if (file-exists-p "/var/lib/myfrdcsa/sandbox/mizarmode-20141121/mizarmode-20141121/mizar.el")
 (progn
  (add-to-list 'load-path "/var/lib/myfrdcsa/sandbox/mizarmode-20141121/mizarmode-20141121")
  (require 'mizar)
  (add-to-list 'auto-mode-alist '("\\.miz$" . mizar-mode))
  ))

(if (file-exists-p "/usr/share/acl2-6.5")
 (progn
  (add-to-list 'auto-mode-alist '("\\.miz$" . mizar-mode))
  (setq *acl2-sources-dir* "/usr/share/acl2-6.5/")
  (load "/usr/share/acl2-6.5/emacs/emacs-acl2.el")
  (define-key acl2-doc-mode-map "an" 'academician-declare-page-of-document-read)))

(defun acl2-doc-go! (&optional arg)
 "Go to the topic occurring at the cursor position."
 (interactive "P")
 (if arg
  (let ((name (acl2-doc-topic-at-point)))
   (cond (name (acl2-doc-display name))
    (t (error "Cursor is not on a name"))))
  (let ((name1 (acl2-doc-topic-at-point))
	(name2 
	 (intern
	  (upcase
	   (bbdb-replace-regexp-in-string "\\([^a-zA-Z0-9]+\\)" "_" 
	    (save-excursion
	     (search-backward "[")
	     (forward-char 1)
	     (set-mark (point))
	     (search-forward "]")
	     (backward-char 1)
	     (buffer-substring-no-properties (mark) (point))
	     ))))))
   (condition-case nil
    (acl2-doc-display name2)
    (error 
     (condition-case nil
      (acl2-doc-index name2)
      (error 
       (condition-case nil
	(acl2-doc-display name1)
	(error
	 (condition-case nil
	  (acl2-doc-index name1)
	  (error )))))))))))
