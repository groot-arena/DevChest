#!/usr/bin/env bash
# vscode.sh - Script to install Microsoft Visual Studio Code

install_vscode() {
    if ! command -v code &> /dev/null; then
        case "$OS_NAME" in
            debian|ubuntu)
                echo "Installing dependencies..."
                try_run sudo apt-get install "gpg"
                try_run wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
                try_run sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
                echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |try_run sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
                rm -f packages.microsoft.gpg
                
                echo "Continuing dependency installation..."
                try_run sudo apt-get install "apt-transport-https"
                try_run sudo apt update
                echo "Installing Microsoft Visual Studio Code..."
                try_run sudo apt-get install code
                ;;
            rhel|centos|fedora|rocky|almalinux)
                try_run sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
                echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | try_run sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
                try_run dnf check-update
                try_run sudo dnf install code
                ;;
            *)
                echo "Unsupported Linux distribution: $OS_NAME for Microsoft Visual Studio Code."
                return 1
                ;;
        esac
    else
        echo "Microsoft Visual Studio Code is already installed. Skipping installation."
    fi
}