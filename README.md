# Jujutsushi
## An Emacs UI to jujutsu

Also provide `vc-jujutsushi`. This buys us project.el support try the 'vc'
project type.

# Setup

Until the time when vc-jj.el is ready for being included upstream, we need to
teach project.el that how to detect jujutsu projects using the #'try-vc
strategy.

```elisp
(add-to-list 'project-vc-backend-markers-alist '(jj . ".jj"))
```

# Pro Tips

## Teach vc to recognize jujutsu projects

```elisp
(use-package project
  :custom (project-vc-extra-root-markers '(".jj"))
```
