#!/usr/bin/env bash

set -u

# ==========================================
# Telegram Bot Builder
# ==========================================

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$PROJECT_DIR/app"
VENV="$PROJECT_DIR/.venv"

INSTALL_PATH="/usr/local/bin/telegram-bot-builder"

STREAMLIT_PID=""
CLEANED_UP=false

# ==========================================
# Colors
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

STREAMLIT_LOG="/tmp/telegram-bot-builder-streamlit.log"

# ==========================================
# Cleanup
# ==========================================

cleanup() {
    if [[ "$CLEANED_UP" == true ]]; then
        return
    fi

    CLEANED_UP=true

    echo
    echo -e "${YELLOW}Stopping Telegram Bot Builder...${NC}"

    if [[ -n "$STREAMLIT_PID" ]] &&
       kill -0 "$STREAMLIT_PID" 2>/dev/null; then

        echo "Stopping Streamlit..."

        kill "$STREAMLIT_PID" 2>/dev/null
        wait "$STREAMLIT_PID" 2>/dev/null
    fi

    if [[ -n "${VIRTUAL_ENV:-}" ]]; then
        deactivate 2>/dev/null || true
    fi

    echo -e "${GREEN}Telegram Bot Builder stopped.${NC}"
}

error_exit() {
    echo
    echo -e "${RED}Error:${NC} $1"
    cleanup
    exit 1
}

trap cleanup EXIT
trap 'exit 130' SIGINT
trap 'exit 143' SIGTERM

# ==========================================
# Install
# ==========================================

install_command() {

    echo
    echo "=========================================="
    echo " Installing Telegram Bot Builder"
    echo "=========================================="
    echo

    if [[ ! -f "$PROJECT_DIR/run.sh" ]]; then
        error_exit "run.sh not found."
    fi

    if [[ -f "$INSTALL_PATH" ]]; then
        echo -e "${YELLOW}Telegram Bot Builder is already installed.${NC}"
        echo
        echo "Location:"
        echo "$INSTALL_PATH"
        return 0
    fi

    echo "Installing command to:"
    echo "$INSTALL_PATH"
    echo

    sudo cp "$PROJECT_DIR/run.sh" "$INSTALL_PATH" || \
        error_exit "Failed to copy launcher."

    sudo chmod +x "$INSTALL_PATH" || \
        error_exit "Failed to make launcher executable."

    echo
    echo -e "${GREEN}Installation successful.${NC}"
    echo
    echo "You can now run:"
    echo
    echo -e "${CYAN}telegram-bot-builder${NC}"
    echo
}

# ==========================================
# Uninstall
# ==========================================

uninstall_command() {

    echo
    echo "=========================================="
    echo " Uninstalling Telegram Bot Builder"
    echo "=========================================="
    echo

    if [[ ! -f "$INSTALL_PATH" ]]; then
        echo -e "${YELLOW}Telegram Bot Builder is not installed.${NC}"
        echo
        return 0
    fi

    echo "Removing:"
    echo "$INSTALL_PATH"
    echo

    sudo rm "$INSTALL_PATH" || \
        error_exit "Failed to remove launcher."

    echo
    echo -e "${GREEN}Uninstallation successful.${NC}"
    echo
}

# ==========================================
# Run Application
# ==========================================

run_command() {

    echo
    echo "=========================================="
    echo "       Telegram Bot Builder"
    echo "=========================================="
    echo

    if [[ ! -d "$APP_DIR" ]]; then
        error_exit "App directory not found: $APP_DIR"
    fi

    # ======================================
    # Virtual Environment
    # ======================================

    if [[ ! -f "$VENV/bin/activate" ]]; then

        echo -e "${YELLOW}Virtual environment not found.${NC}"
        echo

        read -r -p "Create .venv now? [Y/n]: " CREATE_VENV

        CREATE_VENV="${CREATE_VENV:-Y}"

        if [[ "$CREATE_VENV" =~ ^[Yy]$ ]]; then

            echo
            echo "Creating virtual environment..."

            python3 -m venv "$VENV" || \
                error_exit "Failed to create virtual environment."

            echo -e "${GREEN}Virtual environment created.${NC}"

        else
            error_exit "Virtual environment is required."
        fi
    fi

    # ======================================
    # Activate Virtual Environment
    # ======================================

    source "$VENV/bin/activate" || \
        error_exit "Failed to activate virtual environment."

    echo
    echo -e "${GREEN}Virtual environment activated.${NC}"
    echo "Python: $(command -v python)"

    # ======================================
    # Dependencies
    # ======================================

    if ! python -c "import streamlit" 2>/dev/null; then

        echo
        echo -e "${YELLOW}Streamlit is not installed.${NC}"
        echo "Installing project dependencies..."

        if [[ -f "$PROJECT_DIR/requirements.txt" ]]; then

            python -m pip install \
                -r "$PROJECT_DIR/requirements.txt" || \
                error_exit "Failed to install dependencies."

        else
            error_exit "requirements.txt not found."
        fi
    fi

    echo "Streamlit: $(command -v streamlit)"

    # ======================================
    # Start Streamlit
    # ======================================

    echo
    echo "Starting Streamlit..."

    cd "$PROJECT_DIR" || \
        error_exit "Failed to enter project directory."

    streamlit run "$APP_DIR/streamlit_app.py" \
        > "$STREAMLIT_LOG" 2>&1 &

    STREAMLIT_PID=$!

    sleep 2

    # ======================================
    # Check Streamlit
    # ======================================

    if ! kill -0 "$STREAMLIT_PID" 2>/dev/null; then

        echo
        echo -e "${RED}Streamlit failed to start.${NC}"
        echo

        if [[ -f "$STREAMLIT_LOG" ]]; then
            cat "$STREAMLIT_LOG"
        fi

        exit 1
    fi

    # ======================================
    # Running
    # ======================================

    echo
    echo "=========================================="
    echo -e "${GREEN} Telegram Bot Builder Running${NC}"
    echo "=========================================="
    echo
    echo "Streamlit PID: $STREAMLIT_PID"
    echo
    echo "Log:"
    echo "$STREAMLIT_LOG"
    echo
    echo "Press 'q' + Enter to quit."
    echo "Press Ctrl+C to quit."
    echo

    # ======================================
    # Wait
    # ======================================

    while true; do

        read -r command

        case "$command" in

            q|Q)
                exit 0
                ;;

            "")
                continue
                ;;

            *)
                echo "Unknown command. Press 'q' to quit."
                ;;

        esac

    done
}

# ==========================================
# Command Router
# ==========================================

case "${1:-run}" in

    install)
        install_command
        ;;

    uninstall)
        uninstall_command
        ;;

    run)
        run_command
        ;;

    *)
        echo
        echo "Telegram Bot Builder"
        echo
        echo "Usage:"
        echo
        echo "  ./run.sh              Start application"
        echo "  ./run.sh install      Install system command"
        echo "  ./run.sh uninstall    Remove system command"
        echo
        echo "After installation:"
        echo
        echo "  telegram-bot-builder"
        echo

        exit 1
        ;;

esac