# Git for Windows

Playground with git for Windows.

## Cheatsheet

* [Create Repository](#create-repository): Different ways to create a repository
* [Local Changes](#local-changes): Modify snapshots of local changes
* [Git Branch](#git-branch): Switch to different branches

### Create Repository

Clone repository
```
clone git@github.com:glego/PSGlego.git
```

Init repository
```
git init
```

More:
* https://git-scm.com/docs/git-init
* https://git-scm.com/docs/git-clone

### Local Changes

Add all current changes into next commit
```
git add .
```

Commit with message
```
git commit -m "Update getting started documentation"
```
> Commit according to the [git commit guideline](https://chris.beams.io/posts/git-commit/) e.g.: If applied, this commit will ... update getting started documentation 

View changed files
```
git status
```

More:
* https://git-scm.com/docs/git-add
* https://git-scm.com/docs/git-commit

### Git Branch

Create a new branch
```
git branch dev
```

Switch branch
```
git checkout dev
```

Delete local branch
```
git branch -d dev
```

Mark the current commit with a tag
```
git tag release-1.2.1
```

More:
* https://git-scm.com/docs/git-branch


### Undo

Undo all local changes
```
git reset --hard HEAD
```

Undo last commit
```
git reset HEAD~
```


