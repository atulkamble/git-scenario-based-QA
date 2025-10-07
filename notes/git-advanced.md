# Advanced Git Concepts - Deep Dive Notes

## 📚 Table of Contents
1. [Git Internals](#git-internals)
2. [Advanced Branching](#advanced-branching)
3. [Rewriting History](#rewriting-history)
4. [Advanced Merging](#advanced-merging)
5. [Git Hooks Deep Dive](#git-hooks-deep-dive)
6. [Performance Optimization](#performance-optimization)
7. [Enterprise Workflows](#enterprise-workflows)
8. [Debugging and Recovery](#debugging-and-recovery)

---

## Git Internals

### The Object Database

Git stores everything as objects in `.git/objects/`. Understanding this is crucial for advanced Git usage.

#### Object Storage
```bash
# View object type
git cat-file -t <sha1>

# View object content  
git cat-file -p <sha1>

# View object size
git cat-file -s <sha1>
```

#### SHA-1 Generation
```bash
# Generate SHA-1 for content
echo "Hello World" | git hash-object --stdin

# Add to object database
echo "Hello World" | git hash-object -w --stdin
```

### Git References

#### Types of References
1. **Branches** (`refs/heads/`)
2. **Remote branches** (`refs/remotes/`)
3. **Tags** (`refs/tags/`)

```bash
# View all references
git for-each-ref

# View specific reference
cat .git/refs/heads/main

# Update reference
git update-ref refs/heads/main <sha1>
```

### The Index (Staging Area)

The index is a binary file that stores the staging area state.

```bash
# View index contents
git ls-files --stage

# View index as tree
git ls-files --stage | cut -f2 | git cat-file --batch-check
```

### Packfiles

Git optimizes storage using packfiles for efficiency.

```bash
# Manual garbage collection
git gc

# Aggressive garbage collection
git gc --aggressive

# View pack information
git verify-pack -v .git/objects/pack/pack-*.idx
```

---

## Advanced Branching

### Branch Strategies in Depth

#### Git Flow (Detailed)
```
main branch:      ●─────●─────●─────●  (production)
                 /       \   /       \
develop branch:  ●─●─●─●─●─●─●─●─●─●─●  (integration)
                  /   \   /   \
feature branches: ●─●─●   ●─●─●      (features)
                     \     /
release branch:       ●─●─●          (release prep)
                         \
hotfix branch:            ●─●         (urgent fixes)
```

##### Commands for Git Flow
```bash
# Initialize Git Flow
git flow init

# Start/finish feature
git flow feature start new-feature
git flow feature finish new-feature

# Start/finish release
git flow release start 1.0.0
git flow release finish 1.0.0

# Start/finish hotfix
git flow hotfix start urgent-fix
git flow hotfix finish urgent-fix
```

#### GitHub Flow (Simplified)
```
main branch:     ●─●─●─●─●─●─●─●─●  (always deployable)
                  \   /   \   /
feature branches:  ●─●     ●─●     (short-lived)
```

#### GitLab Flow
Combines Git Flow and GitHub Flow with environment branches.

```
main → staging → production
  \       \         \
   \       \         \
    feature branches
```

### Advanced Branch Operations

#### Orphan Branches
Create branches with no common history.

```bash
# Create orphan branch
git checkout --orphan new-root

# Remove all files
git rm -rf .

# Create new initial commit
echo "New root" > README.md
git add README.md
git commit -m "Initial commit for orphan branch"
```

#### Branch Filters
```bash
# List branches by pattern
git branch --list "feature/*"

# List branches by commit
git branch --contains <commit>

# List branches not merged
git branch --no-merged main

# List branches merged
git branch --merged main
```

---

## Rewriting History

### Interactive Rebase (Advanced)

Interactive rebase is powerful for cleaning up commit history.

#### Rebase Commands
- **pick**: Use commit as-is
- **reword**: Change commit message
- **edit**: Stop for amending
- **squash**: Combine with previous commit
- **fixup**: Like squash but discard message
- **exec**: Run shell command
- **drop**: Remove commit

#### Example Interactive Rebase
```bash
git rebase -i HEAD~5

# Editor opens with:
pick a1b2c3d Add feature A
pick e4f5g6h Fix typo
pick h7i8j9k Add feature B  
pick k0l1m2n Fix another typo
pick n3o4p5q Update documentation

# Change to:
pick a1b2c3d Add feature A
fixup e4f5g6h Fix typo
pick h7i8j9k Add feature B
fixup k0l1m2n Fix another typo
reword n3o4p5q Update documentation
```

### Filter-Branch

Rewrite entire repository history.

```bash
# Remove file from all history
git filter-branch --index-filter 'git rm --cached --ignore-unmatch secrets.txt' HEAD

# Change author for all commits
git filter-branch --env-filter '
if [ "$GIT_AUTHOR_EMAIL" = "old@email.com" ]; then
    export GIT_AUTHOR_EMAIL="new@email.com"
    export GIT_AUTHOR_NAME="New Name"
fi
' HEAD
```

### BFG Repo-Cleaner

Alternative to filter-branch for large repositories.

```bash
# Install BFG (requires Java)
# Download from https://rtyley.github.io/bfg-repo-cleaner/

# Remove large files
java -jar bfg.jar --strip-blobs-bigger-than 50M my-repo.git

# Remove sensitive data
java -jar bfg.jar --delete-files passwords.txt my-repo.git
```

---

## Advanced Merging

### Merge Strategies

#### Recursive (Default)
Best for most merges, handles renames well.

```bash
git merge -s recursive branch-name
```

#### Octopus
Merge more than two branches simultaneously.

```bash
git merge branch1 branch2 branch3
```

#### Ours/Theirs
```bash
# Use our version for conflicts
git merge -X ours branch-name

# Use their version for conflicts  
git merge -X theirs branch-name
```

#### Subtree
Merge another repository as subdirectory.

```bash
# Add subtree
git subtree add --prefix=lib/external https://github.com/external/repo.git main --squash

# Update subtree
git subtree pull --prefix=lib/external https://github.com/external/repo.git main --squash

# Push changes back to subtree
git subtree push --prefix=lib/external https://github.com/external/repo.git main
```

### Custom Merge Drivers

Define custom merge strategies for specific file types.

```bash
# .gitattributes
*.sql merge=sql-merge

# .git/config
[merge "sql-merge"]
    driver = ./scripts/sql-merge.sh %O %A %B %L
```

### Three-Way Merge Algorithm

Understanding how Git resolves conflicts:

1. **Base**: Common ancestor commit
2. **Ours**: Current branch commit  
3. **Theirs**: Merging branch commit

```bash
# View merge base
git merge-base branch1 branch2

# Show three-way diff
git show :1:filename  # Base version
git show :2:filename  # Our version
git show :3:filename  # Their version
```

---

## Git Hooks Deep Dive

### Hook Types and Use Cases

#### Pre-commit Hook Example
```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running pre-commit checks..."

# Check for merge conflict markers
if grep -rn "^<<<<<<< \|^======= \|^>>>>>>> " --include="*.js" --include="*.css" .; then
    echo "Error: Merge conflict markers found!"
    exit 1
fi

# Run linting
if command -v eslint >/dev/null 2>&1; then
    echo "Running ESLint..."
    eslint . --ext .js,.jsx,.ts,.tsx
    if [ $? -ne 0 ]; then
        echo "ESLint errors found. Please fix them before committing."
        exit 1
    fi
fi

# Run tests
echo "Running tests..."
npm test
if [ $? -ne 0 ]; then
    echo "Tests failed. Please fix them before committing."
    exit 1
fi

echo "All pre-commit checks passed!"
```

#### Commit-msg Hook Example
```bash
#!/bin/bash
# .git/hooks/commit-msg

commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "Invalid commit message format!"
    echo "Format: type(scope): description"
    echo "Types: feat, fix, docs, style, refactor, test, chore"
    echo "Example: feat(auth): add OAuth2 login"
    exit 1
fi
```

#### Post-receive Hook (Server-side)
```bash
#!/bin/bash
# hooks/post-receive

while read oldrev newrev refname; do
    branch=$(git rev-parse --symbolic --abbrev-ref $refname)
    
    if [ "$branch" == "main" ]; then
        echo "Deploying to production..."
        cd /var/www/production
        git --git-dir=.git pull origin main
        
        # Restart services
        sudo systemctl restart nginx
        sudo systemctl restart app-server
        
        # Send notification
        curl -X POST \
            -H 'Content-type: application/json' \
            --data "{\"text\":\"Production deployed: $newrev\"}" \
            $SLACK_WEBHOOK_URL
    fi
done
```

### Bypassing Hooks

```bash
# Skip pre-commit hooks
git commit --no-verify -m "Emergency fix"

# Skip all hooks
git commit -n -m "Skip hooks"
```

---

## Performance Optimization

### Repository Size Management

#### Analyze Repository Size
```bash
# Check repository size
du -sh .git

# Find largest objects
git rev-list --objects --all \
| git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
| sed -n 's/^blob //p' \
| sort --numeric-sort --key=2 \
| tail -20

# Object count statistics
git count-objects -v
```

#### Optimization Commands
```bash
# Aggressive cleanup
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Repack with optimal settings
git repack -a -d --depth=50 --window=50

# Remove dangling objects
git fsck --unreachable | grep commit | cut -d' ' -f3 | xargs git log --merges --no-walk
```

### Git LFS (Large File Storage)

#### Setup and Configuration
```bash
# Install Git LFS
git lfs install

# Track file types
git lfs track "*.psd"
git lfs track "*.zip" 
git lfs track "*.mp4"
git lfs track "docs/*.pdf"

# View tracked files
git lfs ls-files

# View LFS storage info
git lfs env
```

#### Migration to LFS
```bash
# Migrate existing files
git lfs migrate import --include="*.zip,*.pdf" --everything

# Export from LFS
git lfs migrate export --include="*.txt" --everything
```

### Partial Clone

For very large repositories, use partial clone features.

```bash
# Clone without files (metadata only)
git clone --filter=blob:none <url>

# Clone without large files
git clone --filter=blob:limit=10M <url>

# Clone specific paths only
git clone --filter=sparse:oid=<oid> <url>
```

### Shallow Clone Strategies

```bash
# Shallow clone (recent commits only)
git clone --depth 1 <url>

# Deepen shallow repository
git fetch --depth=10

# Convert to full repository
git fetch --unshallow
```

---

## Enterprise Workflows

### Multi-Repository Management

#### Git Submodules (Advanced)
```bash
# Add submodule with specific branch
git submodule add -b develop https://github.com/company/lib.git lib

# Update all submodules to latest
git submodule foreach 'git pull origin main'

# Work with submodule branches
cd submodule-dir
git checkout develop
git pull origin develop
cd ..
git add submodule-dir
git commit -m "Update submodule to latest develop"
```

#### Git Subtree (Alternative)
```bash
# Add subtree
git subtree add --prefix=vendor/library https://github.com/library/repo.git main --squash

# Update subtree
git subtree pull --prefix=vendor/library https://github.com/library/repo.git main --squash

# Contribute back
git subtree push --prefix=vendor/library https://github.com/library/repo.git main
```

### Monorepo Strategies

#### Sparse Checkout
```bash
# Enable sparse checkout
git config core.sparseCheckout true

# Define paths to include
echo "frontend/*" > .git/info/sparse-checkout
echo "shared/*" >> .git/info/sparse-checkout

# Apply sparse checkout
git read-tree -m -u HEAD
```

#### Subtree Commands for Monorepo
```bash
# Split out subdirectory to separate repo
git subtree split --prefix=frontend --annotate="(frontend) " -b frontend-only

# Push subtree to separate repository
git subtree push --prefix=frontend git@github.com:company/frontend.git main
```

### Automation and CI/CD Integration

#### Semantic Versioning with Git
```bash
#!/bin/bash
# scripts/auto-version.sh

# Get current version
current_version=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

# Determine version bump based on commit messages
if git log $current_version..HEAD --oneline | grep -q "BREAKING CHANGE\|feat!"; then
    # Major version bump
    new_version=$(echo $current_version | awk -F. '{$1=$1+1; $2=0; $3=0; print $1"."$2"."$3}' | sed 's/^v/v/')
elif git log $current_version..HEAD --oneline | grep -q "feat:"; then
    # Minor version bump  
    new_version=$(echo $current_version | awk -F. '{$2=$2+1; $3=0; print $1"."$2"."$3}')
else
    # Patch version bump
    new_version=$(echo $current_version | awk -F. '{$3=$3+1; print $1"."$2"."$3}')
fi

echo "Bumping version from $current_version to $new_version"
git tag -a $new_version -m "Release $new_version"
```

---

## Debugging and Recovery

### Git Bisect (Advanced)

#### Automated Bisect
```bash
# Start bisect
git bisect start HEAD v1.0

# Automated bisect with test script
git bisect run ./test-script.sh

# Example test script
#!/bin/bash
# test-script.sh
make test
if [ $? -eq 0 ]; then
    exit 0  # Good commit
else
    exit 1  # Bad commit
fi
```

#### Manual Bisect Process
```bash
git bisect start
git bisect bad                    # Current commit is bad
git bisect good v2.0             # v2.0 was good

# Git checks out middle commit
# Test the commit
git bisect good  # or git bisect bad

# Repeat until found
git bisect reset  # Return to original HEAD
```

### Recovery Techniques

#### Recovering Lost Commits
```bash
# View reflog for all references
git reflog --all

# Find dangling commits
git fsck --lost-found

# Recover specific commit
git show <commit-hash>
git branch recovery-branch <commit-hash>
```

#### Recovering Deleted Branches
```bash
# Find deleted branch in reflog
git reflog | grep "checkout:"

# Recreate branch
git branch recovered-branch <commit-hash>
```

#### Recovering from Force Push
```bash
# If you have local copy
git reflog
git reset --hard <previous-commit>
git push --force-with-lease

# If others were affected
git revert <bad-commit-range>
```

### Advanced Debugging

#### Blame with Line History
```bash
# Follow line history through renames/moves
git log --follow -p -S "function_name" -- filename

# Blame with commit ranges
git blame -L 10,20 filename

# Blame ignoring whitespace changes
git blame -w filename
```

#### Finding When Bug Was Introduced
```bash
# Search for when line was added/removed
git log -S "problematic_code" --source --all

# Search with regex
git log -G "regex_pattern" --source --all

# Search in specific file
git log --follow -p -- filename | grep -C 5 "search_term"
```

### Repository Forensics

#### Analyzing Repository Health
```bash
# Check object integrity
git fsck --full --strict

# Verify pack files
git verify-pack -v .git/objects/pack/*.idx

# Check for corruption
git cat-file --batch-all-objects --batch-check | sort | uniq -c | sort -rn
```

#### Performance Analysis
```bash
# Time Git operations
time git log --oneline | head -1000

# Memory usage
/usr/bin/time -v git checkout large-branch

# Repository statistics
git count-objects -v
```

---

## Git Worktrees

### Multiple Working Directories

```bash
# Create worktree for different branch
git worktree add ../project-feature feature/new-ui

# List worktrees
git worktree list

# Remove worktree
git worktree remove ../project-feature

# Prune deleted worktrees
git worktree prune
```

### Use Cases for Worktrees
- Testing different branches simultaneously
- Building different versions in parallel
- Code review without switching branches
- Maintaining multiple release versions

---

## Advanced Git Configuration

### Conditional Configuration
```bash
# .gitconfig
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work

[includeIf "gitdir:~/personal/"]
    path = ~/.gitconfig-personal
```

### Custom Diff and Merge Tools
```bash
# Configure external diff tool
git config --global diff.external /path/to/custom-diff

# Configure merge tool
git config --global merge.tool vimdiff
git config --global mergetool.vimdiff.cmd 'vimdiff $MERGED $LOCAL $BASE $REMOTE'
```

Remember: Advanced Git requires understanding the fundamentals first. Practice these concepts in safe environments before using them on important repositories! 🚀