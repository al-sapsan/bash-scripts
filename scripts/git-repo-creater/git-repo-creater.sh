#!/bin/bash -
#===============================================================================
#
#          FILE: git-repo-creator.sh
#
#         USAGE: ./git-repo-creator.sh
#
#   DESCRIPTION: Enhanced GitHub Repository Creation Tool
#
#       OPTIONS: 
#  REQUIREMENTS: git, curl (for GitHub API features)
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Your Name
#       CREATED: $(date +"%Y-%m-%d %H:%M:%S")
#      REVISION: 2.0
#===============================================================================

set -o nounset                              # Treat unset variables as an error
set -o errexit                              # Exit on error
trap 'echo "Error at line $LINENO. Exit code: $?"' ERR

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "$1 is not installed. Please install it first."
        exit 1
    fi
}

# Check prerequisites
check_command git

echo "=========================================="
echo "   🚀 Enhanced GitHub Repo Creator   "
echo "=========================================="

# --- Step 1: Choose folder location ---
while true; do
    read -p "Create repo in current directory? (y/n/help): " use_current
    
    case "$use_current" in
        [Yy]*)
            repo_path="$(pwd)"
            print_info "Using current directory: $repo_path"
            break
            ;;
        [Nn]*)
            read -p "Enter full path where the repo should be created: " repo_path
            
            # Expand tilde to home directory
            repo_path="${repo_path/#\~/$HOME}"
            
            # Check if path contains repository name
            if [[ "$repo_path" =~ /[^/]+$ ]]; then
                read -p "Path ends with a name. Use it as repository name? (y/n): " use_path_name
                if [[ "$use_path_name" =~ ^[Yy]$ ]]; then
                    suggested_name=$(basename "$repo_path")
                fi
            fi
            
            # Create directory if it doesn't exist
            if [ ! -d "$repo_path" ]; then
                print_info "Creating directory: $repo_path"
                mkdir -p "$repo_path"
                print_success "Directory created successfully"
            fi
            break
            ;;
        [Hh]elp)
            echo "y/Y - Use current directory"
            echo "n/N - Specify custom path"
            continue
            ;;
        *)
            print_error "Invalid choice. Please enter y/n or help"
            continue
            ;;
    esac
done

# --- Step 2: Ask for repository name ---
if [ -z "${suggested_name:-}" ]; then
    read -p "Enter repository name: " repo_name
else
    read -p "Enter repository name [default: $suggested_name]: " repo_name_input
    repo_name="${repo_name_input:-$suggested_name}"
fi

# Validate repository name
if [[ ! "$repo_name" =~ ^[a-zA-Z0-9_.-]+$ ]]; then
    print_error "Invalid repository name. Only letters, numbers, dots, dashes and underscores allowed."
    exit 1
fi

full_path="$repo_path/$repo_name"

# Check if folder exists
if [ -d "$full_path" ]; then
    print_warning "Folder '$full_path' already exists."
    read -p "Do you want to use it? (y/n): " use_existing
    
    if [[ ! "$use_existing" =~ ^[Yy]$ ]]; then
        print_info "Exiting..."
        exit 1
    fi
else
    # Create repository folder
    mkdir -p "$full_path"
    print_success "Created repository folder: $full_path"
fi

cd "$full_path" || {
    print_error "Failed to navigate to $full_path"
    exit 1
}

# --- Step 3: Initialize Git ---
print_info "Initializing Git repository..."
git init
print_success "Initialized empty Git repository"

# --- Step 4: Ask for README.md creation ---
read -p "Create README.md? (y/n): " create_readme
if [[ "$create_readme" =~ ^[Yy]$ ]]; then
    # Ask for README content
    read -p "Enter project description (optional): " project_description
    read -p "Enter installation instructions (optional): " install_instructions
    
    cat <<EOL > README.md
# $repo_name

$( [ -n "$project_description" ] && echo -e "\n## Description\n$project_description" )

$( [ -n "$install_instructions" ] && echo -e "## Installation\n$install_instructions" )

## Usage

\`\`\`bash
# Add usage examples here
\`\`\`

## License

[Add your license here]
EOL
    
    git add README.md
    print_success "README.md created and staged"
fi

# --- Step 5: Ask for .gitignore creation ---
read -p "Create .gitignore? (y/n): " create_gitignore
if [[ "$create_gitignore" =~ ^[Yy]$ ]]; then
    echo "Select language/template:"
    echo "1) Python"
    echo "2) Node.js"
    echo "3) Java"
    echo "4) Go"
    echo "5) Rust"
    echo "6) Custom"
    read -p "Enter choice (1-6): " gitignore_choice
    
    case $gitignore_choice in
        1)
            gitignore_content="__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.env
.DS_Store"
            ;;
        2)
            gitignore_content="node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.env
.DS_Store"
            ;;
        3)
            gitignore_content="*.class
*.jar
*.war
*.ear
target/
.env
.DS_Store"
            ;;
        4)
            gitignore_content="bin/
vendor/
.env
.DS_Store"
            ;;
        5)
            gitignore_content="target/
**/*.rs.bk
.env
.DS_Store"
            ;;
        6)
            read -p "Enter custom .gitignore content (press Ctrl+D when done): " custom_content
            gitignore_content="$custom_content"
            ;;
        *)
            gitignore_content=".env
.DS_Store"
            ;;
    esac
    
    echo "$gitignore_content" > .gitignore
    git add .gitignore
    print_success ".gitignore created and staged"
fi

# --- Step 6: Create initial files based on template ---
read -p "Create initial project structure? (y/n): " create_structure
if [[ "$create_structure" =~ ^[Yy]$ ]]; then
    # Create basic directory structure
    mkdir -p src tests docs
    
    # Create a basic Python or shell starter file
    read -p "Create starter file? (python/bash/none): " starter_file
    case $starter_file in
        python|py)
            cat <<EOL > src/main.py
#!/usr/bin/env python3
"""
$repo_name - Main module
"""

def main():
    print("Hello from $repo_name!")

if __name__ == "__main__":
    main()
EOL
            chmod +x src/main.py
            git add src/main.py
            ;;
        bash|sh)
            cat <<EOL > src/main.sh
#!/bin/bash
# $repo_name - Main script

echo "Hello from $repo_name!"
EOL
            chmod +x src/main.sh
            git add src/main.sh
            ;;
    esac
fi

# --- Step 7: First commit ---
print_info "Creating initial commit..."
read -p "Enter initial commit message [default: Initial commit]: " commit_msg
commit_msg="${commit_msg:-Initial commit}"
git commit -m "$commit_msg"
print_success "Initial commit created: $commit_msg"

# --- Step 8: Connect to GitHub ---
read -p "Do you want to connect to GitHub? (y/n): " connect_github
if [[ "$connect_github" =~ ^[Yy]$ ]]; then
    read -p "Enter GitHub username: " gh_user
    read -p "Enter GitHub repository name [default: $repo_name]: " gh_repo_input
    gh_repo="${gh_repo_input:-$repo_name}"
    
    # Ask for protocol
    while true; do
        read -p "Use SSH or HTTPS? (ssh/https): " gh_type
        case $gh_type in
            ssh|SSH)
                remote_url="git@github.com:$gh_user/$gh_repo.git"
                break
                ;;
            https|HTTPS)
                remote_url="https://github.com/$gh_user/$gh_repo.git"
                break
                ;;
            *)
                print_error "Please enter 'ssh' or 'https'"
                continue
                ;;
        esac
    done
    
    # Set remote
    git remote add origin "$remote_url" 2>/dev/null || {
        read -p "Remote 'origin' already exists. Replace it? (y/n): " replace_remote
        if [[ "$replace_remote" =~ ^[Yy]$ ]]; then
            git remote remove origin
            git remote add origin "$remote_url"
        fi
    }
    
    print_success "Connected to GitHub remote: $remote_url"
    
    # --- Step 9: Push to GitHub ---
    read -p "Push to GitHub? (y/n): " push_github
    
    if [[ "$push_github" =~ ^[Yy]$ ]]; then
        # Set branch name
        read -p "Enter branch name [default: main]: " branch_name
        branch_name="${branch_name:-main}"
        
        git branch -M "$branch_name"
        
        # Try to push
        if git push -u origin "$branch_name"; then
            print_success "✅ Repository successfully pushed to GitHub!"
            echo "🔗 You can open it at:"
            echo "   https://github.com/$gh_user/$gh_repo"
            
            # Optional: Open in browser
            read -p "Open repository in browser? (y/n): " open_browser
            if [[ "$open_browser" =~ ^[Yy]$ ]]; then
                if command -v xdg-open &> /dev/null; then
                    xdg-open "https://github.com/$gh_user/$gh_repo"
                elif command -v open &> /dev/null; then
                    open "https://github.com/$gh_user/$gh_repo"
                else
                    print_info "Browser opening not supported on this system"
                fi
            fi
        else
            print_warning "Push failed. The repository might not exist on GitHub."
            print_info "You can create it manually at: https://github.com/new"
            print_info "Then run: git push -u origin $branch_name"
        fi
    fi
fi

# --- Step 10: Create additional configurations ---
read -p "Create LICENSE file? (y/n): " create_license
if [[ "$create_license" =~ ^[Yy]$ ]]; then
    echo "Select license:"
    echo "1) MIT"
    echo "2) Apache 2.0"
    echo "3) GPLv3"
    echo "4) BSD 3-Clause"
    echo "5) Custom"
    read -p "Enter choice (1-5): " license_choice
    
    case $license_choice in
        1)
            curl -s https://raw.githubusercontent.com/spdx/license-list-data/main/text/MIT.txt > LICENSE 2>/dev/null || \
            echo "MIT License text not available. Please add manually." > LICENSE
            ;;
        2)
            curl -s https://www.apache.org/licenses/LICENSE-2.0.txt > LICENSE 2>/dev/null || \
            echo "Apache 2.0 License text not available. Please add manually." > LICENSE
            ;;
        3)
            curl -s https://www.gnu.org/licenses/gpl-3.0.txt > LICENSE 2>/dev/null || \
            echo "GPLv3 License text not available. Please add manually." > LICENSE
            ;;
        4)
            curl -s https://opensource.org/licenses/BSD-3-Clause > LICENSE 2>/dev/null || \
            echo "BSD 3-Clause License text not available. Please add manually." > LICENSE
            ;;
        5)
            read -p "Enter custom license text (press Ctrl+D when done): " custom_license
            echo "$custom_license" > LICENSE
            ;;
    esac
    
    if [ -f "LICENSE" ]; then
        git add LICENSE
        print_success "LICENSE file created and staged"
    fi
fi

# Summary
echo "=========================================="
echo "   📊 Repository Creation Summary   "
echo "=========================================="
echo "📍 Location: $full_path"
echo "📁 Contents:"
ls -la
echo ""
print_success "Repository setup complete! 🎉"
print_info "Next steps:"
echo "   cd $full_path"
echo "   # Make your changes"
echo "   git add ."
echo "   git commit -m 'Your message'"
echo "   git push"
echo "=========================================="