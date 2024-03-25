# Jujutsushi
## An Emacs UI to jujutsu


# Pro Tips

## Teach vc to recognize jujutsu projects

```elisp
(use-package project
  :custom (project-vc-extra-root-markers '(".jj"))
```
