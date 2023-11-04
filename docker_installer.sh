#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$@" > /dev/null 2>&1
}

# Function to install Docker
install_docker() {
    echo "Updating software repositories..."
    sudo apt update

    echo "Installing required prerequisites..."
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    echo "Adding Docker’s official GPG key..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    echo "Adding the Docker repository to APT sources..."
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    echo "Updating the package database with the Docker packages from the newly added repo..."
    sudo apt update

    echo "Installing Docker CE..."
    sudo apt install -y docker-ce

    echo "Starting Docker..."
    sudo systemctl start docker

    echo "Enabling Docker to start on boot..."
    sudo systemctl enable docker

    echo "Adding current user to the Docker group..."
    sudo usermod -aG docker ${USER}

    echo "Docker installation complete."
}

# Function to install Docker Compose
install_docker_compose() {
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installation complete."
}

# Check if Docker is installed
if command_exists docker; then
    echo "Docker is already installed."
else
    echo "Docker is not installed. Installing Docker..."
    install_docker
fi

# Check if Docker Compose is installed
if command_exists docker-compose; then
    echo "Docker Compose is already installed."
else
    echo "Docker Compose is not installed. Installing Docker Compose..."
    install_docker_compose
fi

# Post-installation steps for Docker
if command_exists docker; then
    echo "To apply the new group membership without logging out and back in, run: 'newgrp docker'"
    echo "You may need to log out and back in to ensure Docker can be run without sudo."
fi

# Check Docker and Docker Compose versions
if command_exists docker; then
    docker --version
fi

if command_exists docker-compose; then
    docker-compose --version
fi
