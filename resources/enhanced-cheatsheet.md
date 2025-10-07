# Ultimate Git Cheat Sheet - Complete Reference

## 🎯 Quick Navigation
- [Setup & Configuration](#setup--configuration)
- [Repository Operations](#repository-operations)
- [File Operations](#file-operations)
- [Branching & Merging](#branching--merging)
- [Remote Operations](#remote-operations)
- [History & Inspection](#history--inspection)
- [Undoing Changes](#undoing-changes)
- [Advanced Operations](#advanced-operations)
- [Troubleshooting](#troubleshooting)
- [Git Aliases](#git-aliases)
- [Best Practices](#best-practices)

---

## Setup & Configuration

### Initial Setup (First Time)
```bash
# Set identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Set default editor
git config --global core.editor "code --wait"    # VS Code
git config --global core.editor "vim"            # Vim
git config --global core.editor "nano"           # Nano

# Set merge tool
git config --global merge.tool vimdiff
git config --global merge.tool meld
git config --global merge.tool vscode
```

### Configuration Levels
```bash
git config --system     # System-wide (/etc/gitconfig)
git config --global     # User-specific (~/.gitconfig)
git config --local      # Repository-specific (.git/config)

# View configuration
git config --list                    # All settings
git config --list --show-origin     # With file locations
git config user.name                # Specific setting
git config --global --edit          # Edit global config
```

### Platform-Specific Settings
```bash
# Windows
git config --global core.autocrlf true
git config --global core.filemode false

# macOS/Linux
git config --global core.autocrlf input

# Performance settings
git config --global core.preloadindex true
git config --global core.fscache true
git config --global gc.auto 256
```

---

## Repository Operations

### Creating Repositories
```bash
# Initialize new repository
git init
git init --bare                     # Bare repository (no working directory)
git init --separate-git-dir=/path   # Git directory elsewhere

# Clone repository
git clone <url>
git clone <url> <directory>         # Clone to specific directory
git clone --depth 1 <url>           # Shallow clone (latest commit only)
git clone --branch <branch> <url>   # Clone specific branch
git clone --recursive <url>         # Clone with submodules
git clone --bare <url>              # Clone as bare repository
```

### Repository Information
```bash
# Repository status
git status                          # Full status
git status -s                       # Short status
git status --porcelain             # Machine-readable status

# Repository information
git remote -v                       # List remotes with URLs
git branch -a                       # All branches (local + remote)
git tag                            # List tags
git log --oneline -10              # Recent commits
```

---

## File Operations

### Adding Files
```bash
# Add specific files
git add <file>                      # Single file
git add <file1> <file2>            # Multiple files
git add *.js                       # Wildcard pattern
git add .                          # All files in current directory
git add -A                         # All files (including deleted)
git add -u                         # Only modified/deleted (not new)

# Interactive adding
git add -i                         # Interactive mode
git add -p                         # Patch mode (select hunks)
git add -p <file>                  # Patch mode for specific file
```

### Removing Files
```bash
# Remove from working directory and index
git rm <file>
git rm -r <directory>              # Remove directory recursively
git rm --cached <file>             # Remove from index only
git rm -f <file>                   # Force remove

# Remove all deleted files from index
git ls-files --deleted -z | xargs -0 git rm
```

### Moving/Renaming Files
```bash
git mv <old-name> <new-name>       # Rename file
git mv <file> <directory>/         # Move file to directory
```

### File Status and Differences
```bash
# Show changes
git diff                           # Unstaged changes
git diff --staged                  # Staged changes
git diff --cached                  # Same as --staged
git diff HEAD                      # All changes since last commit
git diff <branch1>..<branch2>      # Between branches
git diff <commit1>..<commit2>      # Between commits
git diff --name-only               # Only file names
git diff --stat                    # Statistics
git diff --word-diff               # Word-level diff

# Specific file differences
git diff <file>                    # Unstaged changes in file
git diff --staged <file>           # Staged changes in file
git diff <commit> <file>           # File changes since commit
```

---

## Branching & Merging

### Branch Management
```bash
# List branches
git branch                         # Local branches
git branch -r                      # Remote branches
git branch -a                      # All branches
git branch -v                      # With last commit
git branch -vv                     # With tracking info

# Create branches
git branch <branch-name>           # Create branch
git checkout -b <branch-name>      # Create and switch
git switch -c <branch-name>        # Modern create and switch
git checkout -b <branch> <start-point>  # Create from specific commit/branch

# Switch branches
git checkout <branch>              # Traditional switch
git switch <branch>                # Modern switch (Git 2.23+)
git checkout -                     # Switch to previous branch
git switch -                       # Modern switch to previous

# Delete branches
git branch -d <branch>             # Delete merged branch
git branch -D <branch>             # Force delete branch
git push origin --delete <branch>  # Delete remote branch
```

### Merging
```bash
# Basic merging
git merge <branch>                 # Merge branch into current
git merge --no-ff <branch>         # Force merge commit
git merge --squash <branch>        # Squash merge
git merge --abort                  # Abort merge in progress
git merge --continue               # Continue after resolving conflicts

# Merge strategies
git merge -s ours <branch>         # Use our version entirely
git merge -s theirs <branch>       # Use their version entirely
git merge -X ours <branch>         # Prefer our version for conflicts
git merge -X theirs <branch>       # Prefer their version for conflicts
```

### Rebasing
```bash
# Basic rebasing
git rebase <branch>                # Rebase current branch onto branch
git rebase <upstream> <branch>     # Rebase branch onto upstream
git rebase --continue              # Continue after resolving conflicts
git rebase --abort                 # Abort rebase
git rebase --skip                  # Skip current commit

# Interactive rebase
git rebase -i HEAD~5               # Interactive rebase last 5 commits
git rebase -i <commit>             # Interactive rebase from commit

# Rebase options
git rebase --onto <new-base> <old-base> <branch>  # Advanced rebasing
git rebase -p                      # Preserve merges (deprecated)
git rebase --rebase-merges         # Modern preserve merges
```

---

## Remote Operations

### Remote Management
```bash
# List remotes
git remote                         # List remote names
git remote -v                      # List with URLs
git remote show <remote>           # Detailed remote info

# Add/modify remotes
git remote add <name> <url>        # Add remote
git remote rename <old> <new>      # Rename remote
git remote remove <name>           # Remove remote
git remote set-url <name> <url>    # Change remote URL

# Multiple remotes example
git remote add origin <your-fork>
git remote add upstream <original-repo>
```

### Fetching and Pulling
```bash
# Fetch (download without merging)
git fetch                          # Fetch all remotes
git fetch <remote>                 # Fetch specific remote
git fetch <remote> <branch>        # Fetch specific branch
git fetch --all                    # Fetch all remotes
git fetch --prune                  # Remove deleted remote branches
git fetch --tags                   # Fetch all tags

# Pull (fetch + merge)
git pull                           # Pull current branch
git pull <remote> <branch>         # Pull specific branch
git pull --rebase                  # Pull with rebase instead of merge
git pull --ff-only                 # Only fast-forward pulls
git pull --no-commit               # Pull without auto-commit
```

### Pushing
```bash
# Basic pushing
git push                           # Push current branch
git push <remote> <branch>         # Push specific branch
git push -u <remote> <branch>      # Push and set upstream
git push --set-upstream <remote> <branch>  # Same as -u

# Advanced pushing
git push --all                     # Push all branches
git push --tags                    # Push all tags
git push <remote> --delete <branch>  # Delete remote branch
git push --force                   # Force push (dangerous!)
git push --force-with-lease        # Safer force push
git push --dry-run                 # Show what would be pushed
```

### Tracking Branches
```bash
# Set upstream tracking
git branch -u <remote>/<branch>    # Set upstream for current branch
git branch --set-upstream-to=<remote>/<branch>  # Same as above
git checkout -b <branch> <remote>/<branch>  # Create tracking branch

# View tracking relationships
git branch -vv                     # Show tracking info
git status -b                      # Show tracking in status
```

---

## History & Inspection

### Viewing History
```bash
# Basic log
git log                            # Full log
git log --oneline                  # Compact one-line format
git log --graph                    # Show branch graph
git log --decorate                 # Show refs (branches, tags)
git log --all                      # All branches
git log -n 10                      # Limit to 10 commits
git log --since="2 weeks ago"      # Time-based filtering
git log --until="2023-12-31"       # Until specific date

# Advanced log formatting
git log --pretty=format:"%h %an %ar %s"  # Custom format
git log --stat                     # Show file change statistics
git log --shortstat                # Abbreviated stat
git log -p                         # Show patches (diffs)
git log --name-only                # Show only changed file names
git log --name-status              # Show file names with status

# Graphical representations
git log --oneline --graph --decorate --all
git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'
```

### Filtering History
```bash
# Filter by author/committer
git log --author="John Doe"        # Filter by author
git log --committer="Jane Smith"   # Filter by committer
git log --grep="fix bug"           # Search commit messages
git log -S "function_name"         # Search for code changes
git log -G "regex_pattern"         # Search with regex

# Filter by file/path
git log -- <file>                  # History of specific file
git log --follow -- <file>         # Follow file through renames
git log -- <directory>             # History of directory

# Filter by merge commits
git log --merges                   # Only merge commits
git log --no-merges                # Exclude merge commits
git log --first-parent             # Follow only main branch
```

### Viewing Specific Commits
```bash
# Show commit details
git show                           # Show last commit
git show <commit>                  # Show specific commit
git show <commit>:<file>           # Show file at specific commit
git show --name-only <commit>      # Show only changed files
git show --stat <commit>           # Show change statistics

# Show ranges
git show <commit1>..<commit2>      # Show range of commits
git show <branch1>..<branch2>      # Show commits in branch2 not in branch1
```

### File History and Blame
```bash
# File history
git log --follow -p -- <file>      # Complete file history with diffs
git log --oneline -- <file>        # Compact file history

# Blame (who changed what)
git blame <file>                   # Show who changed each line
git blame -L 10,20 <file>          # Blame specific lines
git blame -w <file>                # Ignore whitespace changes
git blame -M <file>                # Detect moved lines
git blame -C <file>                # Detect copied lines

# Find when code was added/removed
git log -S "function_name" --source --all
git log -G "regex" --source --all
```

---

## Undoing Changes

### Working Directory Changes
```bash
# Discard changes in working directory
git checkout -- <file>             # Discard changes to file
git restore <file>                 # Modern way (Git 2.23+)
git checkout .                     # Discard all changes
git restore .                      # Modern discard all

# Remove untracked files
git clean -f                       # Remove untracked files
git clean -fd                      # Remove untracked files and directories
git clean -n                       # Dry run (show what would be removed)
git clean -i                       # Interactive clean
```

### Staging Area Changes
```bash
# Unstage files
git reset <file>                   # Unstage specific file
git restore --staged <file>        # Modern unstage (Git 2.23+)
git reset                          # Unstage all files
```

### Commit-Level Changes
```bash
# Modify last commit
git commit --amend                 # Modify last commit message
git commit --amend --no-edit       # Add changes to last commit
git commit --amend --author="Name <email>"  # Change author

# Reset commits
git reset --soft HEAD~1            # Undo commit, keep changes staged
git reset --mixed HEAD~1           # Undo commit, unstage changes
git reset --hard HEAD~1            # Undo commit, discard all changes
git reset --hard <commit>          # Reset to specific commit

# Create reverse commits
git revert <commit>                # Create commit that undoes changes
git revert HEAD                    # Revert last commit
git revert --no-commit <commit>    # Revert without auto-commit
git revert <commit1>..<commit2>    # Revert range of commits
```

### Recovery
```bash
# Find lost commits
git reflog                         # Show reference log
git reflog --all                   # Show all reference logs
git fsck --lost-found              # Find dangling commits

# Recover from reflog
git checkout <reflog-entry>        # Checkout lost commit
git branch recovery <reflog-entry> # Create branch from lost commit
```

---

## Advanced Operations

### Stashing
```bash
# Save stash
git stash                          # Stash current changes
git stash save "message"           # Stash with message
git stash push -m "message"        # Modern stash with message
git stash -u                       # Include untracked files
git stash -a                       # Include all files (even ignored)

# Manage stashes
git stash list                     # List all stashes
git stash show                     # Show latest stash changes
git stash show stash@{2}           # Show specific stash
git stash show -p                  # Show stash with diff

# Apply stashes
git stash pop                      # Apply and remove latest stash
git stash apply                    # Apply latest stash (keep in list)
git stash apply stash@{2}          # Apply specific stash
git stash drop                     # Delete latest stash
git stash drop stash@{2}           # Delete specific stash
git stash clear                    # Delete all stashes

# Partial stashing
git stash -p                       # Interactively choose what to stash
git stash push -- <file>           # Stash specific files
```

### Cherry-picking
```bash
# Basic cherry-pick
git cherry-pick <commit>           # Apply specific commit
git cherry-pick <commit1> <commit2>  # Apply multiple commits
git cherry-pick <commit1>..<commit2>  # Apply range of commits

# Cherry-pick options
git cherry-pick --no-commit <commit>  # Apply without committing
git cherry-pick -x <commit>        # Add "cherry picked from" message
git cherry-pick --continue         # Continue after resolving conflicts
git cherry-pick --abort            # Abort cherry-pick
git cherry-pick --skip             # Skip current commit
```

### Tagging
```bash
# Create tags
git tag <tag-name>                 # Lightweight tag
git tag -a <tag-name> -m "message"  # Annotated tag
git tag -a <tag-name> <commit>     # Tag specific commit

# List tags
git tag                            # List all tags
git tag -l "v1.*"                  # List tags matching pattern
git show <tag-name>                # Show tag information

# Delete tags
git tag -d <tag-name>              # Delete local tag
git push origin --delete <tag-name>  # Delete remote tag

# Push tags
git push origin <tag-name>         # Push specific tag
git push origin --tags             # Push all tags
git push --follow-tags             # Push commits and reachable tags
```

### Submodules
```bash
# Add submodule
git submodule add <url> <path>     # Add submodule
git submodule add -b <branch> <url> <path>  # Add with specific branch

# Initialize and update
git submodule init                 # Initialize submodules
git submodule update               # Update submodules
git submodule update --init        # Initialize and update
git submodule update --recursive   # Update recursively
git submodule update --remote      # Update to remote HEAD

# Clone with submodules
git clone --recursive <url>        # Clone with submodules

# Submodule operations
git submodule foreach 'git pull origin main'  # Command in all submodules
git submodule status               # Show submodule status
```

### Worktrees
```bash
# Create worktree
git worktree add <path> <branch>   # Create worktree for branch
git worktree add <path> -b <new-branch>  # Create worktree with new branch

# Manage worktrees
git worktree list                  # List all worktrees
git worktree remove <path>         # Remove worktree
git worktree prune                 # Clean up deleted worktrees
```

---

## Troubleshooting

### Common Issues
```bash
# Detached HEAD
git checkout <branch-name>         # Return to branch
git checkout -b <new-branch>       # Create branch from detached HEAD

# Merge conflicts
git status                         # See conflicted files
git diff                          # View conflict markers
git mergetool                     # Launch merge tool
git add <resolved-file>           # Mark as resolved
git commit                        # Complete merge

# Corrupted repository
git fsck                          # Check repository integrity
git fsck --full                   # Full integrity check
git gc                           # Garbage collection
git gc --aggressive              # Aggressive cleanup
```

### Repository Analysis
```bash
# Repository statistics
git count-objects -v              # Object count and size
du -sh .git                       # Repository size
git rev-list --count --all        # Total commit count

# Find large objects
git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | sed -n 's/^blob //p' | sort --numeric-sort --key=2 | tail -20

# Verify repository
git fsck --full --strict          # Strict integrity check
git verify-pack -v .git/objects/pack/*.idx  # Verify pack files
```

---

## Git Aliases

### Essential Aliases
Add these to your `~/.gitconfig`:

```ini
[alias]
    # Status and info
    st = status --short --branch
    s = status
    
    # Logging
    lg = log --oneline --graph --decorate --all
    ll = log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat
    ld = log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=relative
    ls = log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate
    last = log -1 HEAD
    
    # Branching
    co = checkout
    br = branch
    sw = switch
    
    # Committing
    ci = commit
    cm = commit -m
    ca = commit --amend
    can = commit --amend --no-edit
    
    # Diffing
    df = diff
    dc = diff --cached
    dt = difftool
    
    # Merging and rebasing
    mg = merge --no-ff
    rb = rebase
    rbi = rebase -i
    
    # Remote operations
    f = fetch
    fa = fetch --all
    p = push
    pf = push --force-with-lease
    pu = push -u origin
    
    # Undoing
    unstage = reset HEAD --
    undo = reset --soft HEAD~1
    undohard = reset --hard HEAD~1
    
    # Stashing
    ss = stash save
    sp = stash pop
    sl = stash list
    
    # Utilities
    aliases = config --get-regexp alias
    remotes = remote -v
    tree = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
    visual = !gitk
    
    # Advanced
    find = "!git ls-files | grep -i"
    grep = grep -Ii
    gra = "!f() { A=$(pwd) && TOPLEVEL=$(git rev-parse --show-toplevel) && cd $TOPLEVEL && git grep --full-name -In $1 | xargs -I{} echo $TOPLEVEL/{} && cd $A; }; f"
```

---

## Best Practices

### Commit Guidelines
```bash
# Commit message format
<type>(<scope>): <subject>

<body>

<footer>

# Types: feat, fix, docs, style, refactor, test, chore
# Example:
feat(auth): add OAuth2 login integration

- Implement Google OAuth2 flow
- Add user session management  
- Update login UI components

Closes #123
```

### Branching Strategy
```bash
# Feature branch workflow
git checkout main
git pull origin main
git checkout -b feature/user-authentication
# ... work on feature ...
git push -u origin feature/user-authentication
# ... create pull request ...
git checkout main
git pull origin main
git branch -d feature/user-authentication
```

### .gitignore Best Practices
```bash
# Operating System
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# Dependencies
node_modules/
vendor/
bower_components/

# Build outputs
dist/
build/
*.log
*.tmp

# Environment
.env
.env.local
.env.*.local

# Language specific
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
*.class
target/
```

Remember: Practice these commands in a safe environment first! 🚀