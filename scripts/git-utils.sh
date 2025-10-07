#!/bin/bash

# Git Utility Functions
# Collection of useful Git utility functions and shortcuts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display colored output
echo_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if we're in a Git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo_color $RED "Error: Not in a Git repository"
        exit 1
    fi
}

# Function to display Git status with colors
git_status_pretty() {
    check_git_repo
    
    echo_color $BLUE "=== Git Repository Status ==="
    echo ""
    
    # Current branch
    current_branch=$(git branch --show-current)
    echo_color $GREEN "Current branch: $current_branch"
    
    # Ahead/behind info
    upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if [ -n "$upstream" ]; then
        ahead=$(git rev-list --count HEAD@{upstream}..HEAD 2>/dev/null || echo "0")
        behind=$(git rev-list --count HEAD..HEAD@{upstream} 2>/dev/null || echo "0")
        
        if [ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ]; then
            echo_color $YELLOW "Ahead: $ahead, Behind: $behind"
        else
            echo_color $GREEN "Up to date with $upstream"
        fi
    fi
    
    echo ""
    
    # Git status
    git status --short --branch
    
    echo ""
    
    # Recent commits
    echo_color $BLUE "Recent commits:"
    git log --oneline -5
}

# Function to create a new feature branch
new_feature() {
    check_git_repo
    
    if [ -z "$1" ]; then
        echo_color $RED "Usage: new_feature <feature-name>"
        return 1
    fi
    
    feature_name=$1
    branch_name="feature/$feature_name"
    
    echo_color $BLUE "Creating new feature branch: $branch_name"
    
    # Ensure we're on main/master
    main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    git checkout "$main_branch"
    git pull origin "$main_branch"
    
    # Create and switch to feature branch
    git checkout -b "$branch_name"
    
    echo_color $GREEN "✅ Feature branch '$branch_name' created and checked out"
}

# Function to finish a feature (merge and cleanup)
finish_feature() {
    check_git_repo
    
    current_branch=$(git branch --show-current)
    
    if [[ ! "$current_branch" =~ ^feature/ ]]; then
        echo_color $RED "Error: Not on a feature branch"
        return 1
    fi
    
    echo_color $BLUE "Finishing feature branch: $current_branch"
    
    # Push feature branch
    git push origin "$current_branch"
    
    # Switch to main and merge
    main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    git checkout "$main_branch"
    git pull origin "$main_branch"
    git merge --no-ff "$current_branch"
    
    # Push merged changes
    git push origin "$main_branch"
    
    # Clean up
    git branch -d "$current_branch"
    git push origin --delete "$current_branch"
    
    echo_color $GREEN "✅ Feature '$current_branch' merged and cleaned up"
}

# Function to create a quick commit
quick_commit() {
    check_git_repo
    
    if [ -z "$1" ]; then
        echo_color $RED "Usage: quick_commit <commit-message>"
        return 1
    fi
    
    commit_message=$1
    
    # Add all changes
    git add .
    
    # Show what will be committed
    echo_color $BLUE "Changes to be committed:"
    git diff --cached --stat
    
    read -p "Proceed with commit? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        git commit -m "$commit_message"
        echo_color $GREEN "✅ Committed: $commit_message"
    else
        git reset
        echo_color $YELLOW "Commit cancelled"
    fi
}

# Function to undo last commit (safe)
undo_last_commit() {
    check_git_repo
    
    last_commit=$(git log -1 --oneline)
    echo_color $YELLOW "Last commit: $last_commit"
    
    read -p "Undo this commit? (keep changes) (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        git reset --soft HEAD~1
        echo_color $GREEN "✅ Last commit undone (changes kept in staging)"
    else
        echo_color $BLUE "Operation cancelled"
    fi
}

# Function to sync with remote
sync_remote() {
    check_git_repo
    
    echo_color $BLUE "Syncing with remote..."
    
    current_branch=$(git branch --show-current)
    
    # Fetch all changes
    git fetch --all --prune
    
    # Pull current branch
    if git rev-parse --abbrev-ref --symbolic-full-name @{u} > /dev/null 2>&1; then
        git pull origin "$current_branch"
        echo_color $GREEN "✅ Synced branch '$current_branch' with remote"
    else
        echo_color $YELLOW "No upstream set for '$current_branch'"
    fi
    
    # Show status
    git_status_pretty
}

# Function to clean up merged branches
cleanup_branches() {
    check_git_repo
    
    echo_color $BLUE "Cleaning up merged branches..."
    
    # Get main branch
    main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    
    # Switch to main
    git checkout "$main_branch"
    
    # Delete merged local branches
    merged_branches=$(git branch --merged | grep -v "\*\|$main_branch\|develop" || true)
    
    if [ -n "$merged_branches" ]; then
        echo_color $YELLOW "Merged branches to delete:"
        echo "$merged_branches"
        
        read -p "Delete these branches? (y/N): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            echo "$merged_branches" | xargs -n 1 git branch -d
            echo_color $GREEN "✅ Merged branches deleted"
        fi
    else
        echo_color $GREEN "No merged branches to clean up"
    fi
    
    # Prune remote branches
    git remote prune origin
    echo_color $GREEN "✅ Remote branches pruned"
}

# Function to show Git aliases
show_aliases() {
    echo_color $BLUE "Useful Git aliases to add to your ~/.gitconfig:"
    echo ""
    cat << 'EOF'
[alias]
    st = status --short --branch
    co = checkout
    br = branch
    ci = commit
    ca = commit --amend
    df = diff
    dc = diff --cached
    lg = log --oneline --graph --decorate --all
    last = log -1 HEAD
    unstage = reset HEAD --
    visual = !gitk
    tree = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
    undo = reset --soft HEAD~1
    save = !git add -A && git commit -m 'SAVEPOINT'
    wip = !git add -u && git commit -m "WIP"
    wipe = !git add -A && git commit -qm 'WIPE SAVEPOINT' && git reset HEAD~1 --hard
EOF
}

# Function to display help
show_help() {
    echo_color $BLUE "Git Utility Functions"
    echo ""
    echo "Available functions:"
    echo "  git_status_pretty     - Show enhanced Git status"
    echo "  new_feature <name>    - Create new feature branch"
    echo "  finish_feature        - Merge and cleanup feature branch"
    echo "  quick_commit <msg>    - Add all and commit with message"
    echo "  undo_last_commit      - Undo last commit (keep changes)"
    echo "  sync_remote           - Sync with remote repository"
    echo "  cleanup_branches      - Remove merged branches"
    echo "  show_aliases          - Display useful Git aliases"
    echo "  show_help             - Show this help"
    echo ""
    echo "Usage examples:"
    echo "  new_feature user-auth"
    echo "  quick_commit 'Fix login bug'"
    echo "  finish_feature"
}

# Export functions if script is sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f git_status_pretty new_feature finish_feature quick_commit
    export -f undo_last_commit sync_remote cleanup_branches show_aliases show_help
    echo_color $GREEN "Git utility functions loaded! Use 'show_help' to see available commands."
else
    # If script is executed directly, show help
    show_help
fi