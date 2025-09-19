#!/bin/bash

# macOS Setup Script

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script is designed for macOS only"
        exit 1
    fi
    log_success "Running on macOS"
}

install_rosetta() {
    log_info "Installing Rosetta 2 for Apple Silicon compatibility..."
    if /usr/bin/pgrep oahd >/dev/null 2>&1; then
        log_success "Rosetta 2 is already installed"
    else
        if sudo softwareupdate --install-rosetta --agree-to-license; then
            log_success "Rosetta 2 installed successfully"
        else
            log_error "Failed to install Rosetta 2"
            exit 1
        fi
    fi
}

install_homebrew() {
    log_info "Checking for Homebrew installation..."

    if command -v brew >/dev/null 2>&1; then
        log_success "Homebrew is already installed"
        log_info "Updating Homebrew..."
        brew update
    else
        log_info "Installing Homebrew..."
        if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            log_success "Homebrew installed successfully"

            # Add Homebrew to PATH for current session
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            log_error "Failed to install Homebrew"
            exit 1
        fi
    fi
}

install_applications() {
    log_info "Installing Applications..."

    brew install --cask google-chrome || true
    brew install --cask 1password || true
    brew install --cask visual-studio-code || true
    brew install --cask slack || true
    brew install --cask linear-linear || true
    brew install --cask github || true

    log_success "Applications installation completed"
}

setup_shell_profile() {
    log_info "Setting up shell profile for Homebrew..."

    if [[ "$SHELL" == */zsh ]]; then
        PROFILE_FILE="$HOME/.zshrc"
    elif [[ "$SHELL" == */bash ]]; then
        PROFILE_FILE="$HOME/.bash_profile"
    else
        log_warning "Unknown shell: $SHELL. You may need to manually add Homebrew to your PATH"
        return
    fi

    BREW_PATH_CMD='eval "$(/opt/homebrew/bin/brew shellenv)"'

    if ! grep -q "brew shellenv" "$PROFILE_FILE" 2>/dev/null; then
        echo "" >> "$PROFILE_FILE"
        echo "# Add Homebrew to PATH" >> "$PROFILE_FILE"
        echo "$BREW_PATH_CMD" >> "$PROFILE_FILE"
        log_success "Added Homebrew to $PROFILE_FILE"
    else
        log_success "Homebrew already configured in $PROFILE_FILE"
    fi
}

# Main execution
main() {
    log_info "Starting macOS setup script..."
    echo "========================================"

    check_macos

    log_info "Step 1/3: Installing Rosetta 2 (if needed)..."
    install_rosetta

    log_info "Step 2/3: Installing Homebrew..."
    install_homebrew

    log_info "Step 3/3: Installing Applications..."
    install_applications

    setup_shell_profile

    echo "========================================"
    log_success "Setup completed successfully!"
    echo ""
    log_info "Installed components:"
    echo "  ✓ Homebrew package manager"
    echo "  ✓ Rosetta 2 (Apple Silicon compatibility)"
    echo "  ✓ Applications: Google Chrome, 1Password, VS Code, Slack, Linear, GitHub Desktop"
    echo ""
    log_info "Please restart your terminal or run 'source ~/.zshrc' (or ~/.bash_profile) to use Homebrew commands"
}

# Run the main function
main "$@"
