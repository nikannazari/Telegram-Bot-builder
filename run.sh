#!/usr/bin/env bash

set -e

# ==========================================
# Telegram Bot Builder Launcher
# ==========================================

APP_NAME="telegram-bot-builder"
INSTALL_PATH="/usr/local/bin/$APP_NAME"

# Resolve the real path of this script.
# This works even when run.sh is executed through a symlink.
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
PROJECT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

VENV="$PROJECT_DIR/.venv"
PYTHON="$VENV/bin/python"
PIP="$VENV/bin/pip"

MAIN_FILE="$PROJECT_DIR/main.py"
REQUIREMENTS="$PROJECT_DIR/requirements.txt"
LOG_FILE="/tmp/telegram-bot-builder-streamlit.log"


# ==========================================
# Colors / Output
# ==========================================

info() {
    echo "[INFO] $1"
}

success() {
    echo "[OK] $1"
}

error() {
    echo "[ERROR] $1"
}


# ==========================================
# Check Project
# ==========================================

check_project() {

    if [[ ! -f "$MAIN_FILE" ]]; then
        error "main.py not found."
        error "Project directory: $PROJECT_DIR"
        exit 1
    fi

}


# ==========================================
# Create Virtual Environment
# ==========================================

create_venv() {

    if [[ ! -d "$VENV" ]]; then

        info "Creating virtual environment..."

        python -m venv "$VENV"

        success "Virtual environment created."

    fi

}


# ==========================================
# Install Dependencies
# ==========================================

install_dependencies() {

    if [[ ! -f "$REQUIREMENTS" ]]; then
        error "requirements.txt not found."
        exit 1
    fi

    info "Checking dependencies..."

    if ! "$PYTHON" -c "import streamlit" &>/dev/null; then

        info "Installing dependencies..."

        "$PIP" install -r "$REQUIREMENTS"

        success "Dependencies installed."

    else

        success "Dependencies already installed."

    fi

}


# ==========================================
# Run Application
# ==========================================

run_app() {

    check_project

    cd "$PROJECT_DIR"

    create_venv

    install_dependencies

    echo
    echo "=========================================="
    echo "      Telegram Bot Builder"
    echo "=========================================="
    echo
    echo "Project : $PROJECT_DIR"
    echo "Python  : $PYTHON"
    echo
    echo "Starting Streamlit..."
    echo

    "$PYTHON" -m streamlit run \
        "$PROJECT_DIR/app/streamlit_app.py" \
        2>&1 | tee "$LOG_FILE"

}


# ==========================================
# Install Global Command
# ==========================================

install_command() {

    check_project

    info "Installing $APP_NAME..."

    # If something already exists at the target,
    # remove it before creating the new symlink.
    if [[ -e "$INSTALL_PATH" || -L "$INSTALL_PATH" ]]; then

        info "Removing existing installation..."

        sudo rm -f "$INSTALL_PATH"

    fi

    # Create a symbolic link to the real project run.sh.
    sudo ln -s "$PROJECT_DIR/run.sh" "$INSTALL_PATH"

    sudo chmod +x "$PROJECT_DIR/run.sh"

    echo
    success "Installation completed."
    echo
    echo "Global command:"
    echo
    echo "    $APP_NAME"
    echo
    echo "Project:"
    echo
    echo "    $PROJECT_DIR"
    echo
    echo "Launcher:"
    echo
    echo "    $INSTALL_PATH -> $PROJECT_DIR/run.sh"
    echo

}


# ==========================================
# Uninstall Global Command
# ==========================================

uninstall_command() {

    if [[ ! -e "$INSTALL_PATH" && ! -L "$INSTALL_PATH" ]]; then

        info "$APP_NAME is not installed."

        exit 0

    fi

    info "Removing $APP_NAME..."

    sudo rm -f "$INSTALL_PATH"

    success "$APP_NAME has been uninstalled."

}


# ==========================================
# Show Help
# ==========================================

show_help() {

    echo
    echo "Telegram Bot Builder"
    echo
    echo "Usage:"
    echo
    echo "  ./run.sh              Start the application"
    echo "  ./run.sh run          Start the application"
    echo "  ./run.sh install      Install global command"
    echo "  ./run.sh uninstall    Remove global command"
    echo "  ./run.sh help         Show this help"
    echo
    echo "After installation:"
    echo
    echo "  telegram-bot-builder"
    echo

}


# ==========================================
# Main
# ==========================================

case "${1:-run}" in

    run)
        run_app
        ;;

    install)
        install_command
        ;;

    uninstall)
        uninstall_command
        ;;

    help|--help|-h)
        show_help
        ;;

    *)
        error "Unknown command: $1"
        show_help
        exit 1
        ;;

esac