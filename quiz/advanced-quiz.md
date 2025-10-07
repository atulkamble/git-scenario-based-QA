# Git Quiz - Advanced Level

## 🎯 Instructions
- These questions test expert-level Git knowledge
- Focus on complex scenarios and edge cases
- Understand Git internals and advanced workflows
- Practice in isolated environments before applying to real projects

---

## Quiz Questions

### Question 1: Git Internals - Object Types
**Scenario:** You want to understand how Git stores data internally.

**Question:** Explain the relationship between Git's four object types and how they work together to form a commit.

<details>
<summary>Click for Answer</summary>

**Answer:**

**The Four Git Object Types:**

1. **Blob**: Stores file content (no metadata, just raw data)
2. **Tree**: Represents directory structure (filenames + blob/tree references)
3. **Commit**: Points to a tree + metadata (author, message, parent commits)
4. **Tag**: Points to a commit with additional metadata

**Relationship diagram:**
```
Commit Object
├── Tree SHA-1 (root directory)
├── Parent commit SHA-1(s)
├── Author info
├── Commit message
└── Timestamp

Tree Object (root)
├── blob SHA-1 → file1.txt
├── blob SHA-1 → file2.js
└── tree SHA-1 → subdirectory/

Tree Object (subdirectory)
└── blob SHA-1 → nested-file.md
```

**Viewing objects:**
```bash
# Find commit's tree
git cat-file -p HEAD

# View tree contents
git cat-file -p <tree-sha>

# View blob content
git cat-file -p <blob-sha>

# Get object type
git cat-file -t <sha>
```

**Key insight:** Every commit is a complete snapshot, not a diff!
</details>

---

### Question 2: Advanced Rebase - Onto
**Scenario:** You have this branch structure:
```
A---B---C main
     \
      D---E---F feature
           \
            G---H bugfix
```

You want to move `bugfix` to be based on `main` instead of `feature`.

**Question:** What command accomplishes this, and why is it tricky?

<details>
<summary>Click for Answer</summary>

**Answer:** Use `git rebase --onto`:

```bash
git rebase --onto main feature bugfix
```

**Explanation:**
- `--onto main`: New base for the commits
- `feature`: Upstream branch (where to stop looking back)
- `bugfix`: Branch to move

**What it does:**
```
Before:
A---B---C main
     \
      D---E---F feature
           \
            G---H bugfix

After:
A---B---C---G'---H' main, bugfix
     \
      D---E---F feature
```

**Why it's tricky:**
- Regular `git rebase main` would replay ALL commits (D, E, F, G, H)
- `--onto` lets you specify exactly which commits to move
- Useful for extracting work that was based on the wrong branch

**Other --onto examples:**
```bash
# Move last 3 commits to different base
git rebase --onto new-base HEAD~3

# Remove commits from middle of branch
git rebase --onto HEAD~3 HEAD~1
```
</details>

---

### Question 3: Submodule vs Subtree
**Scenario:** Your project needs to include an external library. You're deciding between Git submodules and Git subtree.

**Question:** Compare the trade-offs and recommend when to use each approach.

<details>
<summary>Click for Answer</summary>

**Answer:**

**Git Submodules:**

**Pros:**
- Clean separation of concerns
- Explicit version pinning
- Smaller main repository
- Easy to update to specific versions

**Cons:**
- Complex workflow (two-step commits)
- Easy to forget submodule updates
- Cloning requires special flags
- Deployment complexity

**Commands:**
```bash
# Add submodule
git submodule add https://github.com/library/repo.git lib/external

# Clone with submodules
git clone --recursive <url>

# Update submodules
git submodule update --remote
```

**Git Subtree:**

**Pros:**
- Simple workflow (looks like regular files)
- No special clone requirements
- Single repository for deployment
- Easy for team members

**Cons:**
- Larger repository size
- History mixing
- More complex to push changes back
- Less explicit version management

**Commands:**
```bash
# Add subtree
git subtree add --prefix=lib/external https://github.com/library/repo.git main --squash

# Update subtree
git subtree pull --prefix=lib/external https://github.com/library/repo.git main --squash

# Push changes back
git subtree push --prefix=lib/external https://github.com/library/repo.git main
```

**Recommendations:**
- **Use Submodules when:** You need explicit version control, library changes frequently, team is Git-savvy
- **Use Subtree when:** Simple deployment is critical, library changes rarely, team prefers simplicity
</details>

---

### Question 4: Custom Merge Strategies
**Scenario:** You have configuration files that should always prefer the production version during merges, regardless of changes in feature branches.

**Question:** How do you set up a custom merge strategy for specific files?

<details>
<summary>Click for Answer</summary>

**Answer:** Use custom merge drivers with `.gitattributes`:

**1. Define merge strategy in `.gitattributes`:**
```bash
# .gitattributes
config/production.json merge=ours
*.secret merge=ours
database.yml merge=production-merge
```

**2. Configure merge drivers in Git config:**
```bash
# Keep our version (production)
git config merge.ours.driver true

# Custom merge script for database.yml
git config merge.production-merge.driver './scripts/merge-database.sh %O %A %B %L'
git config merge.production-merge.name "Production database merge"
```

**3. Create custom merge script:**
```bash
#!/bin/bash
# scripts/merge-database.sh
# %O = ancestor, %A = ours, %B = theirs, %L = conflict marker size

ANCESTOR=$1
OURS=$2
THEIRS=$3

# Always use production settings for certain keys
python3 << EOF
import json

with open('$OURS', 'r') as f:
    ours = json.load(f)

with open('$THEIRS', 'r') as f:
    theirs = json.load(f)

# Merge logic: keep production host, merge other settings
result = theirs.copy()
result['host'] = ours['host']
result['ssl'] = ours['ssl']

with open('$OURS', 'w') as f:
    json.dump(result, f, indent=2)
EOF

exit 0  # Success
```

**4. Test the merge strategy:**
```bash
git merge feature-branch
# config/production.json will keep main branch version
# database.yml will use custom merge logic
```
</details>

---

### Question 5: Bisect with Automation
**Scenario:** A performance regression was introduced somewhere in the last 100 commits. You have a test script that returns the performance metric.

**Question:** How do you automate finding the exact commit that introduced the regression?

<details>
<summary>Click for Answer</summary>

**Answer:** Use automated Git bisect with a custom test script:

**1. Create test script:**
```bash
#!/bin/bash
# performance-test.sh

# Build the current commit
make clean && make build

# Run performance test
result=$(npm run perf-test 2>&1 | grep "Duration:" | awk '{print $2}')

# Convert to integer (remove 'ms')
duration=${result%ms}

# Threshold: anything over 500ms is bad
if [ "$duration" -gt 500 ]; then
    echo "SLOW: ${duration}ms"
    exit 1  # Bad commit
else
    echo "FAST: ${duration}ms"
    exit 0  # Good commit
fi
```

**2. Run automated bisect:**
```bash
# Start bisect
git bisect start HEAD HEAD~100

# Run automated bisect
git bisect run ./performance-test.sh
```

**3. Advanced test script with error handling:**
```bash
#!/bin/bash
# robust-performance-test.sh

set -e  # Exit on any error

# Skip if build fails (probably not the issue)
if ! make build 2>/dev/null; then
    echo "Build failed, skipping"
    exit 125  # Skip this commit
fi

# Run test with timeout
timeout 30s npm run perf-test > test-output.txt 2>&1

if [ $? -eq 124 ]; then
    echo "Test timed out - likely bad commit"
    exit 1
fi

# Extract and check performance metric
duration=$(grep "Duration:" test-output.txt | awk '{print $2}' | sed 's/ms//')

if [ -z "$duration" ]; then
    echo "Could not extract duration, skipping"
    exit 125
fi

echo "Performance: ${duration}ms"
[ "$duration" -le 500 ] && exit 0 || exit 1
```

**Exit codes for bisect run:**
- `0`: Good commit
- `1`: Bad commit  
- `125`: Skip this commit (can't test)
- `127`: Command not found
- Others: Abort bisect
</details>

---

### Question 6: Git Hooks for Team Workflow
**Scenario:** You want to enforce team coding standards automatically.

**Question:** Design a comprehensive Git hooks system that validates commits, runs tests, and manages deployments.

<details>
<summary>Click for Answer</summary>

**Answer:** Implement multiple hooks for different stages:

**1. Pre-commit hook (client-side):**
```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "🔍 Running pre-commit checks..."

# Check for merge conflict markers
if grep -rn "^<<<<<<< \|^======= \|^>>>>>>> " --include="*.js" --include="*.py" .; then
    echo "❌ Merge conflict markers found!"
    exit 1
fi

# Check for debugging statements
if git diff --cached --name-only | xargs grep -l "console.log\|debugger\|pdb.set_trace" 2>/dev/null; then
    echo "❌ Debugging statements found in staged files!"
    git diff --cached --name-only | xargs grep -Hn "console.log\|debugger\|pdb.set_trace" 2>/dev/null
    exit 1
fi

# Run linting
echo "🔧 Running ESLint..."
git diff --cached --name-only --diff-filter=ACM | grep "\.js$" | xargs eslint
if [ $? -ne 0 ]; then
    echo "❌ ESLint errors found!"
    exit 1
fi

# Run unit tests
echo "🧪 Running unit tests..."
npm test
if [ $? -ne 0 ]; then
    echo "❌ Tests failed!"
    exit 1
fi

echo "✅ All pre-commit checks passed!"
```

**2. Commit-msg hook:**
```bash
#!/bin/bash
# .git/hooks/commit-msg

commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,72}$'

if ! grep -qE "$commit_regex" "$1"; then
    echo "❌ Invalid commit message format!"
    echo "Format: type(scope): description"
    echo "Types: feat, fix, docs, style, refactor, test, chore"
    echo "Example: feat(auth): add OAuth2 integration"
    echo "Max 72 characters"
    exit 1
fi

# Check for ticket reference in commit body
if ! grep -q "Refs #[0-9]\+\|Closes #[0-9]\+\|Fixes #[0-9]\+" "$1"; then
    echo "⚠️  Warning: No ticket reference found (Refs #123, Closes #456, Fixes #789)"
fi
```

**3. Pre-receive hook (server-side):**
```bash
#!/bin/bash
# hooks/pre-receive

while read oldrev newrev refname; do
    branch=$(git rev-parse --symbolic --abbrev-ref $refname)
    
    # Protect main branch
    if [ "$branch" == "main" ]; then
        # Ensure all commits have passed CI
        for commit in $(git rev-list $oldrev..$newrev); do
            ci_status=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
                "https://api.github.com/repos/owner/repo/commits/$commit/status" \
                | jq -r '.state')
            
            if [ "$ci_status" != "success" ]; then
                echo "❌ Push rejected: Commit $commit failed CI checks"
                exit 1
            fi
        done
        
        # Ensure fast-forward only
        if [ "$oldrev" != "0000000000000000000000000000000000000000" ]; then
            if ! git merge-base --is-ancestor $oldrev $newrev; then
                echo "❌ Push rejected: Non-fast-forward push to main branch"
                echo "Please rebase your changes and try again"
                exit 1
            fi
        fi
    fi
done
```

**4. Post-receive hook (deployment):**
```bash
#!/bin/bash
# hooks/post-receive

while read oldrev newrev refname; do
    branch=$(git rev-parse --symbolic --abbrev-ref $refname)
    
    if [ "$branch" == "main" ]; then
        echo "🚀 Deploying to production..."
        
        # Deploy to staging first
        cd /var/www/staging
        git pull origin main
        npm install --production
        npm run build
        
        # Run smoke tests
        if npm run smoke-test; then
            # Deploy to production
            cd /var/www/production
            git pull origin main
            npm install --production
            npm run build
            sudo systemctl restart app
            
            # Send notification
            curl -X POST -H 'Content-type: application/json' \
                --data "{\"text\":\"✅ Production deployed: $(git log -1 --oneline)\"}" \
                $SLACK_WEBHOOK_URL
        else
            echo "❌ Smoke tests failed, deployment aborted"
            # Rollback staging
            cd /var/www/staging
            git reset --hard HEAD~1
        fi
    fi
done
```

**Setup shared hooks:**
```bash
# Store hooks in repository
mkdir .githooks
cp hooks/* .githooks/

# Configure git to use shared hooks
git config core.hooksPath .githooks

# Make hooks executable
chmod +x .githooks/*
```
</details>

---

### Question 7: Repository Surgery
**Scenario:** Your repository history contains sensitive data (API keys) in commits from 6 months ago, and the repository has been shared publicly.

**Question:** How do you completely remove sensitive data from the entire Git history?

<details>
<summary>Click for Answer</summary>

**Answer:** Use BFG Repo-Cleaner or git filter-branch for complete history rewriting:

**Method 1: BFG Repo-Cleaner (Recommended)**
```bash
# 1. Create fresh clone
git clone --mirror https://github.com/user/repo.git repo-backup.git

# 2. Remove sensitive files
java -jar bfg.jar --delete-files "secrets.txt" repo-backup.git
java -jar bfg.jar --replace-text passwords.txt repo-backup.git

# 3. Clean up
cd repo-backup.git
git reflog expire --expire=now --all && git gc --prune=now --aggressive

# 4. Force push (WARNING: This rewrites public history!)
git push --force
```

**Method 2: Git Filter-Branch**
```bash
# Remove specific file from all history
git filter-branch --force --index-filter \
    'git rm --cached --ignore-unmatch path/to/secrets.txt' \
    --prune-empty --tag-name-filter cat -- --all

# Remove sensitive content by pattern
git filter-branch --force --tree-filter \
    'find . -name "*.log" -exec rm -f {} \;' \
    --prune-empty -- --all

# Change all instances of secret key
git filter-branch --force --tree-filter \
    'find . -type f -exec sed -i "s/AKIAIOSFODNN7EXAMPLE/REDACTED/g" {} \;' \
    --prune-empty -- --all
```

**Method 3: Advanced - Content-based removal**
```bash
#!/bin/bash
# remove-secrets.sh

# Define patterns to remove
patterns=(
    "password\s*=\s*['\"][^'\"]*['\"]"
    "api_key\s*=\s*['\"][^'\"]*['\"]"
    "AKIA[0-9A-Z]{16}"  # AWS Access Key pattern
    "sk_live_[0-9a-zA-Z]{24}"  # Stripe live key
)

for pattern in "${patterns[@]}"; do
    git filter-branch --force --tree-filter \
        "find . -type f \( -name '*.js' -o -name '*.py' -o -name '*.json' \) -exec sed -i 's/$pattern/[REDACTED]/g' {} \;" \
        --prune-empty -- --all
done
```

**Complete cleanup process:**
```bash
# 1. Backup repository
cp -r .git .git-backup

# 2. Run BFG or filter-branch
# ... use one of the methods above ...

# 3. Clean up refs and objects
rm -rf .git/refs/original/
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# 4. Verify sensitive data is gone
git log --all --full-history -- path/to/secrets.txt  # Should be empty
git grep -i "sensitive-string" $(git rev-list --all)  # Should be empty

# 5. Force push to all remotes (DESTRUCTIVE!)
git push --force --all
git push --force --tags

# 6. Notify team members
echo "Repository history rewritten. All contributors must re-clone!"
```

**⚠️ Critical warnings:**
- This rewrites public history (changes all commit hashes)
- All contributors must re-clone the repository
- Open pull requests will be broken
- Consider the sensitive data already compromised
- Change/revoke the exposed credentials immediately
</details>

---

### Question 8: Advanced Conflict Resolution
**Scenario:** During a complex three-way merge, you need to resolve conflicts that involve code moved between files.

**Question:** How do you handle conflicts when Git can't properly detect file renames and moves?

<details>
<summary>Click for Answer</summary>

**Answer:** Use advanced merge strategies and manual conflict resolution:

**1. Configure Git for better rename detection:**
```bash
# Improve rename detection
git config merge.renameLimit 999999
git config diff.renameLimit 999999
git config merge.renames true

# More aggressive rename detection
git -c diff.algorithm=patience merge feature-branch
```

**2. Use three-way merge tools:**
```bash
# Configure advanced merge tool
git config merge.tool vimdiff
git config mergetool.vimdiff.cmd 'vimdiff -f $MERGED $LOCAL $BASE $REMOTE'

# Or use VS Code
git config merge.tool vscode
git config mergetool.vscode.cmd 'code --wait $MERGED'

# Launch merge tool for each conflict
git mergetool
```

**3. Manual three-way analysis:**
```bash
# View the three versions
git show :1:filename  # Base (common ancestor)
git show :2:filename  # Ours (current branch)
git show :3:filename  # Theirs (merging branch)

# Compare each version
git diff :1:filename :2:filename  # Base vs Ours
git diff :1:filename :3:filename  # Base vs Theirs
git diff :2:filename :3:filename  # Ours vs Theirs
```

**4. Complex conflict resolution script:**
```bash
#!/bin/bash
# resolve-complex-conflicts.sh

echo "Analyzing complex merge conflicts..."

# Find all conflicted files
conflicted_files=$(git diff --name-only --diff-filter=U)

for file in $conflicted_files; do
    echo "Processing $file..."
    
    # Extract conflict sections
    awk '
    /^<<<<<<< HEAD/ { 
        in_conflict = 1
        print "=== OURS ==="
        next
    }
    /^=======/ {
        print "=== THEIRS ==="
        next
    }
    /^>>>>>>> / {
        in_conflict = 0
        print "=== END ==="
        next
    }
    in_conflict { print }
    ' "$file" > "${file}.conflict-analysis"
    
    echo "Conflict analysis saved to ${file}.conflict-analysis"
done

# Interactive resolution
for file in $conflicted_files; do
    echo "Resolve conflicts in $file? (y/n/s for skip)"
    read -r response
    
    case $response in
        y|Y)
            # Open in editor with conflict analysis
            code "$file" "${file}.conflict-analysis"
            read -p "Press enter when resolved..."
            git add "$file"
            rm "${file}.conflict-analysis"
            ;;
        s|S)
            echo "Skipping $file"
            ;;
        *)
            echo "Opening merge tool for $file"
            git mergetool "$file"
            rm "${file}.conflict-analysis"
            ;;
    esac
done
```

**5. Semantic merge for specific file types:**
```bash
# For package.json conflicts
git config merge.npm.driver 'npm-merge %O %A %B %L'

# Custom merge driver for package.json
#!/bin/bash
# npm-merge script
ancestor=$1
current=$2
other=$3

# Merge dependencies intelligently
node << EOF
const fs = require('fs');

const ancestor = JSON.parse(fs.readFileSync('$ancestor'));
const current = JSON.parse(fs.readFileSync('$current'));
const other = JSON.parse(fs.readFileSync('$other'));

// Merge logic: combine dependencies, prefer higher versions
const merged = { ...current };
merged.dependencies = { ...current.dependencies, ...other.dependencies };

// For version conflicts, choose higher version
for (const [pkg, version] of Object.entries(other.dependencies || {})) {
    if (current.dependencies[pkg] && current.dependencies[pkg] !== version) {
        // Simple version comparison (works for semver)
        if (version > current.dependencies[pkg]) {
            merged.dependencies[pkg] = version;
        }
    }
}

fs.writeFileSync('$current', JSON.stringify(merged, null, 2));
EOF

exit 0
```

**6. Post-resolution validation:**
```bash
# After resolving all conflicts
git diff --check  # Check for whitespace errors
git diff --cached --stat  # Review what will be committed

# Test the merged code
npm test || python -m pytest || make test

# Complete the merge
git commit
```
</details>

---

### Question 9: Performance Optimization for Large Repositories
**Scenario:** Your repository has grown to 10GB with hundreds of thousands of commits, making operations slow.

**Question:** What strategies can you implement to improve Git performance without losing history?

<details>
<summary>Click for Answer</summary>

**Answer:** Implement multiple optimization strategies:

**1. Repository Analysis:**
```bash
#!/bin/bash
# repo-analysis.sh

echo "=== Repository Performance Analysis ==="

# Overall size
echo "Repository size:"
du -sh .git

# Object statistics
echo -e "\nObject statistics:"
git count-objects -v

# Largest objects
echo -e "\nLargest objects:"
git rev-list --objects --all \
| git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
| sed -n 's/^blob //p' \
| sort --numeric-sort --key=2 \
| tail -20 \
| awk '{print $2/1024/1024 " MB " $3}'

# Pack file analysis
echo -e "\nPack file efficiency:"
git verify-pack -v .git/objects/pack/*.idx | head -20

# Branch and tag count
echo -e "\nRepository structure:"
echo "Branches: $(git branch -a | wc -l)"
echo "Tags: $(git tag | wc -l)"
echo "Commits: $(git rev-list --all --count)"
```

**2. Aggressive Optimization:**
```bash
#!/bin/bash
# optimize-repository.sh

echo "🚀 Optimizing repository performance..."

# Clean up loose objects and pack files
echo "Cleaning up loose objects..."
git prune
git prune-packed

# Aggressive garbage collection
echo "Running aggressive garbage collection..."
git gc --aggressive --prune=now

# Optimize pack files
echo "Optimizing pack files..."
git repack -a -d --depth=50 --window=50

# Update server info (for HTTP transport)
git update-server-info

# Expire old reflogs
echo "Cleaning up reflog..."
git reflog expire --expire-unreachable=now --all

# Remove dangling objects
git fsck --unreachable | grep "dangling commit" | awk '{print $3}' | xargs git log --merges --no-walk

echo "✅ Repository optimization complete!"
```

**3. Large File Management:**
```bash
# Migrate large files to Git LFS
#!/bin/bash
# migrate-to-lfs.sh

# Find large files
large_files=$(git rev-list --objects --all \
| git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
| awk '/^blob/ && $3 > 10485760 {print $4}' \
| sort -u)

echo "Large files found:"
echo "$large_files"

# Install and configure Git LFS
git lfs install

# Track large file types
git lfs track "*.zip"
git lfs track "*.tar.gz"
git lfs track "*.mp4"
git lfs track "*.mov"
git lfs track "*.pdf"
git lfs track "*.psd"

# Migrate existing large files
echo "$large_files" | while read file; do
    if [ -f "$file" ]; then
        extension="${file##*.}"
        git lfs track "*.$extension"
    fi
done

# Migrate history to LFS
git lfs migrate import --include="*.zip,*.tar.gz,*.mp4,*.mov,*.pdf,*.psd" --everything

# Add .gitattributes
git add .gitattributes
git commit -m "Configure Git LFS for large files"
```

**4. Partial Clone Configuration:**
```bash
# Enable partial clone features
git config core.preloadIndex true
git config core.fscache true
git config core.untrackedCache true

# For very large repos, enable sparse checkout
git config core.sparseCheckout true
echo "src/*" > .git/info/sparse-checkout
echo "docs/*" >> .git/info/sparse-checkout
git read-tree -m -u HEAD

# Configure automatic maintenance
git config maintenance.auto true
git config maintenance.gc.enabled true
git config maintenance.prefetch.enabled true
```

**5. Performance Monitoring:**
```bash
#!/bin/bash
# performance-monitor.sh

# Time common operations
echo "=== Performance Benchmarks ==="

time_command() {
    echo -n "$1: "
    /usr/bin/time -f "%es" bash -c "$2" 2>&1 | tail -1
}

time_command "git status" "git status >/dev/null"
time_command "git log" "git log --oneline -100 >/dev/null"
time_command "git diff HEAD~1" "git diff HEAD~1 >/dev/null"
time_command "git branch -a" "git branch -a >/dev/null"
time_command "git ls-files" "git ls-files >/dev/null"

# Memory usage
echo -e "\nMemory usage for common operations:"
/usr/bin/time -v git log --oneline -1000 >/dev/null 2>&1 | grep "Maximum resident"
```

**6. Long-term Strategy:**
```bash
# Repository splitting strategy
#!/bin/bash
# split-repository.sh

# Create subtree for independent component
git subtree split --prefix=component/frontend --annotate="(frontend) " -b frontend-only

# Create new repository
mkdir ../frontend-repo
cd ../frontend-repo
git init
git pull ../original-repo frontend-only

# Set up submodule in original repo
cd ../original-repo
git rm -rf component/frontend
git submodule add ../frontend-repo component/frontend
git commit -m "Convert frontend to submodule"

# Clean up
git branch -D frontend-only
```

**Configuration for large repositories:**
```bash
# .git/config optimizations
[core]
    preloadindex = true
    fscache = true
    untrackedCache = true
    
[pack]
    packSizeLimit = 2g
    windowMemory = 256m
    
[gc]
    auto = 256
    autoDetach = false
    
[merge]
    renameLimit = 999999
    
[diff]
    algorithm = histogram
    renameLimit = 999999
```
</details>

---

### Question 10: Git in CI/CD - Advanced Patterns
**Scenario:** Design a Git-based CI/CD workflow that handles multiple environments, automated testing, and safe deployment strategies.

**Question:** How do you implement GitOps with advanced branching strategies and automated quality gates?

<details>
<summary>Click for Answer</summary>

**Answer:** Implement a comprehensive GitOps workflow:

**1. Repository Structure:**
```
project/
├── src/                    # Application code
├── tests/                  # Test suites
├── .github/workflows/      # GitHub Actions
├── k8s/                    # Kubernetes manifests
├── deploy/                 # Deployment scripts
└── quality-gates/          # Quality check scripts
```

**2. Branch Strategy with Quality Gates:**
```yaml
# .github/workflows/quality-gates.yml
name: Quality Gates

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop, release/*]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Full history for better analysis
      
      - name: Security Scan
        run: |
          # Scan for secrets
          docker run --rm -v "$PWD:/code" trufflesecurity/trufflehog:latest git file:///code
          
          # SAST scan
          semgrep --config=auto --error src/
          
          # Dependency vulnerability scan
          npm audit --audit-level moderate

  code-quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Code Quality Analysis
        run: |
          # Linting
          eslint src/ --format junit --output-file eslint-report.xml
          
          # Code coverage
          npm test -- --coverage --coverageReporters=lcov
          
          # SonarQube analysis
          sonar-scanner -Dsonar.projectKey=project -Dsonar.sources=src/
          
      - name: Quality Gate Check
        run: |
          # Enforce minimum coverage
          coverage=$(grep -o 'coverage.*%' coverage/lcov-report/index.html | grep -o '[0-9]*')
          if [ "$coverage" -lt 80 ]; then
            echo "Coverage $coverage% below threshold"
            exit 1
          fi

  integration-tests:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [staging, production-like]
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Test Environment
        run: |
          # Deploy to isolated test environment
          kubectl apply -f k8s/test-${{ matrix.environment }}/
          
          # Wait for deployment
          kubectl wait --for=condition=ready pod -l app=test-app --timeout=300s
          
      - name: Run Integration Tests
        run: |
          # Run comprehensive test suite
          npm run test:integration -- --env=${{ matrix.environment }}
          
          # Load testing
          artillery run tests/load-test.yml
          
          # Security testing
          zap-baseline.py -t http://test-app.local
```

**3. Advanced Deployment Pipeline:**
```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  deploy-staging:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Staging
        run: |
          # Blue-Green deployment
          ./deploy/blue-green-deploy.sh staging
          
      - name: Smoke Tests
        run: |
          # Basic functionality tests
          npm run test:smoke -- --target=staging
          
      - name: Auto-promotion Gate
        run: |
          # Advanced health checks
          ./quality-gates/health-check.sh staging
          
          # Performance regression check
          ./quality-gates/performance-check.sh staging baseline.json

  deploy-production:
    if: startsWith(github.ref, 'refs/tags/v')
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Canary Deployment
        run: |
          # Deploy to 10% of traffic
          ./deploy/canary-deploy.sh production 10
          
      - name: Canary Analysis
        run: |
          # Monitor metrics for 10 minutes
          ./quality-gates/canary-analysis.sh production 600
          
      - name: Full Rollout
        run: |
          # If canary successful, deploy to 100%
          ./deploy/canary-deploy.sh production 100
```

**4. Advanced Deployment Scripts:**
```bash
#!/bin/bash
# deploy/blue-green-deploy.sh

ENVIRONMENT=$1
NEW_VERSION=$(git rev-parse --short HEAD)

echo "🚀 Blue-Green deployment to $ENVIRONMENT"

# Determine current active slot
CURRENT_SLOT=$(kubectl get service app-service -o jsonpath='{.spec.selector.slot}')
NEW_SLOT=$([ "$CURRENT_SLOT" = "blue" ] && echo "green" || echo "blue")

echo "Current slot: $CURRENT_SLOT, New slot: $NEW_SLOT"

# Deploy to inactive slot
sed "s/SLOT_PLACEHOLDER/$NEW_SLOT/g" k8s/app-deployment.yaml | \
sed "s/VERSION_PLACEHOLDER/$NEW_VERSION/g" | \
kubectl apply -f -

# Wait for deployment to be ready
kubectl wait --for=condition=ready pod -l app=myapp,slot=$NEW_SLOT --timeout=300s

# Run health checks on new slot
./quality-gates/health-check.sh "$ENVIRONMENT-$NEW_SLOT"

if [ $? -eq 0 ]; then
    echo "✅ Health checks passed, switching traffic"
    
    # Switch service to new slot
    kubectl patch service app-service -p '{"spec":{"selector":{"slot":"'$NEW_SLOT'"}}}'
    
    # Wait a bit, then clean up old slot
    sleep 30
    kubectl delete deployment app-$CURRENT_SLOT
    
    echo "✅ Blue-Green deployment completed successfully"
else
    echo "❌ Health checks failed, cleaning up failed deployment"
    kubectl delete deployment app-$NEW_SLOT
    exit 1
fi
```

**5. Canary Deployment with Metrics:**
```bash
#!/bin/bash
# deploy/canary-deploy.sh

ENVIRONMENT=$1
TRAFFIC_PERCENTAGE=$2

echo "🐦 Canary deployment: $TRAFFIC_PERCENTAGE% traffic to $ENVIRONMENT"

# Deploy canary version
kubectl apply -f k8s/canary-deployment.yaml

# Configure traffic split
kubectl patch virtualservice app-vs --type merge -p '{
  "spec": {
    "http": [{
      "match": [{"headers": {"canary": {"exact": "true"}}}],
      "route": [{"destination": {"host": "app-canary"}}]
    }, {
      "route": [
        {"destination": {"host": "app-stable"}, "weight": '$((100-TRAFFIC_PERCENTAGE))'},
        {"destination": {"host": "app-canary"}, "weight": '$TRAFFIC_PERCENTAGE'}
      ]
    }]
  }
}'

echo "✅ Canary deployment configured with $TRAFFIC_PERCENTAGE% traffic"
```

**6. Quality Gates Scripts:**
```bash
#!/bin/bash
# quality-gates/canary-analysis.sh

ENVIRONMENT=$1
DURATION=$2

echo "📊 Analyzing canary metrics for ${DURATION}s"

# Start monitoring
start_time=$(date +%s)
end_time=$((start_time + DURATION))

while [ $(date +%s) -lt $end_time ]; do
    # Check error rate
    error_rate=$(curl -s "http://prometheus:9090/api/v1/query?query=rate(http_requests_total{status=~'5..'}[5m])" | jq -r '.data.result[0].value[1]')
    
    # Check response time
    response_time=$(curl -s "http://prometheus:9090/api/v1/query?query=histogram_quantile(0.95,rate(http_request_duration_seconds_bucket[5m]))" | jq -r '.data.result[0].value[1]')
    
    echo "Error rate: $error_rate, P95 response time: ${response_time}s"
    
    # Fail fast if metrics are bad
    if (( $(echo "$error_rate > 0.01" | bc -l) )); then
        echo "❌ Error rate too high: $error_rate"
        exit 1
    fi
    
    if (( $(echo "$response_time > 2.0" | bc -l) )); then
        echo "❌ Response time too high: ${response_time}s"
        exit 1
    fi
    
    sleep 30
done

echo "✅ Canary analysis passed - metrics within acceptable ranges"
```

**7. GitOps Configuration:**
```yaml
# GitOps with ArgoCD
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/company/myapp-config
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: myapp
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
    retry:
      limit: 3
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
```

This comprehensive GitOps implementation provides:
- **Quality gates** at every stage
- **Safe deployment patterns** (blue-green, canary)
- **Automated rollback** on failure
- **Comprehensive monitoring** and alerting
- **Infrastructure as Code** with Git as single source of truth
</details>

---

## 🎯 Expert-Level Concepts Summary

### Git Internals Mastery:
- Object model (blob, tree, commit, tag)
- SHA-1 hashing and integrity
- Pack files and delta compression
- Reference management and reflog

### Advanced Workflows:
- Complex rebasing with `--onto`
- Custom merge strategies and drivers
- Submodule vs subtree trade-offs
- Repository maintenance and optimization

### Enterprise Patterns:
- Comprehensive Git hooks system
- History rewriting and data removal
- Performance optimization strategies
- GitOps and CI/CD integration

### Problem-Solving Skills:
- Complex conflict resolution
- Repository forensics and recovery
- Large repository management
- Security and compliance

### Automation & Tooling:
- Advanced bisect workflows
- Custom scripts and integrations
- Monitoring and alerting
- Quality gate implementation

### Next Steps:
- Contribute to Git development
- Build Git-based tools and services
- Architect enterprise Git workflows
- Mentor teams on advanced Git practices

Congratulations on reaching expert level! 🏆 You now have the knowledge to handle any Git scenario and architect sophisticated workflows for any organization.