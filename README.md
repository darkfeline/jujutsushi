# Jujutsushi
## An Emacs UI to jujutsu

Also provide `vc-jujutsushi`. This buys us project.el support try the 'vc'
project type.

# Pro Tips

## Teach vc to recognize jujutsu projects

```elisp
(use-package project
  :custom (project-vc-extra-root-markers '(".jj"))
```
