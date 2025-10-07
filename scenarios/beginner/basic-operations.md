# Beginner Git Scenarios

## Scenario 1: Repository Initialization and First Commit

### Question
You need to start a new project called "my-portfolio". Create a Git repository, add a README file, and make your first commit.

### Step-by-Step Solution

1. **Create and navigate to project directory**
```bash
mkdir my-portfolio
cd my-portfolio
```

2. **Initialize Git repository**
```bash
git init
```

3. **Create README file**
```bash
echo "# My Portfolio" > README.md
```

4. **Add file to staging area**
```bash
git add README.md
```

5. **Make first commit**
```bash
git commit -m "Initial commit: Add README"
```

6. **Verify the commit**
```bash
git log --oneline
```

### Expected Output
```
a1b2c3d (HEAD -> main) Initial commit: Add README
```

---

## Scenario 2: Creating and Switching Branches

### Question
You're working on a feature called "contact-form" for your website. Create a new branch for this feature and switch to it.

### Step-by-Step Solution

1. **Create and switch to new branch**
```bash
git checkout -b feature/contact-form
```

2. **Verify current branch**
```bash
git branch
```

3. **Alternative method: Create branch then switch**
```bash
git branch feature/contact-form
git checkout feature/contact-form
```

4. **Modern Git way (Git 2.23+)**
```bash
git switch -c feature/contact-form
```

### Expected Output
```
* feature/contact-form
  main
```

---

## Scenario 3: Making Changes and Committing

### Question
On your feature branch, create a contact.html file with basic HTML structure and commit the changes.

### Step-by-Step Solution

1. **Create HTML file**
```bash
cat > contact.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Contact Us</title>
</head>
<body>
    <h1>Contact Form</h1>
    <form>
        <input type="text" placeholder="Your Name">
        <input type="email" placeholder="Your Email">
        <textarea placeholder="Your Message"></textarea>
        <button type="submit">Send</button>
    </form>
</body>
</html>
EOF
```

2. **Check status**
```bash
git status
```

3. **Add and commit**
```bash
git add contact.html
git commit -m "Add basic contact form HTML structure"
```

4. **View commit history**
```bash
git log --oneline
```

---

## Scenario 4: Merging Feature Branch

### Question
Your contact form feature is complete. Merge it back to the main branch.

### Step-by-Step Solution

1. **Switch to main branch**
```bash
git checkout main
```

2. **Merge feature branch**
```bash
git merge feature/contact-form
```

3. **Delete feature branch (optional)**
```bash
git branch -d feature/contact-form
```

4. **Verify merge**
```bash
git log --oneline --graph
```

### Expected Output
```
*   c4d5e6f (HEAD -> main) Merge branch 'feature/contact-form'
|\  
| * b2c3d4e Add basic contact form HTML structure
|/  
* a1b2c3d Initial commit: Add README
```

---

## Scenario 5: Checking File Differences

### Question
You've modified your README.md file but want to see what changes you made before committing.

### Step-by-Step Solution

1. **Modify README.md**
```bash
echo "## Features" >> README.md
echo "- Contact form" >> README.md
echo "- Responsive design" >> README.md
```

2. **Check differences (unstaged)**
```bash
git diff
```

3. **Stage the file**
```bash
git add README.md
```

4. **Check differences (staged)**
```bash
git diff --staged
```

5. **Commit the changes**
```bash
git commit -m "Update README with features list"
```

---

## Practice Scripts

### Script 1: Setup Practice Repository
```bash
#!/bin/bash
# setup-practice-repo.sh

echo "Setting up practice repository..."
mkdir git-practice
cd git-practice
git init
echo "# Git Practice Repository" > README.md
git add README.md
git commit -m "Initial commit"
echo "Practice repository created successfully!"
```

### Script 2: Create Multiple Branches
```bash
#!/bin/bash
# create-branches.sh

branches=("feature/header" "feature/footer" "bugfix/typo" "hotfix/security")

for branch in "${branches[@]}"; do
    git checkout -b "$branch"
    echo "Created and switched to $branch"
    git checkout main
done

echo "All branches created. Use 'git branch' to see them."
```

### Quick Commands Reference
```bash
# Basic commands
git init                    # Initialize repository
git status                  # Check repository status
git add <file>             # Stage file
git commit -m "message"    # Commit with message
git log                    # View commit history

# Branch operations
git branch                 # List branches
git checkout -b <branch>   # Create and switch to branch
git merge <branch>         # Merge branch
git branch -d <branch>     # Delete branch

# Viewing changes
git diff                   # Show unstaged changes
git diff --staged          # Show staged changes
git show                   # Show last commit
```