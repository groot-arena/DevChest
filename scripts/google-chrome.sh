#!/usr/bin/env bash
# google-chrome.sh - Script to install Google Chrome

install_chrome() {
    # Check if Chrome is already installed
    if command -v google-chrome &> /dev/null || command -v google-chrome-stable &> /dev/null; then
        echo "Google Chrome is already installed. Skipping installation."
        return 0
    else
        case "$OS_NAME" in
            debian|ubuntu)
                echo "Installing dependencies..."
                try_run sudo apt-get install "libxss1"
                try_run sudo apt-get "libappindicator1"
                try_run sudo apt-get "libindicator7"
                
                echo ""
                try_run wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

                echo "Installing Google Chrome..."
                sudo apt install -y ./google-chrome-stable_current_amd64.deb || { set_failed; rm -f google-chrome-stable_current_amd64.deb; return 1; }
                rm -f google-chrome-stable_current_amd64.deb
                ;;
            rhel|centos|fedora|rocky|almalinux)
                echo "Installing dependencies..."
                try_run sudo yum install -y "libXScrnSaver"
                
                echo ""
                echo "Downloading google-chrome-stable.rpm"
                try_run wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
                
                echo "Installing Google Chrome..."
                sudo yum localinstall -y google-chrome-stable_current_x86_64.rpm || { set_failed; rm -f google-chrome-stable_current_x86_64.rpm; return 1; }
                rm -f google-chrome-stable_current_x86_64.rpm
                ;;
            arch)
                echo "On Arch Linux, Google Chrome is available via AUR. You need an AUR helper like 'yay'."
                if command -v yay &> /dev/null; then
                    yay -S --noconfirm google-chrome || return 1
                else
                    echo "AUR helper 'yay' not found. Please install it to install Google Chrome."
                    return 1
                fi
                ;;
            *)
                echo "Unsupported Linux distribution for Google Chrome installation: $OS_NAME"
                return 1
                ;;
        esac

        echo "✅ Successfully installed Google Chrome. Skipping installation."
        return 0
    fi
}