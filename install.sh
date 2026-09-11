#!/usr/bin/env bash

set -e

# ==========================================
# Telegram Bot Builder Installer
# ==========================================

APP_NAME="Telegram-Bot-Builder"

INSTALL_DIR="/opt/$APP_NAME"
COMMAND_PATH="/usr/bin/$APP_NAME"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SOURCE_DIR="$SCRIPT_DIR"

VENV_DIR="$INSTALL_DIR/.venv"
PYTHON_BIN="$VENV_DIR/bin/python"
PIP_BIN="$VENV_DIR/bin/pip"

LAUNCHER_CONTENT='#!/usr/bin/env bash

set -e

APP_NAME="Telegram-Bot-Builder"
INSTALL_DIR="/opt/$APP_NAME"

PYTHON_BIN="$INSTALL_DIR/.venv/bin/python"
STREAMLIT_APP="$INSTALL_DIR/app/streamlit_app.py"

if [[ ! -f "$STREAMLIT_APP" ]]; then
    echo "[ERROR] Streamlit application not found:"
    echo "$STREAMLIT_APP"
    exit 1
fi

if [[ ! -x "$PYTHON_BIN" ]]; then
    echo "[ERROR] Python virtual environment not found:"
    echo "$PYTHON_BIN"
    exit 1
fi

cd "$INSTALL_DIR"

exec "$PYTHON_BIN" -m streamlit run "$STREAMLIT_APP"
'


# ==========================================
# Functions
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
# Check Root Permission
# ==========================================

check_root_access() {

    if [[ "$EUID" -eq 0 ]]; then
        error "Do not run this installer directly as root."
        error "Run it normally:"
        error "./install.sh"
        exit 1
    fi

}


# ==========================================
# Check Required Files
# ==========================================

check_source_files() {

    if [[ ! -f "$SOURCE_DIR/main.py" ]]; then
        error "main.py was not found in:"
        error "$SOURCE_DIR"
        exit 1
    fi

    if [[ ! -f "$SOURCE_DIR/requirements.txt" ]]; then
        error "requirements.txt was not found in:"
        error "$SOURCE_DIR"
        exit 1
    fi

    if [[ ! -f "$SOURCE_DIR/app/streamlit_app.py" ]]; then
        error "app/streamlit_app.py was not found."
        exit 1
    fi

}


# ==========================================
# Install Source Code
# ==========================================

install_source() {

    info "Creating installation directory..."

    sudo mkdir -p "$INSTALL_DIR"

    info "Copying application source code..."

    sudo cp -r "$SOURCE_DIR/app" "$INSTALL_DIR/"
    sudo cp -r "$SOURCE_DIR/src" "$INSTALL_DIR/"
    sudo cp -r "$SOURCE_DIR/assets" "$INSTALL_DIR/" 2>/dev/null || true

    sudo cp "$SOURCE_DIR/main.py" "$INSTALL_DIR/"
    sudo cp "$SOURCE_DIR/requirements.txt" "$INSTALL_DIR/"

    if [[ -f "$SOURCE_DIR/pyproject.toml" ]]; then
        sudo cp "$SOURCE_DIR/pyproject.toml" "$INSTALL_DIR/"
    fi

    if [[ -d "$SOURCE_DIR/bots" ]]; then
        sudo cp -r "$SOURCE_DIR/bots" "$INSTALL_DIR/"
    else
        sudo mkdir -p "$INSTALL_DIR/bots"
    fi

    if [[ -d "$SOURCE_DIR/generated" ]]; then
        sudo cp -r "$SOURCE_DIR/generated" "$INSTALL_DIR/"
    else
        sudo mkdir -p "$INSTALL_DIR/generated"
    fi

    success "Source code installed in $INSTALL_DIR"

}


# ==========================================
# Create Virtual Environment
# ==========================================

create_virtual_environment() {

    if [[ ! -d "$VENV_DIR" ]]; then

        info "Creating virtual environment..."

        sudo python -m venv "$VENV_DIR"

        success "Virtual environment created."

    else

        info "Virtual environment already exists."

    fi

}


# ==========================================
# Install Python Dependencies
# ==========================================

install_dependencies() {

    info "Installing Python dependencies..."

    sudo "$PIP_BIN" install --upgrade pip
    sudo "$PIP_BIN" install -r "$INSTALL_DIR/requirements.txt"

    success "Python dependencies installed."

}


# ==========================================
# Set Permissions
# ==========================================

set_permissions() {

    info "Setting permissions..."

    sudo chmod -R a+rX "$INSTALL_DIR"

    sudo mkdir -p "$INSTALL_DIR/bots"
    sudo mkdir -p "$INSTALL_DIR/generated"

    sudo chmod -R a+rwX "$INSTALL_DIR/bots"
    sudo chmod -R a+rwX "$INSTALL_DIR/generated"

    success "Permissions configured."

}


# ==========================================
# Create Global Launcher
# ==========================================

create_launcher() {

    info "Creating global command..."

    echo "$LAUNCHER_CONTENT" | sudo tee "$COMMAND_PATH" > /dev/null

    sudo chmod +x "$COMMAND_PATH"

    success "Global command created:"
    success "$COMMAND_PATH"

}


# ==========================================
# Main Installation
# ==========================================

main() {

    check_root_access
    check_source_files

    echo
    echo "=========================================="
    echo " Installing $APP_NAME"
    echo "=========================================="
    echo

    install_source
    create_virtual_environment
    install_dependencies
    set_permissions
    create_launcher

    echo
    echo "=========================================="
    echo " Installation completed successfully"
    echo "=========================================="
    echo
    echo "Run the application with:"
    echo
    echo "    $APP_NAME"
    echo
    echo "Installed source:"
    echo
    echo "    $INSTALL_DIR"
    echo
    echo "Global command:"
    echo
    echo "    $COMMAND_PATH"
    echo

}


main
