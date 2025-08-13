#!/bin/bash

echo "Starting Vim installation"

# update package list
sudo apt-get update


# Install Vim
sudo apt-get install --no-install-recommends -y \
    vim


# Install Vim Plugins
echo "Installing Vim Plugins started"
mkdir -p ~/.vim
mkdir -p ~/.vim/colors

## Install colorscheme
git clone \
    https://github.com/tomasr/molokai /tmp/molokai \
&& cp /tmp/molokai/colors/molokai.vim ~/.vim/colors/molokai.vim

echo "Installing Vim Plugins completed"


# Cleanup apt cache
echo "Cleaning up apt cache"
sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

echo "Cleaning up apt cache completed"


echo "Vim installation completed"