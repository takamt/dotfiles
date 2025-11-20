#!/bin/bash

echo "Starting Vim installation"


# Detect OS and install Vim accordingly
case "$(uname)" in
    Linux*)
        echo "Detected Linux. Installing with apt-get."
        # update package list
        sudo apt-get update
        # Install Vim
        sudo apt-get install --no-install-recommends -y vim
        ;;
    Darwin*)
        echo "Detected macOS. Installing with brew."
        if ! command -v brew >/dev/null 2>&1; then
            echo "Homebrew not found. Please install Homebrew manually."
            exit 1
        fi
        brew update
        brew install vim
        ;;
    *)
        echo "Unsupported OS: $(uname). Please install Vim manually."
        exit 1
        ;;
esac


# Install Vim Plugins
echo "Installing Vim Plugins started"
mkdir -p ~/.vim
mkdir -p ~/.vim/colors

## Install colorscheme
git clone \
    https://github.com/tomasr/molokai /tmp/molokai \
&& cp /tmp/molokai/colors/molokai.vim ~/.vim/colors/molokai.vim

echo "Installing Vim Plugins completed"


# Cleanup package manager cache
case "$(uname)" in
    Linux*)
        echo "Cleaning up apt cache"
        sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*
        echo "Cleaning up apt cache completed"
        ;;
    Darwin*)
        echo "Cleaning up brew cache"
        brew cleanup
        echo "Cleaning up brew cache completed"
        ;;
    *)
        echo "No package cache cleanup for this OS. Skipping."
        ;;
esac


echo "Vim installation completed"