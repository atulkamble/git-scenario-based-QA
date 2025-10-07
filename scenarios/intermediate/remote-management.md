# Remote Repository Management Scenarios

## Scenario 1: Working with Multiple Remotes

### Question
You're contributing to an open-source project. You've forked the original repository and need to keep your fork in sync while working on features.

### Setup
```bash
# Fork the original repository on GitHub first
# Then clone your fork
git clone https://github.com/yourusername/project-name.git
cd project-name

# Add original repository as upstream
git remote add upstream https://github.com/original-owner/project-name.git

# Verify remotes
git remote -v
```

### Step-by-Step Workflow

1. **Sync with upstream**
```bash
# Fetch latest changes from upstream
git fetch upstream

# Switch to main branch
git checkout main

# Merge upstream changes
git merge upstream/main

# Push updates to your fork
git push origin main
```

2. **Create feature branch**
```bash
# Create feature branch from updated main
git checkout -b feature/new-contribution

# Make your changes
echo "New feature implementation" > new-feature.js
git add new-feature.js
git commit -m "feat: implement new feature for open source project"

# Push feature branch to your fork
git push origin feature/new-contribution
```

3. **Create Pull Request workflow**
```bash
# Before creating PR, sync with upstream again
git fetch upstream
git checkout main
git merge upstream/main
git push origin main

# Rebase feature branch on latest main
git checkout feature/new-contribution
git rebase main

# Force push rebased feature (use with caution)
git push --force-with-lease origin feature/new-contribution
```

---

## Scenario 2: Handling Force Push Conflicts

### Question
A team member force-pushed to a shared branch, and your local branch is now out of sync. How do you safely recover?

### Problem Simulation
```bash
# Setup initial state
git checkout -b shared-feature
echo "Team member work" > shared-file.txt
git add shared-file.txt
git commit -m "Team member's commit"

# Simulate your local work
echo "Your additional work" >> shared-file.txt
git add shared-file.txt
git commit -m "Your commit on shared branch"

# Simulate force push from remote (done by team member)
# This would normally come from git push, but we'll simulate the conflict
```

### Recovery Steps

1. **Backup your work**
```bash
# Create backup branch
git branch backup-my-work

# Check what commits you have that remote doesn't
git log origin/shared-feature..HEAD --oneline
```

2. **Reset to remote state**
```bash
# Fetch latest remote state
git fetch origin

# Hard reset to remote state (loses local commits)
git reset --hard origin/shared-feature
```

3. **Reapply your changes**
```bash
# Cherry-pick your commits from backup
git cherry-pick backup-my-work

# Or merge your backup branch
git merge backup-my-work

# Resolve any conflicts that arise
```

4. **Alternative: Rebase approach**
```bash
# Instead of reset, rebase your work
git fetch origin
git rebase origin/shared-feature
```

---

## Scenario 3: Managing Release Branches

### Question
Your team uses a release branching strategy. You need to prepare a release, apply hotfixes, and manage version tags.

### Release Preparation

1. **Create release branch**
```bash
# Create release branch from develop
git checkout develop
git pull origin develop
git checkout -b release/v1.2.0

# Update version files
echo "1.2.0" > VERSION
git add VERSION
git commit -m "chore: bump version to 1.2.0"

# Push release branch
git push origin release/v1.2.0
```

2. **Bug fixes during release**
```bash
# Fix bugs found during testing
echo "Bug fix for release" > bugfix.txt
git add bugfix.txt
git commit -m "fix: resolve critical bug in release"

# Continue with more fixes as needed
```

3. **Finalize release**
```bash
# Merge to main
git checkout main
git merge --no-ff release/v1.2.0
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin main
git push origin v1.2.0

# Merge back to develop
git checkout develop
git merge --no-ff release/v1.2.0
git push origin develop

# Delete release branch
git branch -d release/v1.2.0
git push origin --delete release/v1.2.0
```

### Hotfix Management

1. **Create hotfix branch**
```bash
# Hotfix from main/production
git checkout main
git pull origin main
git checkout -b hotfix/v1.2.1

# Apply critical fix
echo "Critical security fix" > security-patch.txt
git add security-patch.txt
git commit -m "fix: apply critical security patch"

# Update version
echo "1.2.1" > VERSION
git add VERSION
git commit -m "chore: bump version to 1.2.1"
```

2. **Deploy hotfix**
```bash
# Merge to main
git checkout main
git merge --no-ff hotfix/v1.2.1
git tag -a v1.2.1 -m "Hotfix version 1.2.1"
git push origin main
git push origin v1.2.1

# Merge to develop
git checkout develop
git merge --no-ff hotfix/v1.2.1
git push origin develop

# Clean up
git branch -d hotfix/v1.2.1
git push origin --delete hotfix/v1.2.1
```

---

## Scenario 4: Large File Management

### Question
Your repository has accumulated large files over time, affecting clone and fetch performance. Implement a strategy to manage this.

### Identify Large Files

1. **Analyze repository size**
```bash
#!/bin/bash
# large-files-analyzer.sh

echo "=== Repository Size Analysis ==="
echo "Total size:"
du -sh .git

echo -e "\n=== Largest files in history ==="
git rev-list --objects --all \
| git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
| sed -n 's/^blob //p' \
| sort --numeric-sort --key=2 \
| tail -10 \
| while read objectname size rest; do
    echo "$(numfmt --to=iec-i --suffix=B $size) $rest"
done

echo -e "\n=== File type sizes ==="
git ls-tree -r --name-only HEAD \
| sed 's/.*\.//' \
| sort \
| uniq -c \
| sort -rn \
| head -10
```

2. **Remove large files from history**
```bash
#!/bin/bash
# remove-large-files.sh

# Remove specific large files from entire history
git filter-branch --force --index-filter \
    'git rm --cached --ignore-unmatch *.zip *.tar.gz *.mp4' \
    --prune-empty --tag-name-filter cat -- --all

# Clean up
rm -rf .git/refs/original/
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

3. **Implement Git LFS**
```bash
# Install and initialize Git LFS
git lfs install

# Track large file types
git lfs track "*.zip"
git lfs track "*.tar.gz"
git lfs track "*.mp4"
git lfs track "*.psd"
git lfs track "*.mov"

# Add .gitattributes
git add .gitattributes
git commit -m "Configure Git LFS for large files"

# Migrate existing files to LFS
git lfs migrate import --include="*.zip,*.tar.gz,*.mp4,*.psd,*.mov" --everything
```

---

## Scenario 5: Team Workflow Automation

### Question
Automate common Git workflows for your team, including branch naming conventions, commit message validation, and deployment triggers.

### Branch Naming Convention Script

```bash
#!/bin/bash
# validate-branch-name.sh

current_branch=$(git rev-parse --abbrev-ref HEAD)

# Define valid patterns
valid_patterns=(
    "^feature/[a-z0-9-]+$"
    "^bugfix/[a-z0-9-]+$"
    "^hotfix/[a-z0-9-]+$"
    "^release/v[0-9]+\.[0-9]+\.[0-9]+$"
    "^main$"
    "^develop$"
)

# Check if branch name matches any valid pattern
valid=false
for pattern in "${valid_patterns[@]}"; do
    if [[ $current_branch =~ $pattern ]]; then
        valid=true
        break
    fi
done

if [ "$valid" = false ]; then
    echo "❌ Invalid branch name: $current_branch"
    echo "Valid patterns:"
    echo "  feature/feature-name"
    echo "  bugfix/bug-description"
    echo "  hotfix/hotfix-description"
    echo "  release/v1.0.0"
    exit 1
fi

echo "✅ Branch name is valid: $current_branch"
```

### Automated Deployment Script

```bash
#!/bin/bash
# deploy-on-tag.sh

# This script runs in CI/CD when a new tag is created

TAG_NAME=$1

if [[ -z "$TAG_NAME" ]]; then
    echo "No tag provided"
    exit 1
fi

# Validate tag format (v1.2.3)
if [[ ! $TAG_NAME =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Invalid tag format: $TAG_NAME"
    exit 1
fi

echo "🚀 Deploying version $TAG_NAME"

# Extract version number
VERSION=${TAG_NAME#v}

# Build application
echo "📦 Building application..."
npm install
npm run build

# Run tests
echo "🧪 Running tests..."
npm test

# Deploy to staging first
echo "🎯 Deploying to staging..."
./deploy-staging.sh $VERSION

# Run integration tests
echo "🔍 Running integration tests..."
npm run test:integration

# Deploy to production
echo "🌟 Deploying to production..."
./deploy-production.sh $VERSION

echo "✅ Deployment complete for version $TAG_NAME"
```

### Team Workflow Helper Script

```bash
#!/bin/bash
# team-workflow.sh

ACTION=$1
FEATURE_NAME=$2

case $ACTION in
    "start-feature")
        if [ -z "$FEATURE_NAME" ]; then
            echo "Usage: $0 start-feature feature-name"
            exit 1
        fi
        
        echo "🚀 Starting new feature: $FEATURE_NAME"
        git checkout develop
        git pull origin develop
        git checkout -b "feature/$FEATURE_NAME"
        echo "✅ Feature branch created: feature/$FEATURE_NAME"
        ;;
        
    "finish-feature")
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        
        if [[ ! $current_branch =~ ^feature/ ]]; then
            echo "❌ Not on a feature branch"
            exit 1
        fi
        
        echo "🏁 Finishing feature: $current_branch"
        
        # Push feature branch
        git push origin "$current_branch"
        
        # Create PR (GitHub CLI example)
        if command -v gh &> /dev/null; then
            gh pr create --title "Feature: ${current_branch#feature/}" --body "Auto-generated PR for $current_branch"
        else
            echo "📝 Create PR manually for branch: $current_branch"
        fi
        ;;
        
    "hotfix")
        if [ -z "$FEATURE_NAME" ]; then
            echo "Usage: $0 hotfix hotfix-description"
            exit 1
        fi
        
        echo "🚨 Creating hotfix: $FEATURE_NAME"
        git checkout main
        git pull origin main
        git checkout -b "hotfix/$FEATURE_NAME"
        echo "✅ Hotfix branch created: hotfix/$FEATURE_NAME"
        ;;
        
    "sync")
        echo "🔄 Syncing with remote repositories..."
        git fetch --all --prune
        
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        
        if [ "$current_branch" = "main" ] || [ "$current_branch" = "develop" ]; then
            git pull origin "$current_branch"
        fi
        
        echo "✅ Sync complete"
        ;;
        
    *)
        echo "Usage: $0 {start-feature|finish-feature|hotfix|sync} [feature-name]"
        exit 1
        ;;
esac
```

---

## Practice Exercises

### Exercise 1: Multi-Remote Setup
1. Fork a repository on GitHub
2. Clone your fork locally
3. Add the original repository as upstream
4. Create a feature branch
5. Make changes and create a PR
6. Sync your fork with upstream updates

### Exercise 2: Release Management
1. Create a develop branch
2. Create multiple feature branches
3. Merge features into develop
4. Create a release branch
5. Apply bug fixes to the release
6. Merge to main and tag the release
7. Merge release changes back to develop

### Exercise 3: Conflict Resolution with Multiple Remotes
1. Set up a repository with multiple contributors
2. Create conflicting changes in different remotes
3. Practice resolving conflicts during sync operations
4. Learn to use `git fetch` and manual merging vs `git pull`

### Quick Commands Reference for Remote Operations
```bash
# Multiple remotes
git remote add upstream <url>        # Add upstream remote
git fetch --all                      # Fetch from all remotes
git push origin feature-branch       # Push to specific remote
git pull upstream main               # Pull from specific remote

# Force push safely
git push --force-with-lease          # Safer than --force
git push -u origin branch-name       # Set upstream tracking

# Branch management
git branch -vv                       # Show tracking branches
git branch --set-upstream-to=origin/main  # Set tracking branch
git push origin --delete branch-name # Delete remote branch

# Tag management
git push origin --tags               # Push all tags
git push origin tag-name             # Push specific tag
git fetch --tags                     # Fetch all tags
```