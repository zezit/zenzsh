#!/bin/bash

# -------------- Helpers --------------
# Function to print messages
print() {
    echo "\n\e[1;32m$1\e[0m"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update packages
# Determine the package manager
if command_exists apt; then
  PACKAGE_MANAGER="apt"
  UPDATE_CMD="sudo apt update && sudo apt upgrade -y"
  INSTALL_CMD="sudo apt install -y"
elif command_exists yum; then
  PACKAGE_MANAGER="yum"
  UPDATE_CMD="sudo yum update -y"
  INSTALL_CMD="sudo yum install -y"
elif command_exists dnf; then
  PACKAGE_MANAGER="dnf"
  UPDATE_CMD="sudo dnf upgrade --refresh -y"
  INSTALL_CMD="sudo dnf install -y"
elif command_exists zypper; then
  PACKAGE_MANAGER="zypper"
  UPDATE_CMD="sudo zypper refresh && sudo zypper update -y"
  INSTALL_CMD="sudo zypper install -y"
else
  print "Unsupported package manager. Please install Zsh and Oh My Zsh manually."
  exit 1
fi

# Update and upgrade the system
print "Updating and upgrading the system using $PACKAGE_MANAGER..."
eval $UPDATE_CMD

# Backup existing .zshrc file
if [ -f ~/.zshrc ]; then
  print "Backing up existing .zshrc file to ~/.zshrc.bak..."
  mv ~/.zshrc ~/.zshrc.bak
fi

# Check if Zsh is installed
if command_exists zsh; then
  print "Zsh is already installed."
else
  # Install Zsh
  print "Installing Zsh..."
  eval $INSTALL_CMD zsh
fi

# Change default shell to Zsh
print "Changing default shell to Zsh..."
chsh -s $(which zsh)

# Check if git is installed
if command_exists git; then
  print "Git is already installed."
else
  # Install Git
  print "Installing Git..."
  $INSTALL_CMD git
fi

# Backup powerlevel10k theme
if [ -f ~/.p10k.zsh ]; then
    read -p "A Powerlevel10k theme is already installed. Do you want to back it up and reconfigure? (y/n): " response
    if [ "$response" = "y" ]; then
        print "Backing up existing Powerlevel10k theme to ~/.p10k.zsh.bak..."
        mv ~/.p10k.zsh ~/.p10k.zsh.bak
    else
        print "Skipping backup and reconfiguration of Powerlevel10k."
    fi
fi

# Install fzf
if command_exists fzf; then
  print "fzf is already installed."
else
  print "Installing fzf..."
  $INSTALL_CMD fzf
fi

# Install zoxide
if command_exists zoxide; then
  print "zoxide is already installed."
else
  print "Installing zoxide..."
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# Create a new .zshrc file
print "Creating a new .zshrc file..."
touch ~/.zshrc

# Fill it with the content from github.com/zezit/zenzsh
print "Filling the .zshrc file with the content from github.com/zezit/zenzsh..."
curl -fsSL https://raw.githubusercontent.com/zezit/zenzsh/master/.zshrc > ~/.zshrc

# Reset terminal
print "All done\nPlease restart your terminal to apply the changes using (source ~/.zshrc)"
