#!/bin/bash

# Ensure python3-venv is installed
if ! dpkg -s python3-venv >/dev/null 2>&1; then
    echo "python3-venv is not installed. Installing..."
    sudo apt install -y python3-venv >/dev/null 2>&1
else
    echo "python3-venv is already installed."
fi

# Create and activate a Python virtual environment
VENV_DIR="$HOME/.interactive_setup_env"
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv "$VENV_DIR"
    if [ $? -ne 0 ]; then
        echo "Failed to create virtual environment. Ensure python3-venv is installed."
        exit 1
    fi
else
    echo "Python virtual environment already exists."
fi

# Activate virtual environment
if [ -f "$VENV_DIR/bin/activate" ]; then
    source "$VENV_DIR/bin/activate"
else
    echo "Virtual environment activation script not found. Exiting."
    exit 1
fi

# Ensure pip is installed
if ! command -v pip &>/dev/null; then
    echo "pip is not installed. Installing..."
    sudo apt install -y python3-pip
fi

# Install required Python packages
pip install --upgrade pip
pip install inquirer

# Create requirements.txt
cat <<EOL > requirements.txt
inquirer
EOL

echo "Starting setup..."

# Run the Python script
python3 - <<EOF
import os
import subprocess
import inquirer
import sys

def is_interactive():
    return sys.stdout.isatty() and sys.stdin.isatty()

def print_msg(message):
    print(f"\n\033[1;32m{message}\033[0m")

def command_exists(command):
    return subprocess.call(["which", command], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) == 0

def run_command(command, description):
    if not is_interactive():
        print(f"Non-interactive environment detected. Exiting setup.")
        sys.exit(1)  # Exit the script

    # Proceed with interactive question if in an interactive environment
    questions = [
        inquirer.Confirm("execute", message=f"Do you want to {description}?", default=True)
    ]
    answer = inquirer.prompt(questions)
    if answer["execute"]:
        subprocess.run(command, shell=True)
    else:
        print(f"Skipped: {description}")

# Detect package manager
PACKAGE_MANAGER = None
if command_exists("apt"):
    PACKAGE_MANAGER = "apt"
    UPDATE_CMD = "sudo apt update && sudo apt upgrade -y"
    INSTALL_CMD = "sudo apt install -y"
elif command_exists("yum"):
    PACKAGE_MANAGER = "yum"
    UPDATE_CMD = "sudo yum update -y"
    INSTALL_CMD = "sudo yum install -y"
elif command_exists("dnf"):
    PACKAGE_MANAGER = "dnf"
    UPDATE_CMD = "sudo dnf upgrade --refresh -y"
    INSTALL_CMD = "sudo dnf install -y"
elif command_exists("zypper"):
    PACKAGE_MANAGER = "zypper"
    UPDATE_CMD = "sudo zypper refresh && sudo zypper update -y"
    INSTALL_CMD = "sudo zypper install -y"
else:
    print_msg("Unsupported package manager. Please install required software manually.")
    exit(1)

# Update system
run_command(UPDATE_CMD, "update and upgrade the system")

# Backup existing .zshrc
if os.path.exists(os.path.expanduser("~/.zshrc")):
    run_command("mv ~/.zshrc ~/.zshrc.bak", "backup existing .zshrc file")

# Install Zsh
if not command_exists("zsh"):
    run_command(f"{INSTALL_CMD} zsh", "install Zsh")
else:
    print_msg("Zsh is already installed.")

# Change default shell to Zsh
run_command("chsh -s $(which zsh)", "change default shell to Zsh")

# Install utilities
utilities = ["git", "eza", "bat", "fd-find", "ripgrep", "fzf", "tmux", "gh"]
for util in utilities:
    if not command_exists(util):
        run_command(f"{INSTALL_CMD} {util}", f"install {util}")
    else:
        print_msg(f"{util} is already installed.")

# Install zoxide manually
if not command_exists("zoxide"):
    run_command("curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh", "install zoxide")

# Install GitHub Copilot CLI
if command_exists("gh"):
    run_command("gh extension install github/gh-copilot", "install GitHub Copilot CLI")
else:
    print_msg("GitHub CLI is required for Copilot CLI. Skipping installation.")

# Configure Powerlevel10k theme
if os.path.exists(os.path.expanduser("~/.p10k.zsh")):
    questions = [
        inquirer.Confirm("backup", message="A Powerlevel10k theme is already installed. Backup and reconfigure?", default=True)
    ]
    response = inquirer.prompt(questions)
    if response["backup"]:
        run_command("mv ~/.p10k.zsh ~/.p10k.zsh.bak", "backup Powerlevel10k theme")

# Download new .zshrc
run_command("curl -fsSL https://raw.githubusercontent.com/zezit/zenzsh/master/.zshrc > ~/.zshrc", "download and set up .zshrc")

# Setup Copilot Zsh Plugin
copilot_plugin_dir = os.path.expanduser("${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/github-copilot")
if not os.path.exists(copilot_plugin_dir):
    run_command("git clone https://github.com/mattn/gh-copilot.git "$copilot_plugin_dir"", "install GitHub Copilot Zsh Plugin")

# Add Copilot plugin to .zshrc
run_command("echo 'plugins+=(github-copilot)' >> ~/.zshrc", "add GitHub Copilot plugin to .zshrc")

print_msg("Setup complete! Please restart your terminal or run: source ~/.zshrc")
EOF

# Deactivate virtual environment
deactivate
