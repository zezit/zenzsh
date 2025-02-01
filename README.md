# Interactive System Setup

This project automates the setup of a Linux-based development environment with a set of essential tools and configurations. It creates a Python virtual environment, installs dependencies, and sets up tools like Zsh and Powerlevel10k.

## Files

- `setup.sh`: The main bash script to set up the system.
- `shutdown.sh`: A script to deactivate and clean up after setup.
- `setup.py`: A Python script that handles the interactive setup of the system.
- `requirements.txt`: A list of Python dependencies.

## Usage

### Step 1: Make the setup script executable

Make sure that the `setup.sh` script is executable. Run the following command:

```bash
chmod +x setup.sh
chmod +x shutdown.sh
```

### Step 2: Run the setup script

Run the setup script with the following command:

```bash
./setup.sh
```

### Step 3: Follow the instructions

The setup script will guide you through the installation process. Follow the instructions to set up your system.

```bash
python3 setup.py
```

### Step 4: Restart the terminal

After the setup is complete, restart the terminal to apply the changes.

```bash
shutdown.sh
```