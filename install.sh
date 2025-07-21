#!/bin/sh

# Dotfiles installation script
# This script creates symbolic links from dotfiles to the home directory
# and backs up existing files to prevent data loss
# Compatible with POSIX sh

set -eu

readonly SCRIPT_NAME="$(basename "$0")"
readonly DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly BACKUP_DIR="$HOME/.dotbackup"

# Display usage information
show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Install dotfiles by creating symbolic links in the home directory.

OPTIONS:
    -h, --help     Show this help message and exit
    -d, --debug    Enable debug mode (verbose output)

DESCRIPTION:
    This script will:
    1. Create a backup directory (~/.dotbackup) if it doesn't exist
    2. Back up existing dotfiles to the backup directory
    3. Create symbolic links from dotfiles to the home directory
    4. Handle nested directory structures (e.g., .config/)
    5. Execute all .sh files in the scripts/ directory

STRUCTURE:
    This script expects the following dotfiles structure:
    dotfiles/
    ├── install.sh (this script)
    ├── .config/
    └── scripts/

EOF
}

# Create backup directory if it doesn't exist
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "Creating backup directory: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
    fi
}

# Create directory structure if it doesn't exist
ensure_directory() {
    target_dir="$1"
    if [ ! -d "$target_dir" ]; then
        echo "Creating directory: $target_dir"
        mkdir -p "$target_dir"
    fi
}

# Get relative path from target_path to HOME
get_relative_path_from_home() {
    path="$1"
    # HOMEディレクトリからの相対パスを計算
    relative_path="$(realpath -m --relative-to="$HOME" "$path")"
    echo "$relative_path"
}

# Back up existing file or directory to backup directory
backup_existing_item() {
    item_path="$1"
    
    relative_path="$(get_relative_path_from_home "$item_path")"

    if [ -e "$item_path" ] && [ ! -L "$item_path" ]; then
        backup_target="$(join_paths "$BACKUP_DIR" "$relative_path")"
        backup_dir="$(dirname "$backup_target")"
        
        echo "Backing up existing item: $relative_path"
        ensure_directory "$backup_dir"
        mv "$item_path" "$backup_target"
    elif [ -L "$item_path" ]; then
        echo "Removing existing symlink: $relative_path"
        rm -f "$item_path"
    fi
}

# Create symbolic link with proper directory structure
create_symlink() {
    source_path="$1"
    target_path="$2"
    echo "...create_symlink - source_path: $source_path, target_path: $target_path"

    # Ensure target directory exists
    target_dir="$(dirname "$target_path")"
    ensure_directory "$target_dir"
    
    # Backup existing item
    backup_existing_item "$target_path"
    
    relative_path="$(get_relative_path_from_home "$target_path")"
    echo "Creating symlink: $relative_path"
    ln -sf "$source_path" "$target_path"
}

# Check if a file/directory should be skipped
should_skip_item() {
    item_name="$1"
    case "$item_name" in
        install.sh|scripts|.git|.gitignore|.DS_Store|README*|LICENSE*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Check if a file/directory should be created as a symlink without directories
should_create_symlink_without_dirs() {
    item_name="$1"
    case "$item_name" in
        .bashrc|.zshrc)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Normalize path by removing trailing slashes and ensuring proper format
normalize_path() {
    path="$1"
    # Remove trailing slashes except for root directory
    if [ "$path" != "/" ]; then
        path="${path%/}"
    fi
    echo "$path"
}

# Join two paths safely, handling slashes properly
join_paths() {
    base="$1"
    name="$2"
    
    # Normalize base path
    base="$(normalize_path "$base")"
    
    # Remove leading slashes from name
    name="${name#/}"
    
    # Join paths
    if [ -z "$base" ] || [ "$base" = "/" ]; then
        echo "/$name"
    else
        echo "$base/$name"
    fi
}

# Process a single item (file or directory)
link_dotfiles_process_item() {
    item="$1"
    target_base="$2"
    echo "...link_dotfiles_process_item - item: $item, target_base: $target_base"
    
    # Skip if item doesn't exist
    [ ! -e "$item" ] && return 0
    
    item_name="$(basename "$item")"

    target_path="$(join_paths "$target_base" "$item_name")"
    relative_path="$(get_relative_path_from_home "$target_path")"

    # Skip unwanted items
    if should_skip_item "$item_name"; then
        echo "Skipping: $relative_path"
        return 0
    fi

    if [ -d "$item" ]; then
        echo "Processing directory: $relative_path/"
        # Recursively process subdirectory
        link_dotfiles_process_directory "$item" "$target_path"
    else
        if should_create_symlink_without_dirs "$item_name"; then
            echo "Should create symlink without dirs: $item_name"
            target_path="$(join_paths "$HOME" "$item_name")"
        fi
        # Create symlink for file
        create_symlink "$item" "$target_path"
    fi
}

# Recursively process directory contents
link_dotfiles_process_directory() {
    source_dir="$1"
    target_base="$2"
    
    # Process all items in the directory (non-hidden)
    for item in "$source_dir"/*; do
        link_dotfiles_process_item "$item" "$target_base"
    done
    
    # Process hidden files/directories
    for item in "$source_dir"/.??*; do
        link_dotfiles_process_item "$item" "$target_base"
    done
}

# Main function to link dotfiles to home directory
link_dotfiles() {    
    echo "Dotfiles directory: $DOTFILES_DIR"
    echo "Target directory: $HOME"
    
    # Prevent linking if dotfiles are already in home directory
    if [ "$HOME" = "$DOTFILES_DIR" ]; then
        echo "Warning: Dotfiles directory is the same as home directory. Skipping symlink creation."
        return 0
    fi
    
    echo "Starting dotfiles installation..."
    create_backup_dir
    
    # Process the dotfiles directory
    link_dotfiles_process_directory "$DOTFILES_DIR" "$HOME"
    
    echo "Dotfiles installation completed"
}

# Execute scripts in the scripts directory
execute_scripts() {
    scripts_dir="$(join_paths "$DOTFILES_DIR" "scripts")"
    
    # Check if scripts directory exists
    if [ ! -d "$scripts_dir" ]; then
        echo "No scripts directory found, skipping script execution"
        return 0
    fi
    
    echo "Executing scripts from: $scripts_dir"
    
    # Find and execute all .sh files in scripts directory
    script_count=0
    for script_file in "$scripts_dir"/*.sh; do
        # Skip if glob doesn't match
        [ ! -f "$script_file" ] && continue
        
        script_name="$(basename "$script_file")"
        echo "Executing script: $script_name"
        
        # Make script executable if it isn't already
        if [ ! -x "$script_file" ]; then
            echo "Making $script_name executable"
            chmod +x "$script_file"
        fi
        
        # Execute the script
        if "$script_file"; then
            echo "✓ Successfully executed: $script_name"
            script_count=$((script_count + 1))
        else
            echo "✗ Failed to execute: $script_name" >&2
            echo "Warning: Script execution failed, but continuing installation" >&2
        fi
        echo ""
    done
    
    if [ $script_count -gt 0 ]; then
        echo "Executed $script_count script(s) successfully"
    else
        echo "No executable scripts found in scripts directory"
    fi
}

# Check if current shell supports specific features
check_shell_capabilities() {
    # Test for debug mode support
    if [ "${DEBUG_MODE:-}" = "1" ]; then
        # Try to enable debug mode if supported
        if (set -x) 2>/dev/null; then
            set -x
        else
            echo "Warning: Debug mode not fully supported in this shell"
        fi
    fi
}

# Main execution
main() {

    # Remove flag file if it exists
    rm -f ~/.dotfiles-installed

    # Parse command line arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--debug)
                echo "Debug mode enabled"
                DEBUG_MODE=1
                check_shell_capabilities
                ;;
            -*)
                echo "Error: Unknown option '$1'" >&2
                echo "Use '$SCRIPT_NAME --help' for usage information." >&2
                exit 1
                ;;
            *)
                echo "Error: Unexpected argument '$1'" >&2
                echo "Use '$SCRIPT_NAME --help' for usage information." >&2
                exit 1
                ;;
        esac
        shift
    done
    
    # Execute main installation steps
    link_dotfiles
    execute_scripts

    # Create flag file NOTE: 
    touch ~/.dotfiles-installed
    
    # Success message with colored output (if supported)
    if [ -t 1 ] && command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1; then
        # Terminal supports colors
        echo ""
        echo "$(tput setaf 2)$(tput bold)✓ Dotfiles installation completed successfully!$(tput sgr0)"
    else
        # Fallback for terminals without color support
        echo ""
        echo "✓ Dotfiles installation completed successfully!"
    fi
    echo "Backup files are stored in: $BACKUP_DIR"
}

# Execute main function with all arguments
main "$@"