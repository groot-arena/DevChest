#!/usr/bin/env bash
# install.sh - Script to install multiple tools

#Exit on error, undefined variables, or pipeline failure
set -euo pipefail

# Check if script is run with sudo
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root (use sudo)." >&2
    exit 1
fi

# Declare variables
REPO_URL="https://github.com/groot-arena/DevChest"
TEMP_DIR=$(mktemp -d -t DevChest-XXXX)
IS_INSTALLATION_SUCCESS=true
OS_NAME=
OS_VERSION=

# Function to display the banner
display_banner() {
    figlet "DevChest"
    echo "--------------------------------------------"
    echo "Welcome to the DevChest Installation Script"
    echo "--------------------------------------------"
    echo ""
}

# Function to clone script from Git repository
clone_scripts() {
    if ! command -v git &> /dev/null; then
        echo "Git not found. Installing..."
        case "$OS_NAME" in
            debian|ubuntu)
                sudo apt-get install -y git || { echo "Failed to install git."; return 1; }
                ;;
            rhel|centos|fedora|rocky|almalinux)
                sudo yum install -y git || { echo "Failed to install git."; return 1; }
                ;;
            arch)
                sudo pacman -Sy git --noconfirm || { echo "Failed to install git."; return 1; }
                ;;
            *)
                echo "Unsupported Linux distribution: $OS_NAME for git."
                return 1
                ;;
        esac
    fi

    echo "Cloning scripts from $REPO_URL to $TEMP_DIR..."
    git clone --depth=1 "$REPO_URL" "$TEMP_DIR" > /dev/null 2>&1 || { echo "Failed to clone repository."; exit 1; }
    chmod +x "$TEMP_DIR"/*.sh "$TEMP_DIR"/scripts/*.sh
    scripts_dir="$TEMP_DIR/scripts"
}

# Detect OS and set variables
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
    OS_VERSION=$VERSION_ID
    case "$OS_NAME" in
        ubuntu|debian|centos|rhel|fedora)
            echo "Detected OS: $OS_NAME $OS_VERSION"
            ;;
        *)
            echo "Error: Unsupported OS: $OS_NAME" >&2
            exit 1
            ;;
    esac
else
    echo "Error: /etc/os-release not found. Cannot determine OS." >&2
    exit 1
fi

# Main function
init() {
    # Clone scripts from repository
    clone_scripts

    # Source utility functions
    if [ -f "$TEMP_DIR/utils.sh" ]; then
        source "$TEMP_DIR/utils.sh"
    else
        echo "Error: utils.sh not found in $TEMP_DIR" >&2
        exit 1
    fi

    # Ensure download tools and utilities are installed
    ensure_download_tools  || { echo "Failed to ensure download tools."; exit 1; }

    clear

    # Source scripts
    if [ -d "$TEMP_DIR/scripts" ]; then
        for file in "$TEMP_DIR"/scripts/*.sh; do
            if [ -f "$file" ]; then
                source "$file"
            else
                echo "Warning: No scripts found in $TEMP_DIR/scripts" >&2
                break
            fi
        done
    else
        echo "Error: scripts directory not found in $TEMP_DIR" >&2
        exit 1
    fi

    display_banner

    choices=$(whiptail --title "Tool Installer" --checklist \
        "Select the tools you want to install using SPACE to toggle and ENTER to confirm:" 20 78 10 \
        "google-chrome" "Google Chrome" OFF \
        "docker" "Docker Engine" OFF \
        "nvm" "Node Version Manager (NVM)" OFF \
        "vscode" "Visual Studio Code" OFF \
         3>&1 1>&2 2>&3)

    # Clear the screen after selection to keep it clean
    clear

    # Exit if user pressed Cancel
    exitstatus=$?
    if [ $exitstatus -ne 0 ]; then
        echo "Installation cancelled by user."
        exit 1
    fi

    display_banner
    echo "Selected tools: $choices"
    echo ""

    # Process selected tools
    for choice in $choices; do
        choice=$(echo "$choice" | tr -d '"') # Remove quotes from choice
        case $choice in
            google-chrome)
                echo "➡️  Installing 🌐 Google Chrome..."
                install_chrome
                ;;
            docker)
                echo "➡️  Installing 🐳 Docker..."
                install_docker
                ;;
            nvm)
                echo "➡️  Installing 📦 Node Version Manager (NVM)..."
                install_nvm
                ;;
            vscode)
                echo "➡️  Installing 💻 Visual Studio Code..."
                install_vscode
                ;;
            *)
                echo "❌ Invalid choice: $choice. Skipping..."
                IS_INSTALLATION_SUCCESS=false
                ;;
        esac
    done

    # Display final status
    if $IS_INSTALLATION_SUCCESS; then
        echo ""
        echo "✅ All selected packages installed successfully!"
    else
        echo ""
        echo "⚠️ Some packages failed to install. Please check the logs."
    fi
}

# Trap errors and cleanup on exit
cleanup_on_exit() {
    local exit_code=$?
    local TEMP_DIR=$1
    echo "Cleaning up temporary utilities and directory..."

    # Remove figlet if installed
    if command -v figlet &> /dev/null; then
        echo "Removing figlet..."
        case "$OS_NAME" in
            debian|ubuntu)
                sudo apt-get remove -y figlet || { echo "Failed to remove figlet."; return 1; }
                sudo apt-get autoremove -y || { echo "Failed to autoremove dependencies."; return 1; }
                ;;
            rhel|centos|fedora|rocky|almalinux)
                sudo yum remove -y figlet || { echo "Failed to remove figlet."; return 1; }
                ;;
            arch)
                sudo pacman -Rns figlet --noconfirm || { echo "Failed to remove figlet."; return 1; }
                ;;
            *)
                echo "Skipping figlet removal — unsupported distribution: $OS_NAME"
                ;;
        esac
        echo "Figlet removed successfully."
    fi

    # Remove whiptail/newt if installed
    if command -v whiptail &> /dev/null; then
        echo "Removing whiptail/newt..."
        case "$OS_NAME" in
            debian|ubuntu)
                sudo apt-get remove -y whiptail || { echo "Failed to remove whiptail."; return 1; }
                sudo apt-get autoremove -y || { echo "Failed to autoremove dependencies."; return 1; }
                ;;
            rhel|centos|fedora|rocky|almalinux)
                sudo yum remove -y newt || { echo "Failed to remove newt."; return 1; }
                ;;
            arch)
                sudo pacman -Rns newt --noconfirm || { echo "Failed to remove newt."; return 1; }
                ;;
            *)
                echo "Skipping whiptail/newt removal — unsupported distribution: $OS_NAME"
                ;;
        esac
        echo "Whiptail/newt removed successfully."
    fi

    # Remove temporary directory
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        echo "Removing temporary directory: $TEMP_DIR..."
        rm -rf "$TEMP_DIR" || { echo "Failed to remove temporary directory."; return 1; }
        echo "Temporary directory removed successfully."
    fi

    echo "Cleanup completed successfully."
    exit $exit_code
}

trap 'cleanup_on_exit "$TEMP_DIR"' EXIT

init