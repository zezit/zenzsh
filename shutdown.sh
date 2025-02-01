#!/bin/bash

# Deactivate the Python virtual environment if active
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo "Deactivating virtual environment..."
    deactivate
fi

# Optionally, clean up the environment
echo "Cleaning up setup..."
rm -rf ~/.interactive_setup_env

echo "Shutdown complete. Virtual environment removed."