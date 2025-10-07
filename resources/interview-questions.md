# Git Interview Questions & Scenarios

## 📋 Table of Contents
1. [Basic Git Questions](#basic-git-questions)
2. [Branching and Merging](#branching-and-merging)
3. [Conflict Resolution](#conflict-resolution)
4. [Advanced Scenarios](#advanced-scenarios)
5. [Best Practices](#best-practices)
6. [Command Line Scenarios](#command-line-scenarios)

---

## Basic Git Questions

### Q1: What's the difference between `git pull` and `git fetch`?

**Answer:**
- `git fetch` downloads changes from remote repository but doesn't merge them
- `git pull` = `git fetch` + `git merge` (downloads and merges in one command)

**Example:**
```bash
# Fetch only (safe operation)
git fetch origin main

# Check what was fetched
git log HEAD..origin/main --oneline

# Then merge manually
git merge origin/main

# vs. Pull (fetch + merge)
git pull origin main
```

### Q2: How do you undo the last commit?

**Answer depends on scenario:**

```bash
# Undo commit, keep changes staged
git reset --soft HEAD~1

# Undo commit, keep changes unstaged
git reset --mixed HEAD~1  # or just git reset HEAD~1

# Undo commit, discard changes completely
git reset --hard HEAD~1

# Create new commit that undoes changes (safe for shared repos)
git revert HEAD
```

### Q3: What's the difference between `git rebase` and `git merge`?

**Answer:**
- **Merge**: Creates a merge commit, preserves history structure
- **Rebase**: Replays commits on top of target branch, creates linear history

**Visual Example:**
```
Before:
A---B---C feature
   /
D---E---F main

After merge:
A---B---C---G feature
   /       /
D---E---F--- main

After rebase:
D---E---F---A'---B'---C' feature
         main
```

---

## Branching and Merging

### Q4: You're working on a feature branch. Suddenly, you need to switch to fix an urgent bug on main. What do you do?

**Answer:**
```bash
# Option 1: Stash changes
git stash save "WIP: feature in progress"
git checkout main
git checkout -b hotfix/urgent-bug
# ... make fixes ...
git checkout main
git merge hotfix/urgent-bug
git checkout feature-branch
git stash pop

# Option 2: Commit WIP
git add .
git commit -m "WIP: partial feature implementation"
git checkout main
# ... fix bug ...
git checkout feature-branch
git reset --soft HEAD~1  # undo WIP commit
```

### Q5: How do you rename a branch that's already pushed to remote?

**Answer:**
```bash
# Rename local branch
git branch -m old-name new-name

# Delete old remote branch
git push origin --delete old-name

# Push new branch
git push origin new-name

# Set upstream for new branch
git push --set-upstream origin new-name
```

---

## Conflict Resolution

### Q6: During a merge, you encounter conflicts. Walk through the resolution process.

**Answer:**
```bash
# 1. Attempt merge
git merge feature-branch
# Auto-merging file.txt
# CONFLICT (content): Merge conflict in file.txt

# 2. Check status
git status
# Shows conflicted files

# 3. View conflict markers in file
cat file.txt
# <<<<<<< HEAD
# Current branch content
# =======
# Feature branch content
# >>>>>>> feature-branch

# 4. Resolve manually or with tools
git mergetool  # Opens merge tool
# OR edit manually to resolve conflicts

# 5. Mark as resolved
git add file.txt

# 6. Complete merge
git commit  # Uses default merge message or edit
```

### Q7: You started a merge but want to abort it. How?

**Answer:**
```bash
# Abort merge and return to pre-merge state
git merge --abort

# Alternative: reset to HEAD
git reset --hard HEAD
```

---

## Advanced Scenarios

### Q8: You accidentally committed sensitive data (API key). How do you remove it from history?

**Answer:**
```bash
# For recent commits (not pushed)
git reset --hard HEAD~1  # Remove last commit
git filter-branch --index-filter 'git rm --cached --ignore-unmatch secrets.txt' HEAD

# For commits already pushed (use with caution)
git filter-branch --force --index-filter \
    'git rm --cached --ignore-unmatch secrets.txt' \
    --prune-empty --tag-name-filter cat -- --all

# Clean up
rm -rf .git/refs/original/
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push (dangerous!)
git push --force-with-lease
```

### Q9: How do you find which commit introduced a bug?

**Answer:**
```bash
# Using git bisect
git bisect start
git bisect bad                    # Current commit is bad
git bisect good v1.0             # Known good commit/tag

# Git will checkout middle commit
# Test and mark as good or bad
git bisect good   # or git bisect bad

# Repeat until bug is found
git bisect reset  # Return to original state

# Alternative: Search in commit messages
git log --grep="bug\|fix" --oneline

# Search in code changes
git log -S "function_name" --oneline
```

### Q10: How do you apply a specific commit from another branch?

**Answer:**
```bash
# Cherry-pick specific commit
git cherry-pick <commit-hash>

# Cherry-pick multiple commits
git cherry-pick <hash1> <hash2> <hash3>

# Cherry-pick a range
git cherry-pick <start-hash>..<end-hash>

# Cherry-pick without committing (review first)
git cherry-pick --no-commit <commit-hash>
```

---

## Command Line Scenarios

### Scenario A: Fix Commit Message

**Problem:** Last commit has typo in message
```bash
# If not pushed yet
git commit --amend -m "Correct commit message"

# If already pushed (use carefully)
git commit --amend -m "Correct commit message"
git push --force-with-lease
```

### Scenario B: Split Large Commit

**Problem:** One commit contains multiple unrelated changes
```bash
# Reset to before the commit but keep changes
git reset --soft HEAD~1

# Stage and commit changes separately
git add file1.txt
git commit -m "Feature A: Add authentication"

git add file2.txt file3.txt
git commit -m "Feature B: Update UI components"
```

### Scenario C: Merge vs Rebase Decision

**When to merge:**
- Feature branches into main
- Want to preserve exact history
- Working on shared/public branches

**When to rebase:**
- Updating feature branch with latest main
- Cleaning up local commits before sharing
- Want linear history

```bash
# Rebase example: Update feature with latest main
git checkout feature-branch
git rebase main

# Interactive rebase: Clean up commits
git rebase -i HEAD~3
```

---

## Best Practices Q&A

### Q11: What makes a good commit message?

**Answer:**
```
Format: <type>(<scope>): <subject>

<body>

<footer>
```

**Examples:**
```
feat(auth): add OAuth2 login integration

- Implement Google OAuth2 flow
- Add user session management
- Update login UI components

Closes #123
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### Q12: How do you handle large files in Git?

**Answer:**
```bash
# Use Git LFS (Large File Storage)
git lfs install
git lfs track "*.psd"
git lfs track "*.zip"
git add .gitattributes
git commit -m "Configure Git LFS"

# Check LFS files
git lfs ls-files

# Alternative: Keep large files out of repo
echo "*.zip" >> .gitignore
echo "dist/" >> .gitignore
```

### Q13: How do you set up a Git workflow for a team?

**Answer: Git Flow Example**
```bash
# Main branches
main        # Production-ready code
develop     # Integration branch

# Supporting branches
feature/*   # New features
release/*   # Release preparation
hotfix/*    # Production fixes

# Workflow commands
git flow init
git flow feature start new-feature
git flow feature finish new-feature
git flow release start 1.0.0
git flow release finish 1.0.0
```

---

## Troubleshooting Common Issues

### Issue 1: "Your branch is ahead of origin/main by X commits"
```bash
# Option 1: Push commits
git push origin main

# Option 2: Reset to remote state
git reset --hard origin/main
```

### Issue 2: "Please commit your changes or stash them"
```bash
# Option 1: Stash
git stash
git checkout other-branch
git stash pop

# Option 2: Commit
git add .
git commit -m "WIP: temporary commit"
```

### Issue 3: Detached HEAD state
```bash
# Create new branch from detached HEAD
git checkout -b new-branch-name

# Or return to main branch
git checkout main
```

---

## Quick Reference Commands

```bash
# Status and info
git status              # Repository status
git log --oneline      # Commit history
git diff               # Unstaged changes
git diff --cached      # Staged changes

# Branching
git branch             # List branches
git checkout -b name   # Create and switch
git merge branch       # Merge branch
git branch -d name     # Delete branch

# Remote operations
git fetch              # Download changes
git pull               # Fetch and merge
git push               # Upload changes
git remote -v          # List remotes

# Undoing changes
git checkout -- file   # Discard file changes
git reset HEAD file    # Unstage file
git commit --amend     # Modify last commit
git revert commit      # Create undo commit

# Advanced
git stash              # Save work temporarily
git cherry-pick hash   # Apply specific commit
git rebase -i HEAD~n   # Interactive rebase
git bisect start       # Find bug introduction
```