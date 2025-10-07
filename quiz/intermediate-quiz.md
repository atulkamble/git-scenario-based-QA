# Git Quiz - Intermediate Level

## 🎯 Instructions
- These questions test deeper Git concepts and workflows
- Focus on understanding when and why to use specific commands
- Practice conflict resolution and advanced operations
- Simulate these scenarios in a safe test environment

---

## Quiz Questions

### Question 1: Merge vs Rebase
**Scenario:** You have a feature branch that diverged from main 5 commits ago. Main has 3 new commits since then.

**Question:** What's the difference between merging and rebasing your feature branch?

<details>
<summary>Click for Answer</summary>

**Answer:** 

**Merge creates:**
```
A---B---C---F---G main
     \           /
      D---E-----/  feature (merge commit G)
```

**Rebase creates:**
```
A---B---C---F---D'---E' main, feature (linear history)
```

**Key differences:**
- **Merge**: Preserves actual development history, creates merge commit
- **Rebase**: Creates linear history, rewrites commits (new hashes)

**When to use:**
- **Merge**: Integrating completed features, shared/public branches
- **Rebase**: Updating feature branch, cleaning local history

**Commands:**
```bash
# Merge
git checkout main
git merge feature-branch

# Rebase  
git checkout feature-branch
git rebase main
```
</details>

---

### Question 2: Conflict Resolution
**Scenario:** During a merge, you encounter this conflict in `config.js`:

```javascript
<<<<<<< HEAD
const API_URL = 'https://api.production.com';
=======
const API_URL = 'https://api.staging.com';
>>>>>>> feature-branch
```

**Question:** What do these conflict markers mean and how do you resolve them?

<details>
<summary>Click for Answer</summary>

**Answer:**

**Conflict markers explanation:**
- `<<<<<<< HEAD`: Start of current branch (main) version
- `=======`: Separator between versions
- `>>>>>>> feature-branch`: End of merging branch version

**Resolution steps:**
1. **Choose the correct version** (or combine both)
2. **Remove conflict markers**
3. **Save the file**
4. **Stage the resolved file**
5. **Complete the merge**

**Example resolution:**
```javascript
// Choose production URL for main branch
const API_URL = 'https://api.production.com';
```

**Commands:**
```bash
# Edit file to resolve conflict
nano config.js

# Stage resolved file
git add config.js

# Complete merge
git commit
```

**Pro tip:** Use `git mergetool` to open a visual merge tool!
</details>

---

### Question 3: Interactive Rebase
**Scenario:** Your feature branch has these commits:
1. `Add user model`
2. `Fix typo in user model`  
3. `Add user controller`
4. `Fix typo in controller`
5. `Add tests`

**Question:** How would you clean up this history before merging?

<details>
<summary>Click for Answer</summary>

**Answer:** Use interactive rebase to squash the typo fixes:

```bash
git rebase -i HEAD~5
```

**In the editor, change:**
```
pick a1b2c3d Add user model
pick e4f5g6h Fix typo in user model
pick h7i8j9k Add user controller  
pick k0l1m2n Fix typo in controller
pick n3o4p5q Add tests
```

**To:**
```
pick a1b2c3d Add user model
fixup e4f5g6h Fix typo in user model
pick h7i8j9k Add user controller
fixup k0l1m2n Fix typo in controller
pick n3o4p5q Add tests
```

**Result:** Clean history with 3 commits instead of 5.

**Interactive rebase options:**
- `pick`: Use commit as-is
- `reword`: Change commit message
- `edit`: Stop to modify commit
- `squash`: Combine with previous (keep both messages)
- `fixup`: Combine with previous (discard this message)
- `drop`: Remove commit entirely
</details>

---

### Question 4: Stashing Scenarios
**Scenario:** You're working on a feature when an urgent bug needs fixing. Your current changes aren't ready to commit.

**Question:** What's the best workflow to handle this situation?

<details>
<summary>Click for Answer</summary>

**Answer:** Use Git stash to temporarily save your work:

```bash
# Save current work
git stash save "WIP: user authentication feature"

# Switch to main and fix bug
git checkout main
git checkout -b hotfix/urgent-bug
# ... fix the bug ...
git add .
git commit -m "Fix critical security issue"

# Merge hotfix
git checkout main
git merge hotfix/urgent-bug
git push origin main

# Return to feature work
git checkout feature-branch
git stash list                    # Verify stash exists
git stash pop                     # Restore your work

# Continue working
# ... complete feature ...
git add .
git commit -m "Complete user authentication"
```

**Stash commands:**
```bash
git stash                         # Quick stash
git stash save "message"          # Stash with description
git stash list                    # List all stashes
git stash show                    # Show latest stash changes
git stash pop                     # Apply and remove stash
git stash apply                   # Apply but keep stash
git stash drop                    # Delete stash
```
</details>

---

### Question 5: Cherry-picking
**Scenario:** You have a bug fix in commit `abc123` on your experimental branch, but you need this fix in the main branch without merging the entire experimental branch.

**Question:** How do you apply just this specific commit to main?

<details>
<summary>Click for Answer</summary>

**Answer:** Use cherry-pick to apply the specific commit:

```bash
# Switch to main branch
git checkout main

# Apply the specific commit
git cherry-pick abc123

# If conflicts occur, resolve them
git add .
git cherry-pick --continue

# Push the change
git push origin main
```

**Cherry-pick options:**
```bash
git cherry-pick abc123            # Apply single commit
git cherry-pick abc123 def456     # Apply multiple commits
git cherry-pick abc123..def456    # Apply range of commits
git cherry-pick --no-commit abc123 # Apply without committing
git cherry-pick -x abc123         # Add "cherry picked from" note
```

**When to use cherry-pick:**
- Applying hotfixes to multiple branches
- Selectively moving commits between branches
- Backporting features to older versions
- Extracting specific changes from experimental branches
</details>

---

### Question 6: Reset vs Revert
**Scenario:** You have 3 commits on main branch, and the middle commit introduced a bug that's now in production.

**Question:** What's the difference between using `git reset` and `git revert` to fix this?

<details>
<summary>Click for Answer</summary>

**Answer:**

**git reset** (destructive - changes history):
```bash
git reset --hard HEAD~2    # Removes last 2 commits entirely
```
- ❌ **Don't use on shared/public branches**
- ✅ **Use only on local, unshared commits**
- **Effect**: History is rewritten, commits disappear

**git revert** (safe - preserves history):
```bash
git revert <bad-commit-hash>    # Creates new commit undoing changes
```
- ✅ **Safe for shared/public branches**
- ✅ **Preserves complete history**
- **Effect**: New commit that undoes the problematic changes

**For production fixes, always use revert:**
```bash
# Identify the problematic commit
git log --oneline

# Revert the bad commit
git revert abc123

# Push the fix
git push origin main
```

**Reset types:**
```bash
git reset --soft HEAD~1     # Undo commit, keep changes staged
git reset --mixed HEAD~1    # Undo commit, unstage changes  
git reset --hard HEAD~1     # Undo commit, discard changes
```
</details>

---

### Question 7: Remote Tracking
**Scenario:** You cloned a repository and created a local branch `feature/login`. You want to push it and set up tracking.

**Question:** What command pushes the branch and sets up tracking in one step?

<details>
<summary>Click for Answer</summary>

**Answer:** `git push -u origin feature/login`

**Explanation:**
- `-u` (or `--set-upstream`) sets up tracking relationship
- After this, you can use `git push` and `git pull` without specifying remote/branch

**Before setting upstream:**
```bash
git push origin feature/login     # Must specify remote and branch
git pull origin feature/login     # Must specify remote and branch
```

**After setting upstream:**
```bash
git push                          # Automatically pushes to origin/feature/login
git pull                          # Automatically pulls from origin/feature/login
```

**Other tracking commands:**
```bash
git branch -u origin/feature/login          # Set upstream for current branch
git branch --set-upstream-to=origin/main    # Set upstream to different branch
git branch -vv                              # Show tracking relationships
```
</details>

---

### Question 8: Force Push Scenarios
**Scenario:** You rebased your feature branch and now need to update the remote branch, but Git rejects the push.

**Question:** What are the safer alternatives to `git push --force`?

<details>
<summary>Click for Answer</summary>

**Answer:** Use `git push --force-with-lease` for safer force pushing:

```bash
# Safer force push
git push --force-with-lease

# Even safer - specify the expected remote state
git push --force-with-lease=origin/feature/login
```

**Why it's safer:**
- Checks if remote branch changed since your last fetch
- Prevents overwriting others' work
- Fails if someone else pushed to the branch

**Complete safe workflow:**
```bash
# Before rebasing, fetch latest
git fetch origin

# Rebase your branch
git rebase origin/main

# Safe force push
git push --force-with-lease origin feature/login
```

**When force push is needed:**
- After interactive rebase
- After amending pushed commits
- After squashing commits

**Never force push to:**
- Main/master branches
- Shared feature branches
- Public repositories (open source)
</details>

---

### Question 9: Merge Conflicts in Rebase
**Scenario:** During `git rebase main`, you encounter conflicts in multiple commits.

**Question:** What's the proper workflow to handle rebase conflicts?

<details>
<summary>Click for Answer</summary>

**Answer:** Handle each conflict step by step:

```bash
# Start rebase
git rebase main

# When conflict occurs:
# 1. See which files have conflicts
git status

# 2. Edit conflicted files to resolve
nano conflicted-file.js

# 3. Stage resolved files
git add conflicted-file.js

# 4. Continue rebase (don't commit!)
git rebase --continue

# Repeat for each conflicted commit
```

**Rebase conflict commands:**
```bash
git rebase --continue      # Continue after resolving conflicts
git rebase --skip          # Skip current commit (if empty after conflicts)
git rebase --abort         # Cancel rebase and return to original state
```

**Pro tips:**
- **Don't use `git commit`** during rebase conflicts
- **Use `git add`** for resolved files, then `--continue`
- **Check `git status`** to see progress
- **Consider `git rebase --abort`** if it gets too complex

**Visual tools help:**
```bash
git mergetool              # Open visual merge tool
git config --global merge.tool vscode  # Set VS Code as merge tool
```
</details>

---

### Question 10: Branch Management
**Scenario:** You want to see which branches have been merged into main and clean up old branches.

**Question:** What commands help you identify and clean up merged branches?

<details>
<summary>Click for Answer</summary>

**Answer:**

**Find merged branches:**
```bash
# Local branches merged into main
git branch --merged main

# Local branches NOT merged
git branch --no-merged main

# Remote branches merged into main
git branch -r --merged main
```

**Safe cleanup workflow:**
```bash
# 1. Switch to main
git checkout main

# 2. Update main
git pull origin main

# 3. List merged branches (excluding main/develop)
git branch --merged | grep -v "\*\|main\|develop"

# 4. Delete merged branches
git branch --merged | grep -v "\*\|main\|develop" | xargs -n 1 git branch -d

# 5. Clean up remote tracking branches
git remote prune origin
```

**Manual cleanup:**
```bash
# Delete specific local branch
git branch -d feature/completed

# Force delete unmerged branch (careful!)
git branch -D feature/abandoned

# Delete remote branch
git push origin --delete feature/completed
```

**Verification commands:**
```bash
git branch -a              # See all branches
git remote show origin     # See remote branch status
git fetch --prune          # Remove stale remote references
```
</details>

---

## 🎯 Advanced Concepts Summary

### Workflow Patterns:
1. **Feature Branch**: `main` → `feature` → merge back
2. **Git Flow**: `main` + `develop` + `feature/*` + `release/*` + `hotfix/*`
3. **GitHub Flow**: `main` + short-lived `feature/*` branches
4. **Forking**: `upstream` → fork → `origin` → pull request

### Conflict Resolution Strategy:
1. **Understand the conflict** (read the markers)
2. **Decide on resolution** (ours, theirs, or combination)
3. **Edit manually** or use merge tools
4. **Test the resolution**
5. **Stage and commit/continue**

### History Rewriting Rules:
- ✅ **Safe**: Local commits not yet pushed
- ❌ **Dangerous**: Shared/public commits
- **Tools**: Interactive rebase, amend, reset
- **Alternative**: Revert for public branches

### Recovery Techniques:
```bash
git reflog                 # Find lost commits
git fsck --lost-found      # Find dangling objects
git branch recovery <hash> # Recover lost work
```

### Next Level:
- Advanced Git hooks
- Submodules and subtrees  
- Git internals and performance
- Enterprise workflow automation

Ready for the advanced quiz? 🚀