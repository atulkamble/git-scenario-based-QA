#!/bin/bash

# Git Scenarios Test Runner
# Validates and tests all Git scenarios in the repository

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
TEST_DIR="$BASE_DIR/test-runs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Create test directory
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo_color $BLUE "🧪 Git Scenarios Test Runner"
echo_color $BLUE "============================"
echo ""

# Test 1: Basic Git Operations
test_basic_operations() {
    echo_color $YELLOW "Test 1: Basic Git Operations"
    
    local test_repo="test-basic-ops"
    rm -rf "$test_repo"
    mkdir "$test_repo"
    cd "$test_repo"
    
    # Test git init
    git init
    if [ $? -eq 0 ]; then
        echo_color $GREEN "✅ git init successful"
    else
        echo_color $RED "❌ git init failed"
        return 1
    fi
    
    # Test first commit
    echo "# Test Repository" > README.md
    git add README.md
    git commit -m "Initial commit"
    if [ $? -eq 0 ]; then
        echo_color $GREEN "✅ First commit successful"
    else
        echo_color $RED "❌ First commit failed"
        return 1
    fi
    
    # Test branch creation
    git checkout -b feature/test-branch
    if [ $? -eq 0 ]; then
        echo_color $GREEN "✅ Branch creation successful"
    else
        echo_color $RED "❌ Branch creation failed"
        return 1
    fi
    
    cd ..
    echo_color $GREEN "✅ Basic operations test completed"
    echo ""
}

# Test 2: Conflict Resolution
test_conflict_resolution() {
    echo_color $YELLOW "Test 2: Conflict Resolution"
    
    local test_repo="test-conflicts"
    rm -rf "$test_repo"
    mkdir "$test_repo"
    cd "$test_repo"
    
    git init
    echo "# Conflict Test" > README.md
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
    
    # Merge one branch
    git checkout main
    git merge branch-a
    
    # Try to merge the other (should create conflict)
    git merge branch-b || true
    
    # Check if conflict exists
    if git status | grep -q "both modified"; then
        echo_color $GREEN "✅ Conflict created successfully"
        
        # Resolve conflict
        cat > README.md << EOF
# Conflict Test
Change from branch A
Change from branch B
EOF
        git add README.md
        git commit -m "Resolve merge conflict"
        echo_color $GREEN "✅ Conflict resolved successfully"
    else
        echo_color $RED "❌ Conflict not created as expected"
        return 1
    fi
    
    cd ..
    echo_color $GREEN "✅ Conflict resolution test completed"
    echo ""
}

# Test 3: Rebase Operations
test_rebase_operations() {
    echo_color $YELLOW "Test 3: Rebase Operations"
    
    local test_repo="test-rebase"
    rm -rf "$test_repo"
    mkdir "$test_repo"
    cd "$test_repo"
    
    git init
    echo "Base commit" > file.txt
    git add file.txt
    git commit -m "Base commit"
    
    # Create feature branch with multiple commits
    git checkout -b feature/rebase-test
    for i in {1..3}; do
        echo "Feature commit $i" >> file.txt
        git add file.txt
        git commit -m "Feature commit $i"
    done
    
    # Add commit to main
    git checkout main
    echo "Main branch change" >> file.txt
    git add file.txt
    git commit -m "Main branch change"
    
    # Rebase feature branch
    git checkout feature/rebase-test
    git rebase main
    
    if [ $? -eq 0 ]; then
        echo_color $GREEN "✅ Rebase successful"
    else
        echo_color $RED "❌ Rebase failed"
        return 1
    fi
    
    cd ..
    echo_color $GREEN "✅ Rebase operations test completed"
    echo ""
}

# Test 4: Stash Operations
test_stash_operations() {
    echo_color $YELLOW "Test 4: Stash Operations"
    
    local test_repo="test-stash"
    rm -rf "$test_repo"
    mkdir "$test_repo"
    cd "$test_repo"
    
    git init
    echo "Initial content" > work.txt
    git add work.txt
    git commit -m "Initial commit"
    
    # Make changes
    echo "Work in progress" >> work.txt
    echo "More changes" > new-file.txt
    
    # Stash changes
    git stash save "WIP: testing stash functionality"
    
    if [ $? -eq 0 ]; then
        echo_color $GREEN "✅ Stash save successful"
    else
        echo_color $RED "❌ Stash save failed"
        return 1
    fi
    
    # Check if working directory is clean
    if [ -z "$(git status --porcelain)" ]; then
        echo_color $GREEN "✅ Working directory cleaned by stash"
    else
        echo_color $RED "❌ Working directory not clean after stash"
        return 1
    fi
    
    # Apply stash
    git stash pop
    
    if [ $? -eq 0 ]; then
        echo_color $GREEN "✅ Stash pop successful"
    else
        echo_color $RED "❌ Stash pop failed"
        return 1
    fi
    
    cd ..
    echo_color $GREEN "✅ Stash operations test completed"
    echo ""
}

# Test 5: Cherry-pick Operations
test_cherry_pick() {
    echo_color $YELLOW "Test 5: Cherry-pick Operations"
    
    local test_repo="test-cherry-pick"
    rm -rf "$test_repo"
    mkdir "$test_repo"
    cd "$test_repo"
    
    git init
    echo "Base" > file.txt
    git add file.txt
    git commit -m "Base commit"
    
    # Create feature branch with commits
    git checkout -b feature/source
    echo "Feature A" >> file.txt
    git add file.txt
    git commit -m "Add feature A"
    
    echo "Feature B" >> file.txt
    git add file.txt
    feature_b_commit=$(git commit -m "Add feature B" && git rev-parse HEAD)
    
    echo "Feature C" >> file.txt
    git add file.txt
    git commit -m "Add feature C"
    
    # Cherry-pick specific commit to main
    git checkout main
    git cherry-pick $feature_b_commit
    
    if [ $? -eq 0 ]; then
        echo_color $GREEN "✅ Cherry-pick successful"
    else
        echo_color $RED "❌ Cherry-pick failed"
        return 1
    fi
    
    # Verify cherry-pick worked
    if git log --oneline | grep -q "Add feature B"; then
        echo_color $GREEN "✅ Cherry-picked commit found in main"
    else
        echo_color $RED "❌ Cherry-picked commit not found"
        return 1
    fi
    
    cd ..
    echo_color $GREEN "✅ Cherry-pick operations test completed"
    echo ""
}

# Test 6: Tag Operations
test_tag_operations() {
    echo_color $YELLOW "Test 6: Tag Operations"
    
    local test_repo="test-tags"
    rm -rf "$test_repo"
    mkdir "$test_repo"
    cd "$test_repo"
    
    git init
    echo "Version 1.0" > version.txt
    git add version.txt
    git commit -m "Version 1.0 release"
    
    # Create lightweight tag
    git tag v1.0
    
    # Create annotated tag
    git tag -a v1.0.1 -m "Version 1.0.1 with bug fixes"
    
    # List tags
    if git tag | grep -q "v1.0"; then
        echo_color $GREEN "✅ Tags created successfully"
    else
        echo_color $RED "❌ Tags not created"
        return 1
    fi
    
    # Show tag info
    git show v1.0.1 > /dev/null
    if [ $? -eq 0 ]; then
        echo_color $GREEN "✅ Annotated tag info accessible"
    else
        echo_color $RED "❌ Tag info not accessible"
        return 1
    fi
    
    cd ..
    echo_color $GREEN "✅ Tag operations test completed"
    echo ""
}

# Test 7: Reset Operations
test_reset_operations() {
    echo_color $YELLOW "Test 7: Reset Operations"
    
    local test_repo="test-reset"
    rm -rf "$test_repo"
    mkdir "$test_repo"
    cd "$test_repo"
    
    git init
    echo "Commit 1" > file.txt
    git add file.txt
    git commit -m "Commit 1"
    
    echo "Commit 2" > file.txt
    git add file.txt
    git commit -m "Commit 2"
    
    echo "Commit 3" > file.txt
    git add file.txt
    git commit -m "Commit 3"
    
    # Test soft reset
    git reset --soft HEAD~1
    
    if git status | grep -q "Changes to be committed"; then
        echo_color $GREEN "✅ Soft reset successful (changes staged)"
    else
        echo_color $RED "❌ Soft reset failed"
        return 1
    fi
    
    # Recommit
    git commit -m "Commit 3 (recommitted)"
    
    # Test mixed reset
    git reset --mixed HEAD~1
    
    if git status | grep -q "Changes not staged"; then
        echo_color $GREEN "✅ Mixed reset successful (changes unstaged)"
    else
        echo_color $RED "❌ Mixed reset failed"
        return 1
    fi
    
    cd ..
    echo_color $GREEN "✅ Reset operations test completed"
    echo ""
}

# Run all tests
run_all_tests() {
    local failed_tests=0
    
    test_basic_operations || ((failed_tests++))
    test_conflict_resolution || ((failed_tests++))
    test_rebase_operations || ((failed_tests++))
    test_stash_operations || ((failed_tests++))
    test_cherry_pick || ((failed_tests++))
    test_tag_operations || ((failed_tests++))
    test_reset_operations || ((failed_tests++))
    
    echo_color $BLUE "=============================="
    echo_color $BLUE "Test Summary"
    echo_color $BLUE "=============================="
    
    if [ $failed_tests -eq 0 ]; then
        echo_color $GREEN "🎉 All tests passed! ($((7 - failed_tests))/7)"
    else
        echo_color $RED "❌ $failed_tests test(s) failed out of 7"
        echo_color $YELLOW "✅ $((7 - failed_tests)) test(s) passed"
    fi
    
    return $failed_tests
}

# Validate repository structure
validate_repository_structure() {
    echo_color $YELLOW "Validating repository structure..."
    
    local required_files=(
        "README.md"
        "scenarios/beginner/basic-operations.md"
        "scenarios/intermediate/conflict-resolution-and-history.md"
        "scenarios/intermediate/remote-management.md"
        "scenarios/advanced/enterprise-workflows.md"
        "scripts/setup-scenarios.sh"
        "scripts/git-utils.sh"
        "resources/interview-questions.md"
        "resources/git-cheatsheet.md"
    )
    
    local missing_files=0
    
    for file in "${required_files[@]}"; do
        if [ -f "$BASE_DIR/$file" ]; then
            echo_color $GREEN "✅ $file"
        else
            echo_color $RED "❌ $file (missing)"
            ((missing_files++))
        fi
    done
    
    if [ $missing_files -eq 0 ]; then
        echo_color $GREEN "✅ Repository structure validation passed"
    else
        echo_color $RED "❌ Repository structure validation failed ($missing_files missing files)"
    fi
    
    echo ""
}

# Main execution
main() {
    validate_repository_structure
    
    echo_color $BLUE "Starting Git functionality tests..."
    echo ""
    
    run_all_tests
    
    # Cleanup
    echo ""
    echo_color $BLUE "Cleaning up test directory..."
    cd "$BASE_DIR"
    rm -rf "$TEST_DIR"
    echo_color $GREEN "✅ Cleanup completed"
}

# Handle script arguments
case "${1:-run}" in
    "validate")
        validate_repository_structure
        ;;
    "test")
        run_all_tests
        ;;
    "run"|*)
        main
        ;;
esac