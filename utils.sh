#!/usr/bin/env bash
# utils.sh - Utility functions for installing dependencies and managing package lists

# Function to update package lists based on the OS
update_package_lists() {
    if [ -z "$OS_NAME" ]; then
        echo "Error: OS_NAME is not set. Cannot update package lists."
        return 1
    fi
    echo "Updating package lists for $OS_NAME..."
    case "$OS_NAME" in
        debian|ubuntu)
            sudo apt-get update -y || { echo "Failed to update package lists for $OS_NAME."; return 1; }
            ;;
        rhel|centos|fedora|rocky|almalinux)
            sudo yum makecache -y || { echo "Failed to update package lists for $OS_NAME."; return 1; }
            ;;
        arch)
            sudo pacman -Sy --noconfirm || { echo "Failed to update package lists for $OS_NAME."; return 1; }
            ;;
        *)
            echo "Unsupported Linux distribution: $OS_NAME for updating package lists."
            return 1
            ;;
    esac
    echo "Package lists updated successfully for $OS_NAME."
}

# Function to install a package based on the OS
install_package() {
    local package=$1
    echo "Installing $package..."
    case "$OS_NAME" in
        debian|ubuntu)
            sudo apt-get install -y "$package" || { echo "Failed to install $package."; return 1; }
            ;;
        rhel|centos|fedora|rocky|almalinux)
            sudo yum install -y "$package" || { echo "Failed to install $package."; return 1; }
            ;;
        arch)
            sudo pacman -Sy "$package" --noconfirm || { echo "Failed to install $package."; return 1; }
            ;;
        *)
            echo "Unsupported Linux distribution: $OS_NAME for $package."
            return 1
            ;;
    esac
    echo "$package installed successfully."
}

# Ensure whiptail is installed
ensure_whiptail() {
    if ! command -v whiptail &> /dev/null; then
        echo "Whiptail not found. Installing..."
        # Try 'whiptail' first, fall back to 'newt' for some distributions
        install_package "whiptail" || install_package "newt" || { echo "Failed to install whiptail or newt."; return 1; }
    else
        echo "Whiptail already installed."
    fi
}

# Ensure figlet is installed
ensure_figlet() {
    if ! command -v figlet &> /dev/null; then
        echo "Figlet not found. Installing..."
        install_package "figlet"  || { echo "Failed to install figlet."; return 1; }
    else
        echo "Figlet already installed."
    fi
}

# Ensure wget is installed
ensure_wget() {
    if ! command -v wget &> /dev/null; then
        echo "Wget not found. Installing..."
        install_package "wget" || { echo "Failed to install wget."; return 1; }
    else
        echo "Wget already installed."
    fi
}

# Ensure curl is installed
ensure_curl() {
    if ! command -v curl &> /dev/null; then
        echo "Curl not found. Installing..."
        install_package "curl" || { echo "Failed to install curl."; return 1; }
    else
        echo "Curl already installed."
    fi
}

# Ensure necessary download tools are installed
ensure_download_tools() {
    echo "Updating the packages list..."
    update_package_lists || { echo "Failed to update package lists. Exiting."; exit 1; }
    echo ""
    echo "Ensuring download tools are available..."
    if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
        echo "Neither wget nor curl found. Installing both..."
        ensure_wget
        ensure_curl
    elif ! command -v wget &> /dev/null; then
        ensure_wget
    elif ! command -v curl &> /dev/null; then
        ensure_curl
    elif ! command -v figlet &> /dev/null; then
        ensure_figlet
    fi
    ensure_whiptail
    echo "Download tools check complete."
}

# try_run: Executes a command and handles errors uniformly
# Usage: try_run <command> [args...]
# Runs the given command, and if it fails, prints an error message,
# sets the global 'IS_INSTALLATION_SUCCESS' flag to false, and returns failure.
try_run() {
    "$@" || {
        echo "❌ Command failed: $*" >&2
        IS_INSTALLATION_SUCCESS=false
        return 1
    }
}

# Function to set IS_INSTALLATION_SUCCESS to false
set_failed() {
    IS_INSTALLATION_SUCCESS=false
    return 1
}