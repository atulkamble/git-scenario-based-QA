# Intermediate Git Scenarios

## Scenario 1: Resolving Merge Conflicts

### Question
You're working on a team project. Both you and your colleague modified the same file. When you try to merge, you encounter a conflict. How do you resolve it?

### Setup Script
```bash
#!/bin/bash
# Create conflict scenario
git init conflict-demo
cd conflict-demo

echo "# Project Title" > README.md
git add README.md
git commit -m "Initial commit"

# Create branch A
git checkout -b feature-a
echo "# Project Title
## Description
This is an awesome project for learning Git." > README.md
git add README.md
git commit -m "Add description in feature-a"

# Create branch B
git checkout main
git checkout -b feature-b
echo "# Project Title
## Overview
This project demonstrates Git workflows." > README.md
git add README.md
git commit -m "Add overview in feature-b"

# Return to main and merge (will cause conflict)
git checkout main
git merge feature-a  # This merges successfully
git merge feature-b  # This will cause conflict
```

### Step-by-Step Resolution

1. **Identify the conflict**
```bash
git status
```

2. **View the conflicted file**
```bash
cat README.md
```
You'll see:
```
# Project Title
<<<<<<< HEAD
## Description
This is an awesome project for learning Git.
=======
## Overview
This project demonstrates Git workflows.
>>>>>>> feature-b
```

3. **Resolve the conflict manually**
```bash
# Edit README.md to resolve conflict
cat > README.md << EOF
# Project Title

## Description
This is an awesome project for learning Git.

## Overview
This project demonstrates Git workflows and conflict resolution.
EOF
```

4. **Mark conflict as resolved**
```bash
git add README.md
```

5. **Complete the merge**
```bash
git commit -m "Resolve merge conflict between feature-a and feature-b"
```

6. **Verify the resolution**
```bash
git log --oneline --graph
```

---

## Scenario 2: Interactive Rebase

### Question
You have multiple commits in your feature branch, but some commit messages are unclear and you want to clean up the history before merging.

### Setup
```bash
git checkout -b feature/cleanup-demo
echo "file1 content" > file1.txt
git add file1.txt
git commit -m "add file1"

echo "file2 content" > file2.txt
git add file2.txt
git commit -m "file2"

echo "updated content" > file1.txt
git add file1.txt
git commit -m "fix typo"

echo "more file2 content" >> file2.txt
git add file2.txt
git commit -m "update file2 with more content"
```

### Interactive Rebase Solution

1. **Start interactive rebase**
```bash
git rebase -i HEAD~4
```

2. **In the editor, change the commits:**
```
pick a1b2c3d add file1
reword e4f5g6h file2
squash h7i8j9k fix typo
pick k0l1m2n update file2 with more content
```

3. **Reword commit message when prompted:**
```
Add file2.txt with initial content
```

4. **Write squash commit message:**
```
Add file1.txt with content

- Initial file creation
- Fixed typo in content
```

5. **Verify the cleaned history**
```bash
git log --oneline
```

---

## Scenario 3: Stashing Work in Progress

### Question
You're in the middle of implementing a feature when an urgent bug needs to be fixed. You need to temporarily save your work and switch contexts.

### Step-by-Step Solution

1. **Start working on a feature**
```bash
git checkout -b feature/user-profile
echo "User profile form" > profile.html
echo "profile styles" > profile.css
git add profile.html
# Don't commit yet - work in progress
```

2. **Urgent bug report comes in**
```bash
# Check current status
git status
```

3. **Stash the work**
```bash
git stash save "WIP: user profile form and styles"
```

4. **Switch to fix the bug**
```bash
git checkout main
git checkout -b hotfix/urgent-bug
echo "Bug fix implemented" > bugfix.txt
git add bugfix.txt
git commit -m "Fix urgent security bug"
```

5. **Merge hotfix**
```bash
git checkout main
git merge hotfix/urgent-bug
git branch -d hotfix/urgent-bug
```

6. **Return to feature work**
```bash
git checkout feature/user-profile
git stash list
git stash pop
```

7. **Continue working**
```bash
git add profile.css
git commit -m "Add user profile form and styles"
```

---

## Scenario 4: Cherry-picking Commits

### Question
You have a specific commit from another branch that you need in your current branch, but you don't want to merge the entire branch.

### Step-by-Step Solution

1. **Setup scenario**
```bash
git checkout main
git checkout -b feature/experimental
echo "experimental feature" > experiment.txt
git add experiment.txt
git commit -m "Add experimental feature"

echo "useful utility function" > utils.js
git add utils.js
git commit -m "Add useful utility function"

echo "more experimental stuff" >> experiment.txt
git add experiment.txt
git commit -m "More experimental work"
```

2. **Switch to main and cherry-pick the utility function**
```bash
git checkout main
git log feature/experimental --oneline
# Note the commit hash for "Add useful utility function"
```

3. **Cherry-pick the specific commit**
```bash
git cherry-pick <commit-hash>
```

4. **Verify the cherry-pick**
```bash
git log --oneline
ls -la  # Should show utils.js but not experiment.txt
```

---

## Scenario 5: Undoing Changes

### Question
You made some commits that you need to undo. Demonstrate different ways to undo changes based on different scenarios.

### Scenario 5a: Undo Last Commit (Keep Changes)
```bash
# Make a commit you want to undo
echo "wrong content" > mistake.txt
git add mistake.txt
git commit -m "This commit was a mistake"

# Undo the commit but keep changes
git reset --soft HEAD~1
git status  # Changes are staged
```

### Scenario 5b: Undo Last Commit (Discard Changes)
```bash
# Make another commit
git commit -m "Another mistake"

# Undo commit and discard changes
git reset --hard HEAD~1
```

### Scenario 5c: Revert a Commit (Safe for shared repositories)
```bash
# Create a commit to revert
echo "problematic feature" > problem.txt
git add problem.txt
git commit -m "Add problematic feature"

# Create a revert commit
git revert HEAD
```

### Scenario 5d: Undo Staged Changes
```bash
echo "unstaged content" > file.txt
git add file.txt
# Undo staging
git reset HEAD file.txt
```

### Scenario 5e: Discard Working Directory Changes
```bash
echo "unwanted changes" >> file.txt
# Discard changes
git checkout -- file.txt
# or
git restore file.txt
```

---

## Practice Scripts

### Conflict Simulation Script
```bash
#!/bin/bash
# simulate-conflict.sh

repo_name="conflict-practice"
rm -rf "$repo_name"
mkdir "$repo_name"
cd "$repo_name"

git init
echo "# $repo_name" > README.md
git add README.md
git commit -m "Initial commit"

# Create conflicting branches
git checkout -b branch-a
echo "Change from branch A" >> README.md
git add README.md
git commit -m "Change from branch A"

git checkout main
git checkout -b branch-b
echo "Change from branch B" >> README.md
git add README.md
git commit -m "Change from branch B"

# Setup for conflict
git checkout main
git merge branch-a
echo "Now run: git merge branch-b"
echo "This will create a conflict for you to resolve!"
```

### Rebase Practice Script
```bash
#!/bin/bash
# rebase-practice.sh

git checkout -b rebase-practice
for i in {1..5}; do
    echo "Content $i" > "file$i.txt"
    git add "file$i.txt"
    git commit -m "commit $i"
done

echo "Created 5 commits. Practice with:"
echo "git rebase -i HEAD~5"
```

### Useful Commands for Intermediate Users
```bash
# Conflict resolution
git status                          # See conflicted files
git diff                           # See conflict markers
git add <resolved-file>            # Mark as resolved
git commit                         # Complete merge

# Rebase operations
git rebase -i HEAD~n               # Interactive rebase last n commits
git rebase --continue              # Continue after resolving conflicts
git rebase --abort                 # Cancel rebase

# Stash operations
git stash                          # Stash current changes
git stash list                     # List all stashes
git stash pop                      # Apply and remove last stash
git stash apply                    # Apply without removing

# Cherry-pick
git cherry-pick <commit-hash>      # Apply specific commit
git cherry-pick --no-commit <hash> # Apply without committing

# Undoing changes
git reset --soft HEAD~1            # Undo commit, keep changes staged
git reset --mixed HEAD~1           # Undo commit, unstage changes
git reset --hard HEAD~1            # Undo commit, discard changes
git revert HEAD                    # Create new commit that undoes last commit
```