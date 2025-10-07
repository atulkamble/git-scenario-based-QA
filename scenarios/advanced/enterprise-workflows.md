# Advanced Git Scenarios

## Scenario 1: Complex Merge Strategy and Subtree Merging

### Question
You need to integrate a third-party library as a subtree in your project, maintain the ability to pull updates from the library, and handle complex merge scenarios with multiple long-running branches.

### Step-by-Step Solution

1. **Setup main project**
```bash
mkdir advanced-project
cd advanced-project
git init
echo "# Advanced Project" > README.md
git add README.md
git commit -m "Initial project setup"
```

2. **Add remote for third-party library**
```bash
git remote add library-origin https://github.com/example/library.git
git fetch library-origin
```

3. **Add library as subtree**
```bash
git subtree add --prefix=lib/external library-origin main --squash
```

4. **Create complex branching structure**
```bash
# Long-running development branch
git checkout -b develop
echo "Development changes" > dev-file.txt
git add dev-file.txt
git commit -m "Add development features"

# Feature branches from develop
git checkout -b feature/advanced-auth
echo "Advanced authentication system" > auth.js
git add auth.js
git commit -m "Implement advanced authentication"

git checkout develop
git checkout -b feature/api-integration
echo "API integration logic" > api.js
git add api.js
git commit -m "Add API integration"

# Release branch
git checkout develop
git checkout -b release/v1.0
echo "v1.0" > VERSION
git add VERSION
git commit -m "Prepare v1.0 release"
```

5. **Complex merge with custom strategy**
```bash
# Merge features into develop with merge commit
git checkout develop
git merge --no-ff feature/advanced-auth -m "Merge advanced authentication feature"
git merge --no-ff feature/api-integration -m "Merge API integration feature"

# Merge develop into release
git checkout release/v1.0
git merge develop --no-ff -m "Merge develop into release v1.0"

# Tag the release
git tag -a v1.0.0 -m "Release version 1.0.0"
```

6. **Update subtree from upstream**
```bash
git subtree pull --prefix=lib/external library-origin main --squash
```

---

## Scenario 2: Git Hooks and Automation

### Question
Implement a comprehensive Git hooks system that validates commits, runs tests, and automates deployment workflows.

### Pre-commit Hook Implementation

1. **Create pre-commit hook**
```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running pre-commit checks..."

# Check for debugging statements
if git diff --cached --name-only | xargs grep -l "console.log\|debugger\|pdb.set_trace" 2>/dev/null; then
    echo "Error: Debugging statements found. Please remove before committing."
    echo "Files with debugging statements:"
    git diff --cached --name-only | xargs grep -l "console.log\|debugger\|pdb.set_trace" 2>/dev/null
    exit 1
fi

# Check commit message format
commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}'
if ! grep -qE "$commit_regex" .git/COMMIT_EDITMSG 2>/dev/null; then
    echo "Invalid commit message format."
    echo "Use: type(scope): description"
    echo "Types: feat, fix, docs, style, refactor, test, chore"
    exit 1
fi

# Run linting
if command -v eslint &> /dev/null; then
    echo "Running ESLint..."
    eslint $(git diff --cached --name-only --diff-filter=ACM | grep "\.js$")
    if [ $? -ne 0 ]; then
        echo "ESLint errors found. Please fix before committing."
        exit 1
    fi
fi

# Run tests
echo "Running tests..."
npm test
if [ $? -ne 0 ]; then
    echo "Tests failed. Please fix before committing."
    exit 1
fi

echo "Pre-commit checks passed!"
exit 0
```

2. **Make hook executable**
```bash
chmod +x .git/hooks/pre-commit
```

3. **Create commit-msg hook**
```bash
#!/bin/bash
# .git/hooks/commit-msg

commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "Invalid commit message format in file: $1"
    echo "Commit message should match: $commit_regex"
    echo ""
    echo "Examples:"
    echo "  feat(auth): add OAuth2 authentication"
    echo "  fix(api): resolve user validation bug"
    echo "  docs: update README with installation steps"
    exit 1
fi

# Check for ticket reference
if ! grep -qE "Refs? #[0-9]+" "$1"; then
    echo "Warning: Commit message should reference a ticket (e.g., 'Refs #123')"
fi
```

4. **Post-commit hook for notifications**
```bash
#!/bin/bash
# .git/hooks/post-commit

# Get commit information
commit_hash=$(git rev-parse HEAD)
commit_message=$(git log -1 --pretty=%B)
author=$(git log -1 --pretty=%an)
branch=$(git branch --show-current)

# Send notification (example with Slack webhook)
if [ -n "$SLACK_WEBHOOK_URL" ]; then
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"New commit by $author on $branch: $commit_message (${commit_hash:0:7})\"}" \
        "$SLACK_WEBHOOK_URL"
fi

# Update deployment status
echo "Commit $commit_hash ready for deployment" >> deployment.log
```

---

## Scenario 3: Git Bisect for Bug Hunting

### Question
A bug was introduced somewhere in the last 50 commits. Use Git bisect to efficiently find the problematic commit.

### Setup Bug Scenario
```bash
#!/bin/bash
# create-bug-scenario.sh

git checkout -b bug-hunt-demo
for i in {1..20}; do
    if [ $i -eq 12 ]; then
        # Introduce a bug in commit 12
        echo "function calculate(a, b) { return a - b; }" > calculator.js
    else
        echo "function calculate(a, b) { return a + b; }" > calculator.js
    fi
    
    echo "Update $i" >> changelog.txt
    git add .
    git commit -m "Update $i: various improvements"
done
```

### Bisect Process

1. **Start bisect**
```bash
git bisect start
```

2. **Mark current commit as bad**
```bash
git bisect bad
```

3. **Mark a known good commit**
```bash
git bisect good HEAD~19
```

4. **Create test script**
```bash
#!/bin/bash
# test-calculator.sh
node -e "
const calc = require('./calculator.js');
if (calc.calculate) {
    const result = calc.calculate(5, 3);
    if (result === 8) {
        console.log('PASS: Calculator works correctly');
        process.exit(0);
    } else {
        console.log('FAIL: Calculator returned', result, 'expected 8');
        process.exit(1);
    }
} else {
    console.log('FAIL: Calculator function not found');
    process.exit(1);
}
"
```

5. **Run bisect with automated testing**
```bash
git bisect run ./test-calculator.sh
```

6. **Review the problematic commit**
```bash
git show  # Shows the bad commit
```

7. **End bisect session**
```bash
git bisect reset
```

---

## Scenario 4: Advanced Repository Maintenance

### Question
Your repository has grown large and unwieldy. Implement maintenance procedures to optimize performance, clean up history, and manage large files.

### Repository Analysis and Cleanup

1. **Analyze repository size**
```bash
#!/bin/bash
# analyze-repo.sh

echo "=== Repository Size Analysis ==="
echo "Total repository size:"
du -sh .git

echo -e "\n=== Largest objects in repository ==="
git rev-list --objects --all \
| git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
| sed -n 's/^blob //p' \
| sort --numeric-sort --key=2 \
| tail -20

echo -e "\n=== File type breakdown ==="
git ls-tree -r --name-only HEAD | sed 's/.*\.//' | sort | uniq -c | sort -rn

echo -e "\n=== Largest files in working directory ==="
find . -type f -not -path './.git/*' -exec du -h {} + | sort -rh | head -20
```

2. **Clean up large files from history**
```bash
#!/bin/bash
# cleanup-large-files.sh

# Find large files in history
large_files=$(git rev-list --objects --all \
| git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
| awk '/^blob/ && $3 > 1048576 {print $4}' \
| sort -u)

echo "Large files found:"
echo "$large_files"

# Remove large files from history
for file in $large_files; do
    echo "Removing $file from history..."
    git filter-branch --force --index-filter \
        "git rm --cached --ignore-unmatch $file" \
        --prune-empty --tag-name-filter cat -- --all
done

# Clean up refs
rm -rf .git/refs/original/
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

3. **Implement Git LFS for large files**
```bash
#!/bin/bash
# setup-git-lfs.sh

# Install and initialize Git LFS
git lfs install

# Track large file types
git lfs track "*.psd"
git lfs track "*.zip"
git lfs track "*.mp4"
git lfs track "*.mov"
git lfs track "*.pdf"

# Add .gitattributes
git add .gitattributes
git commit -m "Configure Git LFS for large files"

# Migrate existing large files
git lfs migrate import --include="*.psd,*.zip,*.mp4,*.mov,*.pdf"
```

---

## Scenario 5: Multi-Repository Management with Submodules

### Question
Manage a complex project structure with multiple related repositories using Git submodules, including updates, branch management, and automation.

### Submodule Management

1. **Add submodules**
```bash
# Add frontend submodule
git submodule add https://github.com/company/frontend.git frontend

# Add backend submodule
git submodule add https://github.com/company/backend.git backend

# Add shared utilities
git submodule add https://github.com/company/utils.git shared/utils

git commit -m "Add project submodules"
```

2. **Clone repository with submodules**
```bash
# Clone with submodules
git clone --recursive https://github.com/company/main-project.git

# Or clone then initialize submodules
git clone https://github.com/company/main-project.git
cd main-project
git submodule init
git submodule update
```

3. **Update submodules**
```bash
#!/bin/bash
# update-submodules.sh

echo "Updating all submodules..."

# Update each submodule to latest
git submodule foreach 'git fetch origin; git checkout main; git pull origin main'

# Update main repository
git add .
git commit -m "Update submodules to latest versions"

echo "Submodule update complete!"
```

4. **Work with submodule branches**
```bash
#!/bin/bash
# submodule-branch-work.sh

submodule_path="frontend"
feature_branch="feature/new-ui"

echo "Creating feature branch in $submodule_path..."

cd "$submodule_path"
git checkout -b "$feature_branch"
echo "New UI component" > new-component.js
git add new-component.js
git commit -m "Add new UI component"
git push origin "$feature_branch"

cd ..
git add "$submodule_path"
git commit -m "Update $submodule_path to $feature_branch"
```

5. **Automation script for submodule management**
```bash
#!/bin/bash
# manage-submodules.sh

ACTION=$1
SUBMODULE=$2

case $ACTION in
    "status")
        echo "=== Submodule Status ==="
        git submodule status
        git submodule foreach 'echo "=== $name ==="; git status --short'
        ;;
    
    "update")
        if [ -n "$SUBMODULE" ]; then
            echo "Updating $SUBMODULE..."
            git submodule update --remote "$SUBMODULE"
        else
            echo "Updating all submodules..."
            git submodule update --remote
        fi
        ;;
    
    "sync")
        echo "Syncing submodule URLs..."
        git submodule sync
        git submodule update --init --recursive
        ;;
    
    "foreach")
        shift
        echo "Running '$*' in all submodules..."
        git submodule foreach "$@"
        ;;
    
    *)
        echo "Usage: $0 {status|update|sync|foreach} [submodule] [command]"
        echo "Examples:"
        echo "  $0 status"
        echo "  $0 update frontend"
        echo "  $0 foreach 'git checkout main'"
        exit 1
        ;;
esac
```

---

## Performance Optimization Scripts

### Git Configuration for Large Repositories
```bash
#!/bin/bash
# optimize-git-config.sh

echo "Optimizing Git configuration for large repositories..."

# Enable parallel processing
git config core.preloadindex true
git config core.fscache true
git config gc.auto 256

# Optimize pack files
git config pack.packSizeLimit 2g
git config pack.windowMemory 256m

# Enable partial clone for very large repos
git config core.enablePartialClone true

# Optimize status and diff performance
git config status.showUntrackedFiles no
git config diff.algorithm histogram

echo "Git optimization complete!"
```

### Repository Health Check
```bash
#!/bin/bash
# health-check.sh

echo "=== Git Repository Health Check ==="

echo "Repository size:"
du -sh .git

echo -e "\nObject count:"
git count-objects -v

echo -e "\nBranch information:"
echo "Local branches: $(git branch | wc -l)"
echo "Remote branches: $(git branch -r | wc -l)"
echo "Tags: $(git tag | wc -l)"

echo -e "\nRecent activity:"
git log --oneline --since="1 month ago" | wc -l | xargs echo "Commits in last month:"

echo -e "\nLarge files:"
git ls-tree -r --name-only HEAD | xargs -I {} sh -c 'echo "$(git log -1 --format="%ai" -- "{}"): $(du -h "{}" 2>/dev/null || echo "0 {}")"' | sort -rh | head -10

echo -e "\nRepository integrity:"
git fsck --full --strict
```