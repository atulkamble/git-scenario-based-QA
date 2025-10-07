#!/bin/bash

# Git Scenario Setup Script
# This script sets up various Git scenarios for practice

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Git Scenario Setup Script"
echo "=================================="

# Function to create a basic repository
create_basic_repo() {
    local repo_name=$1
    local description=$2
    
    echo "📁 Creating repository: $repo_name"
    mkdir -p "$BASE_DIR/examples/$repo_name"
    cd "$BASE_DIR/examples/$repo_name"
    
    git init
    echo "# $repo_name" > README.md
    echo "" >> README.md
    echo "$description" >> README.md
    git add README.md
    git commit -m "Initial commit: $description"
    
    echo "✅ Repository $repo_name created successfully"
}

# Function to create conflict scenario
create_conflict_scenario() {
    local repo_name="conflict-scenario"
    
    echo "⚔️  Creating conflict scenario..."
    mkdir -p "$BASE_DIR/examples/$repo_name"
    cd "$BASE_DIR/examples/$repo_name"
    
    git init
    echo "# Conflict Resolution Practice" > README.md
    git add README.md
    git commit -m "Initial commit"
    
    # Create branch A
    git checkout -b feature-a
    cat > config.json << EOF
{
  "app_name": "GitPractice",
  "version": "1.0.0",
  "features": ["authentication", "dashboard"]
}
EOF
    git add config.json
    git commit -m "Add configuration with authentication and dashboard"
    
    # Create branch B
    git checkout main
    git checkout -b feature-b
    cat > config.json << EOF
{
  "app_name": "GitPractice",
  "version": "1.0.0",
  "features": ["user-management", "reporting"]
}
EOF
    git add config.json
    git commit -m "Add configuration with user management and reporting"
    
    # Setup for conflict
    git checkout main
    git merge feature-a
    
    echo "🎯 Conflict scenario ready!"
    echo "   To practice: git merge feature-b"
    echo "   This will create a merge conflict in config.json"
}

# Function to create rebase scenario
create_rebase_scenario() {
    local repo_name="rebase-scenario"
    
    echo "🔄 Creating rebase scenario..."
    mkdir -p "$BASE_DIR/examples/$repo_name"
    cd "$BASE_DIR/examples/$repo_name"
    
    git init
    echo "# Rebase Practice Repository" > README.md
    git add README.md
    git commit -m "Initial commit"
    
    # Create messy commit history
    git checkout -b feature/messy-history
    
    echo "console.log('debug message');" > debug.js
    git add debug.js
    git commit -m "add debug file"
    
    echo "function helper() { return 'test'; }" > utils.js
    git add utils.js
    git commit -m "utils"
    
    echo "console.log('more debug');" >> debug.js
    git add debug.js
    git commit -m "more debug"
    
    rm debug.js
    git add debug.js
    git commit -m "remove debug file"
    
    echo "// Helper functions for the application" > utils.js
    git add utils.js
    git commit -m "fix utils comment"
    
    echo "🎯 Rebase scenario ready!"
    echo "   To practice: git rebase -i HEAD~5"
    echo "   Clean up the messy commit history"
}

# Function to create submodule scenario
create_submodule_scenario() {
    local main_repo="main-project"
    local sub_repo="shared-library"
    
    echo "📦 Creating submodule scenario..."
    
    # Create shared library repo
    mkdir -p "$BASE_DIR/examples/$sub_repo"
    cd "$BASE_DIR/examples/$sub_repo"
    git init
    echo "# Shared Library" > README.md
    echo "export function sharedUtility() { return 'shared'; }" > index.js
    git add .
    git commit -m "Initial shared library"
    
    # Create main project repo
    mkdir -p "$BASE_DIR/examples/$main_repo"
    cd "$BASE_DIR/examples/$main_repo"
    git init
    echo "# Main Project" > README.md
    git add README.md
    git commit -m "Initial main project"
    
    # Add submodule
    git submodule add "../$sub_repo" lib
    git commit -m "Add shared library as submodule"
    
    echo "🎯 Submodule scenario ready!"
    echo "   Practice with: cd examples/$main_repo"
    echo "   Try: git submodule update --remote"
}

# Main menu
show_menu() {
    echo ""
    echo "Select scenario to create:"
    echo "1) Basic repository"
    echo "2) Conflict resolution scenario"
    echo "3) Rebase practice scenario"
    echo "4) Submodule scenario"
    echo "5) All scenarios"
    echo "6) Exit"
    echo ""
}

# Main execution
while true; do
    show_menu
    read -p "Enter your choice (1-6): " choice
    
    case $choice in
        1)
            read -p "Enter repository name: " repo_name
            read -p "Enter description: " description
            create_basic_repo "$repo_name" "$description"
            ;;
        2)
            create_conflict_scenario
            ;;
        3)
            create_rebase_scenario
            ;;
        4)
            create_submodule_scenario
            ;;
        5)
            echo "🔄 Creating all scenarios..."
            create_basic_repo "sample-project" "A sample project for Git practice"
            create_conflict_scenario
            create_rebase_scenario
            create_submodule_scenario
            echo "✅ All scenarios created!"
            ;;
        6)
            echo "👋 Goodbye!"
            exit 0
            ;;
        *)
            echo "❌ Invalid choice. Please try again."
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
done