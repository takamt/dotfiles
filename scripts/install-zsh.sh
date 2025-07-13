#!/bin/bash

# update package list
sudo apt-get update

# Install ZSH
sudo apt-get install --no-install-recommends -y \
    zsh

# Set default shell to zsh
export SHELL=/usr/bin/zsh
zsh && chsh -s /bin/zsh

# Install ZSH Plugins
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


# Install eza instead of ls
sudo apt-get install -y \
    gpg \
    && mkdir -p /etc/apt/keyrings \
    && wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list \
    && chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
    eza


# Cleanup apt cache
sudo apt-get clean \
    && rm -rf /var/lib/apt/lists/*