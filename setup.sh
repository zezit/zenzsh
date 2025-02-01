#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Ensure python3-venv is installed
if ! dpkg -s python3-venv >/dev/null 2>&1; then
    echo -e "${YELLOW}python3-venv is not installed. Installing...${NC}"
    sudo apt install -y python3-venv >/dev/null 2>&1
else
    echo -e "${GREEN}python3-venv is already installed.${NC}"
fi

# Create and activate a Python virtual environment
VENV_DIR="$HOME/.interactive_setup_env"
if [ ! -d "$VENV_DIR" ]; then
    echo -e "${YELLOW}Creating Python virtual environment...${NC}"
    python3 -m venv "$VENV_DIR"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to create virtual environment. Ensure python3-venv is installed.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}Python virtual environment already exists.${NC}"
fi

# Activate virtual environment
if [ -f "$VENV_DIR/bin/activate" ]; then
    source "$VENV_DIR/bin/activate"
else
    echo -e "${RED}Virtual environment activation script not found. Exiting.${NC}"
    exit 1
fi

# Ensure pip is installed
if ! command -v pip &>/dev/null; then
    echo -e "${YELLOW}pip is not installed. Installing...${NC}"
    sudo apt install -y python3-pip
fi

# Install required Python packages
pip install --upgrade pip
pip install -r requirements.txt

# Activate virtual environment
echo -e "${YELLOW}Run the following command to activate the virtual environment:${NC}"
echo -e "$ ${GREEN}source $VENV_DIR/bin/activate && pip install -r requirements.txt && python3 setup.py${NC}"