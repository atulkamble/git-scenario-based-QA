# Git Fundamentals - Complete Study Notes

## 📚 Table of Contents
1. [Git Basics](#git-basics)
2. [Repository Structure](#repository-structure)
3. [Working Areas](#working-areas)
4. [Branching Concepts](#branching-concepts)
5. [Merging Strategies](#merging-strategies)
6. [Remote Operations](#remote-operations)
7. [Advanced Concepts](#advanced-concepts)
8. [Best Practices](#best-practices)

---

## Git Basics

### What is Git?
Git is a **distributed version control system** that tracks changes in files and coordinates work among multiple people. Key characteristics:

- **Distributed**: Every clone is a full backup
- **Fast**: Local operations are lightning quick
- **Secure**: Uses SHA-1 hashing for integrity
- **Flexible**: Supports various workflows

### Git vs Other VCS
| Feature | Git | SVN | Mercurial |
|---------|-----|-----|-----------|
| Type | Distributed | Centralized | Distributed |
| Speed | Very Fast | Moderate | Fast |
| Branching | Excellent | Limited | Good |
| Learning Curve | Steep | Moderate | Moderate |

### Core Concepts

#### 1. Repository (Repo)
A directory containing your project files and Git metadata (.git folder).

```bash
# Initialize a new repository
git init
# or clone an existing one
git clone <url>
```

#### 2. Commit
A snapshot of your project at a specific point in time.

```bash
# Create a commit
git add .
git commit -m "Meaningful commit message"
```

#### 3. Branch
A lightweight movable pointer to a specific commit.

```bash
# Create and switch to branch
git checkout -b feature-branch
# Modern way (Git 2.23+)
git switch -c feature-branch
```

---

## Repository Structure

### .git Directory
```
.git/
├── HEAD              # Points to current branch
├── config            # Repository configuration
├── objects/          # All content (commits, trees, blobs)
├── refs/             # Branch and tag references
│   ├── heads/        # Local branches
│   └── remotes/      # Remote branches
├── hooks/            # Git hooks (scripts)
└── index             # Staging area
```

### Object Types

#### 1. Blob (Binary Large Object)
Stores file content (without filename or metadata).

#### 2. Tree
Represents a directory listing (filenames + blob references).

#### 3. Commit
Points to a tree and contains metadata (author, message, timestamp).

#### 4. Tag
A reference to a specific commit (annotated tags include metadata).

### SHA-1 Hashing
Every Git object is identified by a unique 40-character SHA-1 hash.

```bash
# View object type and content
git cat-file -t <sha1>    # Type
git cat-file -p <sha1>    # Content
```

---

## Working Areas

### The Three Areas

#### 1. Working Directory
Your actual files - what you see and edit.

#### 2. Staging Area (Index)
A preparation area for your next commit.

#### 3. Repository (.git directory)
Where Git stores metadata and object database.

### File States

```
Untracked → (git add) → Staged → (git commit) → Committed
    ↑                               ↓
    ← (git rm --cached) ← Modified ← (edit files)
```

#### File Lifecycle
- **Untracked**: New files Git doesn't know about
- **Staged**: Files marked for next commit
- **Modified**: Changed files in working directory
- **Committed**: Files safely stored in repository

### Commands for Each Area

```bash
# Working Directory → Staging
git add <file>
git add .                 # All files
git add -A               # All including deleted
git add -u               # Only modified/deleted

# Staging → Repository
git commit -m "message"
git commit -am "message" # Add + commit (tracked files)

# Check status
git status
git status --short       # Compact view
```

---

## Branching Concepts

### What are Branches?
Branches are lightweight movable pointers to commits. They enable:
- **Parallel development**
- **Feature isolation**
- **Experimental changes**
- **Release management**

### Branch Types

#### 1. Main Branches
- **main/master**: Production-ready code
- **develop**: Integration branch for features

#### 2. Supporting Branches
- **feature/***: New features
- **release/***: Release preparation
- **hotfix/***: Critical production fixes

### Branching Commands

```bash
# List branches
git branch              # Local branches
git branch -r           # Remote branches
git branch -a           # All branches

# Create branch
git branch <name>       # Create
git checkout -b <name>  # Create and switch
git switch -c <name>    # Modern way

# Switch branches
git checkout <branch>   # Traditional
git switch <branch>     # Modern way

# Delete branches
git branch -d <branch>  # Safe delete (merged only)
git branch -D <branch>  # Force delete
```

### HEAD Pointer
HEAD points to the current branch (or commit in detached state).

```bash
# View HEAD
cat .git/HEAD

# Detached HEAD (dangerous state)
git checkout <commit-hash>

# Return to branch
git checkout <branch-name>
```

---

## Merging Strategies

### Types of Merges

#### 1. Fast-Forward Merge
When target branch hasn't diverged from source branch.

```
Before:
A---B---C main
         \
          D---E feature

After fast-forward:
A---B---C---D---E main, feature
```

#### 2. Three-Way Merge
When both branches have new commits.

```
Before:
A---B---C---F main
     \
      D---E feature

After merge:
A---B---C---F---G main
     \         /
      D---E---/ feature
```

#### 3. Squash Merge
Combines all feature commits into a single commit.

```bash
git merge --squash feature-branch
git commit -m "Add complete feature"
```

### Merge vs Rebase

#### Merge
- **Preserves history**: Shows actual development timeline
- **Non-destructive**: Doesn't change existing commits
- **Creates merge commits**: Can clutter history

```bash
git checkout main
git merge feature-branch
```

#### Rebase
- **Linear history**: Creates clean, straight-line history
- **Rewrites commits**: Changes commit hashes
- **No merge commits**: Cleaner log

```bash
git checkout feature-branch
git rebase main
```

### When to Use Each

| Scenario | Recommendation |
|----------|----------------|
| Feature integration | Merge |
| Updating feature branch | Rebase |
| Public/shared branches | Merge (never rebase) |
| Local cleanup | Rebase |

---

## Remote Operations

### Understanding Remotes
Remotes are references to other repositories (usually on servers).

```bash
# List remotes
git remote -v

# Add remote
git remote add origin <url>

# Remove remote
git remote remove <name>

# Rename remote
git remote rename old-name new-name
```

### Fetch vs Pull

#### git fetch
Downloads changes but doesn't merge them.

```bash
git fetch origin        # Fetch all branches
git fetch origin main   # Fetch specific branch
```

#### git pull
Fetch + merge in one command.

```bash
git pull origin main    # Fetch and merge
git pull --rebase       # Fetch and rebase
```

### Push Operations

```bash
# Push to remote
git push origin main

# Push new branch
git push -u origin feature-branch  # Set upstream

# Force push (dangerous!)
git push --force
git push --force-with-lease        # Safer option
```

### Tracking Branches
Local branches that track remote branches.

```bash
# Set upstream
git branch --set-upstream-to=origin/main main

# Push and set upstream
git push -u origin feature-branch

# View tracking relationships
git branch -vv
```

---

## Advanced Concepts

### Git Hooks
Scripts that run automatically on certain Git events.

#### Client-side Hooks
- **pre-commit**: Before commit is created
- **prepare-commit-msg**: Before commit message editor
- **commit-msg**: Validate commit message
- **post-commit**: After commit is created

#### Server-side Hooks
- **pre-receive**: Before any references are updated
- **update**: Before each branch is updated
- **post-receive**: After all references are updated

#### Example Hook
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check for debugging statements
if git diff --cached --name-only | xargs grep -l "console.log" 2>/dev/null; then
    echo "Error: Debugging statements found!"
    exit 1
fi
```

### Git Aliases
Shortcuts for common commands.

```bash
# Set aliases
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit

# Complex aliases
git config --global alias.lg "log --oneline --graph --decorate --all"
```

### Reflog
A log of where HEAD has been.

```bash
# View reflog
git reflog

# Recover lost commits
git checkout <reflog-hash>
git branch recovery-branch
```

### Submodules
Include other Git repositories as subdirectories.

```bash
# Add submodule
git submodule add <url> <path>

# Initialize and update
git submodule init
git submodule update

# Clone with submodules
git clone --recursive <url>
```

---

## Best Practices

### Commit Messages
Follow the conventional format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation
- **style**: Formatting
- **refactor**: Code restructuring
- **test**: Adding tests
- **chore**: Maintenance

#### Examples
```
feat(auth): add OAuth2 login integration

- Implement Google OAuth2 flow
- Add user session management
- Update login UI components

Closes #123
```

### Branching Strategy

#### Git Flow
```
main          # Production releases
develop       # Integration branch
feature/*     # New features
release/*     # Release preparation  
hotfix/*      # Production fixes
```

#### GitHub Flow (Simplified)
```
main          # Always deployable
feature/*     # Short-lived feature branches
```

### .gitignore Best Practices

```bash
# OS files
.DS_Store
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp

# Dependencies
node_modules/
vendor/

# Build artifacts
dist/
build/
*.log

# Environment files
.env
.env.local
```

### Security Considerations

#### Never Commit
- Passwords or API keys
- Personal information
- Large binary files
- Temporary files

#### Use Git LFS
For large files (>100MB):

```bash
git lfs install
git lfs track "*.zip"
git add .gitattributes
```

### Performance Tips

#### Large Repositories
```bash
# Shallow clone
git clone --depth 1 <url>

# Partial clone
git clone --filter=blob:none <url>

# Sparse checkout
git config core.sparseCheckout true
echo "path/to/include" > .git/info/sparse-checkout
git read-tree -m -u HEAD
```

#### Repository Maintenance
```bash
# Garbage collection
git gc --aggressive

# Prune unreachable objects
git prune

# Check repository integrity
git fsck
```

---

## Troubleshooting Common Issues

### Detached HEAD
```bash
# Create branch from detached HEAD
git checkout -b new-branch-name

# Or return to branch
git checkout main
```

### Merge Conflicts
```bash
# View conflicted files
git status

# Resolve conflicts manually, then
git add <resolved-file>
git commit
```

### Undo Changes
```bash
# Unstage file
git reset HEAD <file>

# Discard working directory changes
git checkout -- <file>

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1
```

### Lost Commits
```bash
# Find lost commits
git reflog

# Recover commit
git checkout <commit-hash>
git branch recovery <commit-hash>
```

---

## Git Configuration

### Levels of Configuration
1. **System**: All users (`/etc/gitconfig`)
2. **Global**: Current user (`~/.gitconfig`)
3. **Local**: Current repository (`.git/config`)

### Essential Configuration
```bash
# Identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Default branch
git config --global init.defaultBranch main

# Editor
git config --global core.editor "code --wait"

# Merge tool
git config --global merge.tool vimdiff

# Auto CRLF (Windows)
git config --global core.autocrlf true

# Auto CRLF (Mac/Linux)
git config --global core.autocrlf input
```

### Useful Aliases
```bash
git config --global alias.st "status --short --branch"
git config --global alias.lg "log --oneline --graph --decorate --all"
git config --global alias.last "log -1 HEAD"
git config --global alias.unstage "reset HEAD --"
git config --global alias.visual "!gitk"
```

---

## Study Tips

### Practice Commands Daily
```bash
# Basic workflow
git status → git add → git commit → git push

# Branch workflow  
git checkout -b → work → git add → git commit → git push → PR

# Update workflow
git fetch → git merge/rebase → resolve conflicts
```

### Use Visual Tools
- **gitk**: Built-in Git GUI
- **Git Extensions**: Windows GUI
- **SourceTree**: Cross-platform GUI
- **GitKraken**: Modern Git client

### Learn Incrementally
1. **Week 1**: Basic commands (add, commit, push, pull)
2. **Week 2**: Branching and merging
3. **Week 3**: Conflict resolution
4. **Week 4**: Advanced features (rebase, cherry-pick)
5. **Week 5**: Team workflows and best practices

Remember: Git is powerful but complex. Focus on understanding concepts, not just memorizing commands! 🎓