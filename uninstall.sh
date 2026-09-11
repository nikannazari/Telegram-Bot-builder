#!/usr/bin/env bash

set -e

# ==========================================
# Telegram Bot Builder Uninstaller
# ==========================================

APP_NAME="Telegram-Bot-Builder"

INSTALL_DIR="/opt/$APP_NAME"
COMMAND_PATH="/usr/bin/$APP_NAME"


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
        error "Do not run this uninstaller directly as root."
        error "Run it normally:"
        error "./uninstall.sh"
        exit 1
    fi

}


# ==========================================
# Confirm Uninstallation
# ==========================================

confirm_uninstall() {

    echo
    echo "The following files will be removed:"
    echo
    echo "  Source directory:"
    echo "    $INSTALL_DIR"
    echo
    echo "  Global command:"
    echo "    $COMMAND_PATH"
    echo

    read -r -p "Are you sure? [y/N]: " ANSWER

    case "$ANSWER" in
        y|Y|yes|YES)
            echo
            info "Continuing uninstallation..."
            ;;

        *)
            echo
            info "Uninstallation cancelled."
            exit 0
            ;;
    esac

}


# ==========================================
# Remove Global Command
# ==========================================

remove_launcher() {

    if [[ -e "$COMMAND_PATH" || -L "$COMMAND_PATH" ]]; then

        info "Removing global command..."

        sudo rm -f "$COMMAND_PATH"

        success "Removed $COMMAND_PATH"

    else

        info "Global command was not found."

    fi

}


# ==========================================
# Remove Source Code
# ==========================================

remove_source() {

    if [[ -d "$INSTALL_DIR" ]]; then

        info "Removing installed source code..."

        sudo rm -rf "$INSTALL_DIR"

        success "Removed $INSTALL_DIR"

    else

        info "Installation directory was not found."

    fi

}


# ==========================================
# Main Uninstallation
# ==========================================

main() {

    check_root_access
    confirm_uninstall
    remove_launcher
    remove_source

    echo
    echo "=========================================="
    echo " Uninstallation completed successfully"
    echo "=========================================="
    echo

}


main