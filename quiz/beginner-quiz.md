# Git Quiz - Beginner Level

## 🎯 Instructions
- Read each question carefully
- Think about your answer before looking at the solution
- Try to understand the concept, not just memorize commands
- Practice the commands in a test repository

---

## Quiz Questions

### Question 1: Repository Initialization
**Scenario:** You want to start tracking a new project with Git. The project folder already exists with some files.

**Question:** What command should you use to initialize Git tracking?

<details>
<summary>Click for Answer</summary>

**Answer:** `git init`

**Explanation:** 
- `git init` creates a new Git repository in the current directory
- It creates a `.git` folder containing all Git metadata
- After initialization, you need to add files with `git add` and commit with `git commit`

**Complete workflow:**
```bash
cd your-project-folder
git init
git add .
git commit -m "Initial commit"
```
</details>

---

### Question 2: File States
**Scenario:** You have three files in your repository:
- `file1.txt` - modified but not staged
- `file2.txt` - modified and staged  
- `file3.txt` - newly created, not tracked

**Question:** What will `git status` show for each file?

<details>
<summary>Click for Answer</summary>

**Answer:**
```
Changes not staged for commit:
    modified: file1.txt

Changes to be committed:
    modified: file2.txt

Untracked files:
    file3.txt
```

**Explanation:**
- **Modified but not staged**: File is tracked and changed, but changes aren't staged for commit
- **Modified and staged**: File changes are ready to be committed
- **Untracked**: Git doesn't know about this file yet
</details>

---

### Question 3: Adding Files
**Scenario:** You have multiple files with different extensions in your project.

**Question:** How would you add only JavaScript files to the staging area?

A) `git add *.js`
B) `git add --js-only`
C) `git add -js`
D) `git add javascript`

<details>
<summary>Click for Answer</summary>

**Answer:** A) `git add *.js`

**Explanation:**
- `*.js` is a wildcard pattern that matches all files ending with `.js`
- Git supports standard shell wildcards for file patterns
- Alternative: `git add . -- '*.js'` for more complex scenarios

**Other useful patterns:**
```bash
git add *.py          # All Python files
git add src/*.js      # JS files in src directory
git add **/*.css      # CSS files in any subdirectory
```
</details>

---

### Question 4: Commit Messages
**Question:** Which commit message follows Git best practices?

A) `fixed bug`
B) `Fix user authentication bug in login form`
C) `FIXED THE TERRIBLE BUG THAT WAS DRIVING ME CRAZY!!!`
D) `fix`

<details>
<summary>Click for Answer</summary>

**Answer:** B) `Fix user authentication bug in login form`

**Explanation:**
Best practices for commit messages:
- Use imperative mood ("Fix" not "Fixed")
- Be descriptive but concise
- Capitalize the first letter
- No period at the end of subject line
- Keep first line under 50 characters

**Good examples:**
```
Add user registration form
Fix validation error handling
Update README with installation steps
Remove deprecated API endpoints
```
</details>

---

### Question 5: Branch Creation
**Scenario:** You need to create a new feature branch called "user-profile" and switch to it immediately.

**Question:** What's the most efficient single command to do this?

<details>
<summary>Click for Answer</summary>

**Answer:** `git checkout -b user-profile`

**Explanation:**
- `git checkout -b <branch-name>` creates a new branch and switches to it
- Equivalent to: `git branch user-profile` + `git checkout user-profile`
- Modern alternative (Git 2.23+): `git switch -c user-profile`

**Branch workflow:**
```bash
git checkout -b feature/user-profile    # Create and switch
# ... work on feature ...
git add .
git commit -m "Add user profile component"
git checkout main                       # Switch back to main
```
</details>

---

### Question 6: Viewing Changes
**Scenario:** Before committing, you want to review what changes you've made to staged files.

**Question:** Which command shows the changes that will be included in the next commit?

A) `git diff`
B) `git diff --staged`
C) `git status`
D) `git log`

<details>
<summary>Click for Answer</summary>

**Answer:** B) `git diff --staged`

**Explanation:**
- `git diff` shows unstaged changes (working directory vs staging area)
- `git diff --staged` shows staged changes (staging area vs last commit)
- `git diff --cached` is the same as `--staged`
- `git status` shows which files are changed but not the actual changes

**Diff commands:**
```bash
git diff                    # Unstaged changes
git diff --staged          # Staged changes  
git diff HEAD              # All changes since last commit
git diff main..feature     # Between branches
```
</details>

---

### Question 7: Undoing Changes
**Scenario:** You accidentally modified `important.txt` and want to discard the changes, returning the file to its last committed state.

**Question:** What command will discard the changes in the working directory?

<details>
<summary>Click for Answer</summary>

**Answer:** `git checkout -- important.txt`

**Explanation:**
- `git checkout -- <file>` discards changes in working directory
- Modern alternative (Git 2.23+): `git restore important.txt`
- The `--` ensures Git treats it as a file name, not a branch name

**Undoing different types of changes:**
```bash
git checkout -- file.txt     # Discard working directory changes
git reset HEAD file.txt      # Unstage file
git restore file.txt         # Modern discard changes
git restore --staged file.txt # Modern unstage
```

⚠️ **Warning:** This permanently discards your changes!
</details>

---

### Question 8: Remote Repositories
**Scenario:** You cloned a repository and want to see the URL of the remote repository.

**Question:** Which command shows the remote repository URLs?

<details>
<summary>Click for Answer</summary>

**Answer:** `git remote -v`

**Explanation:**
- `git remote` lists remote names (usually "origin")
- `git remote -v` shows remote names with URLs
- `-v` stands for "verbose"

**Remote commands:**
```bash
git remote                    # List remote names
git remote -v                # List remotes with URLs
git remote show origin       # Detailed info about origin
git remote add upstream <url> # Add another remote
```

**Example output:**
```
origin  https://github.com/user/repo.git (fetch)
origin  https://github.com/user/repo.git (push)
```
</details>

---

### Question 9: Merging Branches
**Scenario:** You've finished working on a feature branch and want to merge it into the main branch.

**Question:** What's the correct sequence of commands?

<details>
<summary>Click for Answer</summary>

**Answer:**
```bash
git checkout main
git pull origin main
git merge feature-branch
```

**Explanation:**
1. **Switch to main branch**: You need to be on the target branch
2. **Update main branch**: Ensure you have the latest changes
3. **Merge feature branch**: Integrate your feature

**Complete workflow:**
```bash
# Finish feature work
git add .
git commit -m "Complete feature implementation"

# Switch to main and update
git checkout main
git pull origin main

# Merge feature
git merge feature-branch

# Push updated main
git push origin main

# Clean up
git branch -d feature-branch
```
</details>

---

### Question 10: Git Log
**Scenario:** You want to see a compact, one-line summary of the last 5 commits.

**Question:** Which command accomplishes this?

A) `git log -5`
B) `git log --oneline -5`
C) `git log --short -5`  
D) `git log --summary -5`

<details>
<summary>Click for Answer</summary>

**Answer:** B) `git log --oneline -5`

**Explanation:**
- `--oneline` formats each commit as a single line
- `-5` limits output to 5 commits
- Shows abbreviated commit hash and commit message

**Useful log options:**
```bash
git log --oneline -10          # Last 10 commits, one line each
git log --graph --oneline      # Visual branch structure
git log --stat                 # Show file statistics
git log --since="2 weeks ago"  # Time-based filtering
git log --author="John"        # Filter by author
```

**Example output:**
```
a1b2c3d Add user authentication
e4f5g6h Fix login form validation
h7i8j9k Update README documentation
k0l1m2n Initial project setup
```
</details>

---

## 🎯 Quick Review

### Commands Covered in This Quiz:
```bash
git init                    # Initialize repository
git status                  # Check repository status
git add <file>             # Stage files
git add *.js               # Stage files by pattern
git commit -m "message"    # Create commit
git checkout -b <branch>   # Create and switch branch
git diff --staged          # View staged changes
git checkout -- <file>    # Discard working changes
git remote -v              # Show remote URLs
git merge <branch>         # Merge branch
git log --oneline -5       # Show recent commits
```

### Key Concepts:
- **Three areas**: Working directory, staging area, repository
- **File states**: Untracked, modified, staged, committed
- **Branch workflow**: Create, work, merge, delete
- **Commit messages**: Imperative, descriptive, concise
- **Remote operations**: fetch, pull, push

### Next Steps:
1. Practice these commands in a test repository
2. Try the intermediate quiz
3. Work through the scenario exercises
4. Set up your first real project with Git

Remember: Understanding concepts is more important than memorizing commands! 🚀