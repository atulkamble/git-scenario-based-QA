# Git Command Cheat Sheet

## 🚀 Quick Navigation
- [Setup & Configuration](#setup--configuration)
- [Repository Basics](#repository-basics)
- [Branching & Merging](#branching--merging)
- [Remote Operations](#remote-operations)
- [History & Inspection](#history--inspection)
- [Undoing Changes](#undoing-changes)
- [Advanced Operations](#advanced-operations)
- [Troubleshooting](#troubleshooting)

---

## Setup & Configuration

### First-time Git setup
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
git config --global core.editor "code --wait"  # VS Code as editor
```

### Useful global configs
```bash
git config --global core.autocrlf true         # Windows
git config --global core.autocrlf input        # Mac/Linux
git config --global pull.rebase false          # Merge on pull
git config --global push.default simple        # Simple push strategy
```

### View configuration
```bash
git config --list                              # All settings
git config user.name                           # Specific setting
git config --global --edit                     # Edit global config
```

---

## Repository Basics

### Initialize & Clone
```bash
git init                                       # Initialize new repo
git init --bare                                # Bare repository
git clone <url>                               # Clone repository
git clone <url> <directory>                   # Clone to specific directory
git clone --depth 1 <url>                    # Shallow clone (latest commit only)
```

### Basic workflow
```bash
git status                                     # Check repository status
git add <file>                                # Stage specific file
git add .                                     # Stage all changes
git add -A                                    # Stage all (including deleted)
git add -u                                    # Stage modified files only
git commit -m "message"                       # Commit with message
git commit -am "message"                      # Add and commit (tracked files)
git commit --amend                            # Modify last commit
```

---

## Branching & Merging

### Branch operations
```bash
git branch                                     # List local branches
git branch -a                                 # List all branches
git branch -r                                 # List remote branches
git branch <name>                             # Create new branch
git checkout <branch>                         # Switch to branch
git checkout -b <branch>                      # Create and switch to branch
git switch <branch>                           # Switch branch (Git 2.23+)
git switch -c <branch>                        # Create and switch (Git 2.23+)
```

### Merging
```bash
git merge <branch>                            # Merge branch into current
git merge --no-ff <branch>                    # Force merge commit
git merge --squash <branch>                   # Squash merge
git merge --abort                             # Abort merge in progress
```

### Branch cleanup
```bash
git branch -d <branch>                        # Delete merged branch
git branch -D <branch>                        # Force delete branch
git push origin --delete <branch>             # Delete remote branch
git remote prune origin                       # Remove stale remote references
```

---

## Remote Operations

### Remote management
```bash
git remote                                     # List remotes
git remote -v                                 # List remotes with URLs
git remote add <name> <url>                   # Add remote
git remote remove <name>                      # Remove remote
git remote rename <old> <new>                 # Rename remote
git remote set-url <name> <url>               # Change remote URL
```

### Fetch, Pull, Push
```bash
git fetch                                      # Fetch all remotes
git fetch <remote>                            # Fetch specific remote
git fetch <remote> <branch>                   # Fetch specific branch
git pull                                      # Fetch and merge current branch
git pull <remote> <branch>                    # Pull specific branch
git pull --rebase                             # Pull with rebase instead of merge
git push                                      # Push current branch
git push <remote> <branch>                    # Push specific branch
git push -u <remote> <branch>                 # Push and set upstream
git push --force-with-lease                   # Safer force push
```

---

## History & Inspection

### Viewing history
```bash
git log                                       # Full commit history
git log --oneline                             # Compact history
git log --graph                               # Show branch graph
git log --graph --oneline --all               # Visual branch history
git log -p                                    # Show patch/diff
git log --stat                                # Show file statistics
git log --since="2 weeks ago"                 # Time-based filtering
git log --author="Name"                       # Filter by author
git log --grep="keyword"                      # Search commit messages
git log <file>                                # History of specific file
```

### Viewing changes
```bash
git diff                                      # Unstaged changes
git diff --staged                             # Staged changes
git diff --cached                             # Same as --staged
git diff HEAD                                 # All changes since last commit
git diff <branch1>..<branch2>                 # Diff between branches
git diff <commit1>..<commit2>                 # Diff between commits
git show                                      # Show last commit
git show <commit>                             # Show specific commit
git show <commit>:<file>                      # Show file at specific commit
```

### File history & blame
```bash
git log --follow <file>                       # Follow file through renames
git blame <file>                              # Show who changed each line
git annotate <file>                           # Alternative to blame
```

---

## Undoing Changes

### Working directory changes
```bash
git checkout -- <file>                       # Discard changes to file
git restore <file>                            # Discard changes (Git 2.23+)
git checkout .                                # Discard all changes
git restore .                                 # Discard all changes (Git 2.23+)
git clean -f                                  # Remove untracked files
git clean -fd                                 # Remove untracked files & directories
git clean -n                                  # Dry run (show what would be removed)
```

### Staging area changes
```bash
git reset <file>                              # Unstage file
git restore --staged <file>                   # Unstage file (Git 2.23+)
git reset                                     # Unstage all files
```

### Commit-level changes
```bash
git reset --soft HEAD~1                      # Undo commit, keep changes staged
git reset --mixed HEAD~1                     # Undo commit, unstage changes
git reset --hard HEAD~1                      # Undo commit, discard changes
git revert <commit>                           # Create new commit that undoes changes
git revert HEAD                               # Revert last commit
git revert --no-commit <commit>               # Revert without auto-commit
```

---

## Advanced Operations

### Stashing
```bash
git stash                                     # Stash current changes
git stash save "message"                      # Stash with message
git stash list                                # List all stashes
git stash show                                # Show latest stash changes
git stash show stash@{n}                      # Show specific stash
git stash pop                                 # Apply and remove latest stash
git stash apply                               # Apply latest stash (keep in list)
git stash apply stash@{n}                     # Apply specific stash
git stash drop                                # Delete latest stash
git stash drop stash@{n}                      # Delete specific stash
git stash clear                               # Delete all stashes
```

### Rebasing
```bash
git rebase <branch>                           # Rebase current branch onto branch
git rebase -i HEAD~n                          # Interactive rebase last n commits
git rebase --continue                         # Continue after resolving conflicts
git rebase --abort                            # Abort rebase
git rebase --skip                             # Skip current commit during rebase
```

### Cherry-picking
```bash
git cherry-pick <commit>                      # Apply specific commit
git cherry-pick <commit1>..<commit2>          # Apply range of commits
git cherry-pick --no-commit <commit>          # Apply without committing
git cherry-pick --continue                    # Continue after resolving conflicts
git cherry-pick --abort                       # Abort cherry-pick
```

### Tagging
```bash
git tag                                       # List all tags
git tag <tagname>                             # Create lightweight tag
git tag -a <tagname> -m "message"             # Create annotated tag
git tag -a <tagname> <commit>                 # Tag specific commit
git push origin <tagname>                     # Push specific tag
git push origin --tags                        # Push all tags
git tag -d <tagname>                          # Delete local tag
git push origin --delete <tagname>            # Delete remote tag
```

---

## Submodules

### Basic submodule operations
```bash
git submodule add <url> <path>                # Add submodule
git submodule init                            # Initialize submodules
git submodule update                          # Update submodules
git submodule update --init --recursive       # Init and update recursively
git clone --recursive <url>                   # Clone with submodules
git submodule foreach 'git pull origin main'  # Update all submodules
```

---

## Search & Filter

### Searching
```bash
git grep "pattern"                            # Search in tracked files
git grep "pattern" <commit>                   # Search in specific commit
git log -S "string"                           # Find commits that add/remove string
git log -G "regex"                            # Find commits that match regex
git log --all --grep="pattern"                # Search commit messages
```

### Filtering
```bash
git log --since="2023-01-01"                  # Commits since date
git log --until="2023-12-31"                  # Commits until date
git log --author="John"                       # Commits by author
git log --committer="Jane"                    # Commits by committer
git log --no-merges                           # Exclude merge commits
git log --merges                              # Only merge commits
```

---

## Troubleshooting

### Common fixes
```bash
git reflog                                    # View reference log
git fsck                                      # Check repository integrity
git gc                                        # Garbage collection
git gc --aggressive                           # Aggressive garbage collection
git count-objects -v                          # Repository statistics
```

### Conflict resolution
```bash
git status                                    # See conflicted files
git diff                                      # View conflict markers
git mergetool                                 # Launch merge tool
git add <file>                                # Mark conflict as resolved
git commit                                    # Complete merge
```

### Recovery
```bash
git reflog                                    # Find lost commits
git checkout <commit>                         # Checkout lost commit
git branch <name> <commit>                    # Create branch from lost commit
git fsck --lost-found                         # Find dangling commits
```

---

## Git Aliases (Add to ~/.gitconfig)

```ini
[alias]
    # Status and logs
    st = status --short --branch
    lg = log --oneline --graph --decorate --all
    last = log -1 HEAD
    
    # Branching
    co = checkout
    br = branch
    sw = switch
    
    # Committing
    ci = commit
    ca = commit --amend
    cm = commit -m
    
    # Diffing
    df = diff
    dc = diff --cached
    
    # Undoing
    unstage = reset HEAD --
    undo = reset --soft HEAD~1
    
    # Remote
    pushf = push --force-with-lease
    
    # Utilities
    tree = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
    aliases = config --get-regexp alias
```

---

## Environment Variables

```bash
export GIT_EDITOR="code --wait"               # Set default editor
export GIT_MERGE_TOOL="meld"                  # Set merge tool
export GIT_PAGER="less -R"                    # Set pager
```

---

## Tips & Best Practices

### Commit messages
- Use imperative mood ("Add feature" not "Added feature")
- Keep first line under 50 characters
- Separate subject from body with blank line
- Use body to explain what and why, not how

### Branching strategy
- `main/master`: Production-ready code
- `develop`: Integration branch
- `feature/*`: Feature development
- `hotfix/*`: Production fixes
- `release/*`: Release preparation

### Workflow tips
- Commit early and often
- Write meaningful commit messages
- Use branches for features
- Keep commits atomic (one logical change)
- Review changes before committing
- Use `.gitignore` appropriately