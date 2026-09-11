#!/usr/bin/env bash

set -e

# ==========================================
# Telegram Bot Builder - Development Runner
# ==========================================

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

VENV_DIR="$PROJECT_DIR/.venv"
PYTHON_BIN="$VENV_DIR/bin/python"
PIP_BIN="$VENV_DIR/bin/pip"

REQUIREMENTS_FILE="$PROJECT_DIR/requirements.txt"
STREAMLIT_APP="$PROJECT_DIR/app/streamlit_app.py"

LOG_FILE="/tmp/telegram-bot-builder-dev.log"


# ==========================================
# Output Functions
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
# Check Required Files
# ==========================================

check_files() {

    if [[ ! -f "$REQUIREMENTS_FILE" ]]; then
        error "requirements.txt not found:"
        error "$REQUIREMENTS_FILE"
        exit 1
    fi

    if [[ ! -f "$STREAMLIT_APP" ]]; then
        error "Streamlit application not found:"
        error "$STREAMLIT_APP"
        exit 1
    fi

}


# ==========================================
# Create Virtual Environment
# ==========================================

create_venv() {

    if [[ ! -d "$VENV_DIR" ]]; then

        info "Creating virtual environment..."

        python -m venv "$VENV_DIR"

        success "Virtual environment created."

    else

        info "Virtual environment already exists."

    fi

}


# ==========================================
# Activate Virtual Environment
# ==========================================

activate_venv() {

    info "Activating virtual environment..."

    # shellcheck disable=SC1091
    source "$VENV_DIR/bin/activate"

    success "Virtual environment activated."

}


# ==========================================
# Install Requirements
# ==========================================

install_requirements() {

    info "Upgrading pip..."

    python -m pip install --upgrade pip

    info "Installing project requirements..."

    python -m pip install -r "$REQUIREMENTS_FILE"

    success "Requirements installed."

}


# ==========================================
# Run Streamlit Application
# ==========================================

run_app() {

    cd "$PROJECT_DIR"

    info "Starting Streamlit application..."

    echo
    echo "=========================================="
    echo "      Telegram Bot Builder - DEV"
    echo "=========================================="
    echo
    echo "Project directory:"
    echo "$PROJECT_DIR"
    echo
    echo "Virtual environment:"
    echo "$VENV_DIR"
    echo
    echo "Application:"
    echo "$STREAMLIT_APP"
    echo
    echo "Press Ctrl+C to stop the application."
    echo

    python -m streamlit run "$STREAMLIT_APP" \
        2>&1 | tee "$LOG_FILE"

}


# ==========================================
# Main
# ==========================================

main() {

    check_files
    create_venv
    activate_venv
    install_requirements
    run_app

}


main