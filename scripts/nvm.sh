#!/usr/bin/env bash
# nvm.sh - Script to install Node Version Manager

install_nvm() {
    if ! command -v nvm &> /dev/null; then
        echo "Installing nvm..."
        try_run curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')/install.sh | bash
    else
        echo "nvm is already installed. Skipping installation."
    fi
}
