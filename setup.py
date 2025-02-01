import os
import subprocess
import click
from cliff.command import Command

class SetupCommand(Command):
    """Setup command to perform the setup process."""
    
    def take_action(self, parsed_args):
        """Method to run the setup."""
        # Check for interactive mode
        if not os.isatty(0) or not os.isatty(1):
            print("Non-interactive environment detected. Exiting setup.")
            return

        # Start setup
        self.run_command("sudo apt update && sudo apt upgrade -y", "update and upgrade the system")
        
        # Backup existing .zshrc
        if os.path.exists(os.path.expanduser("~/.zshrc")):
            self.run_command("mv ~/.zshrc ~/.zshrc.bak", "backup existing .zshrc file")
        
        # Install Zsh
        if not self.command_exists("zsh"):
            self.run_command("sudo apt install -y zsh", "install Zsh")
        else:
            print("Zsh is already installed.")
        
        # Download new .zshrc
        self.run_command("curl -fsSL https://raw.githubusercontent.com/zezit/zenzsh/master/.zshrc > ~/.zshrc", "download and set up .zshrc")

        print("Setup complete! Please restart your terminal or run: source ~/.zshrc")

    def run_command(self, command, description):
        """Runs a command interactively with confirmation."""
        confirmation = click.confirm(f"Do you want to {description}?")
        if confirmation:
            result = subprocess.run(command, shell=True, capture_output=True, text=True)
            output_lines = result.stdout.splitlines()[-5:]
            for line in output_lines:
                print(line)
        else:
            print(f"Skipped: {description}")

    def command_exists(self, command):
        """Check if a command exists on the system."""
        return subprocess.call(["which", command], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) == 0


@click.group()
def cli():
    """Main entry point for the setup tool."""
    pass


@cli.command()
def setup():
    """Run the system setup."""
    command = SetupCommand(None, None)
    command.run([])

if __name__ == '__main__':
    cli()
