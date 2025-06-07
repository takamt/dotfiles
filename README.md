# Dotfiles

This repository contains my personal dotfiles configuration, primarily focused on zsh settings.

## Features

- zsh configuration files
- Installation script
- Symbolic link creation with backup functionality
- Custom script execution

## Installation

1. Run the installation script:
```bash
./install.sh
```

## Installation Script Features

- Backs up existing dotfiles to `~/.dotbackup`
- Creates symbolic links to the home directory
- Handles nested directory structures (e.g., `.config/`)
- Executes `.sh` files in the `scripts/` directory

## Options

The installation script supports the following options:

- `-h, --help`: Display help message
- `-d, --debug`: Enable debug mode (verbose output)

## Directory Structure

```
dotfiles/
├── install.sh
├── .config/
└── scripts/
```

## Notes

- Existing dotfiles are automatically backed up before installation
- Existing symbolic links are automatically removed
- The installation script is compatible with POSIX-compliant shells

## License

Released under the MIT License. 