#!/bin/bash

echo "Starting ZSH installation"

# update package list
sudo apt-get update

# Install ZSH
sudo apt-get install --no-install-recommends -y \
    zsh


# Install ZSH Plugins
echo "Installing ZSH Plugins started"
mkdir -p ~/.zsh

## Install zsh-autosuggestions
git clone \
    https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

## Install zsh-syntax-highlighting
git clone \
    https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting

## Install zsh-completions
git clone \
    https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions

## Install git-prompt
curl -o \
    ~/.zsh/git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

echo "Installing ZSH Plugins completed"

# Install eza instead of ls
echo "Installing eza started"
sudo apt-get install -y \
    gpg \
    && sudo mkdir -p /etc/apt/keyrings \
    && wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list \
    && sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list \
    && sudo apt-get update \
    && sudo apt-get install --no-install-recommends -y \
    eza

echo "Installing eza completed"

# Cleanup apt cache
echo "Cleaning up apt cache"
sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

echo "Cleaning up apt cache completed"

echo "ZSH installation completed"

# Set default shell to zsh
export SHELL=/usr/bin/zsh
sudo chsh -s /usr/bin/zsh && zsh