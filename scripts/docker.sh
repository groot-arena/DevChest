#!/usr/bin/env bash
# docker.sh - Script to install Docker Engine

install_docker() {
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker Engine on $OS_NAME..."
        case "$OS_NAME" in
            debian|ubuntu)
                # Remove conflicting packages
                echo "Removing conflicting packages..."
                for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

                # Add Docker's official GPG key:
                echo "Adding Docker's official GPG Key..."
                try_run sudo apt-get update
                try_run sudo apt-get install ca-certificates curl
                try_run sudo install -m 0755 -d /etc/apt/keyrings
                try_run sudo curl -fsSL https://download.docker.com/linux/$OS_NAME/gpg -o /etc/apt/keyrings/docker.asc
                try_run sudo chmod a+r /etc/apt/keyrings/docker.asc
                
                # Add the repository
                echo "Adding Docker repository to Apt sources..."
                echo \
                    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS_NAME \
                    $(lsb_release -cs) stable" | try_run sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                try_run sudo apt-get update
                
                # Install Docker
                echo "Installing Docker packages..."
                try_run sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                ;;
            centos|rhel)
                # Remove conflicting packages
                echo "Removing conflicting packages..."
                try_run sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc

                # Install prerequisites
                echo "Installing prerequisites..."
                try_run sudo yum install -y yum-utils

                # Add Docker repository
                echo "Adding Docker repository..."
                try_run sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

                # Install Docker
                echo "Installing Docker packages..."
                try_run sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                ;;
            fedora)
                # Remove conflicting packages
                echo "Removing conflicting packages..."
                try_run sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc

                # Add Docker repository
                echo "Adding Docker repository..."
                try_run sudo dnf -y install dnf-plugins-core
                try_run sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

                # Install Docker
                echo "Installing Docker packages..."
                try_run sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                ;;
            *)
                echo "Error: Unsupported OS: $OS_NAME" >&2
                set_failed
                ;;
        esac

        # Start and enable Docker service
        echo "Starting and enabling Docker service..."
        try_run sudo systemctl start docker
        try_run sudo systemctl enable docker

        # Verify installation
        if command -v docker &> /dev/null; then
            echo "Docker installed successfully. Version: $(docker --version)"
        else
            echo "Error: Docker installation failed." >&2
        fi
        
        # Add current user to docker group (optional, for running docker without sudo)
        if [ -n "$SUDO_USER" ]; then
            echo "Adding $SUDO_USER to docker group..."
            try_run sudo usermod -aG docker "$SUDO_USER" 
            try_run echo "Please log out and log back in to apply group changes, or run 'newgrp docker'."
        fi

        echo "Docker installation completed."
    else
        echo "Docker Engine is already installed. Skipping installation."
    fi
}