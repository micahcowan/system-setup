;; Settings that are automatically loaded by Emacs's Viper mode.

(setq viper-inhibit-startup-message 't)
(setq viper-expert-level '5)
(setq viper-want-ctl-h-help t)

(viper-record-kbd-macro "gg" 'vi-state [\1 G] 't)

(setq viper-shift-width 4) ; don't touch or else...

(viper-record-kbd-macro [(control \6)] 'vi-state [(control ^)] 't)

(viper-record-kbd-macro "u" 'vi-state [(control x) u] 't)

(viper-record-kbd-macro [(control \[)] 'vi-state [(control z) (control \[) q (control z)] 't)

(viper-record-kbd-macro "gqap" 'vi-state [(control z) (control \[) q (control z)] 't)

(viper-record-kbd-macro "zz" 'vi-state [z \.] 't)

(viper-record-kbd-macro "zt" 'vi-state [z (control m)] 't)

(viper-record-kbd-macro "zb" 'vi-state [z -] 't)

(viper-record-kbd-macro "==" 'vi-state [= |] 't)

;; vim: set ft=lisp :
