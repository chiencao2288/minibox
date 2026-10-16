#!/usr/bin/env bash
# ==============================================================================
# Minibox One-Liner Installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/chiencao2288/minibox/main/install.sh | bash
#
# Custom install location:
#   curl -fsSL https://raw.githubusercontent.com/chiencao2288/minibox/main/install.sh | bash -s ~/.local/bin
#
# Environment variables:
#   MINIBOX_INSTALL_DIR  Custom installation directory (default: ~/.local/bin)
#   MINIBOX_OWNER        GitHub repository owner (default: chiencao2288)
#   MINIBOX_REPO         GitHub repository name (default: minibox)
#   MINIBOX_BRANCH       Git branch to pull from (default: main)
# ==============================================================================

set -euo pipefail

REPO_OWNER="${MINIBOX_OWNER:-chiencao2288}"
REPO_NAME="${MINIBOX_REPO:-minibox}"
BRANCH="${MINIBOX_BRANCH:-main}"
DEFAULT_INSTALL_DIR="${HOME}/.local/bin"
TARGET_DIR="${1:-${MINIBOX_INSTALL_DIR:-$DEFAULT_INSTALL_DIR}}"
TARGET_BIN="${TARGET_DIR}/minibox"
RAW_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/minibox"

# Color definitions
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_GREEN='\033[0;32m'
C_CYAN='\033[0;36m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'

info() {
    printf "${C_CYAN}ℹ %s${C_RESET}\n" "$*"
}

success() {
    printf "${C_GREEN}✔ %s${C_RESET}\n" "$*"
}

warn() {
    printf "${C_YELLOW}⚠ %s${C_RESET}\n" "$*"
}

error() {
    printf "${C_RED}✖ %s${C_RESET}\n" "$*" >&2
}

printf "\n${C_BOLD}📦 Minibox Installer${C_RESET}\n"
printf "──────────────────────────────────────────────────────\n"

# 1. Ensure target directory exists
mkdir -p "${TARGET_DIR}"

# 2. Acquire minibox binary
# If running inside a git clone where minibox exists locally, prefer local copy
SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
fi

if [[ -n "${SCRIPT_DIR}" && -f "${SCRIPT_DIR}/minibox" ]]; then
    info "Installing from local repository: ${SCRIPT_DIR}/minibox"
    cp -f "${SCRIPT_DIR}/minibox" "${TARGET_BIN}"
else
    info "Downloading minibox from ${REPO_OWNER}/${REPO_NAME} (${BRANCH})..."
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "${RAW_URL}" -o "${TARGET_BIN}"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "${TARGET_BIN}" "${RAW_URL}"
    else
        error "Neither 'curl' nor 'wget' is available. Please install one of them."
        exit 1
    fi
fi

# 3. Validate downloaded script
if [[ ! -s "${TARGET_BIN}" ]]; then
    error "Installation failed: Downloaded file is empty."
    exit 1
fi

if ! head -n 1 "${TARGET_BIN}" | grep -qE '^#!/(usr/bin/env bash|bin/bash)'; then
    error "Installation failed: File does not appear to be a valid Bash script."
    exit 1
fi

chmod +x "${TARGET_BIN}"
success "Installed executable to: ${TARGET_BIN}"

# 4. PATH verification
path_configured=true
case ":${PATH}:" in
    *":${TARGET_DIR}:"*)
        ;;
    *)
        path_configured=false
        warn "Directory '${TARGET_DIR}' is NOT in your current PATH."
        
        # Detect user shell config to append PATH
        shell_rc=""
        if [[ -n "${ZSH_VERSION:-}" || "${SHELL:-}" =~ zsh$ ]]; then
            shell_rc="${HOME}/.zshrc"
        elif [[ -f "${HOME}/.bashrc" ]]; then
            shell_rc="${HOME}/.bashrc"
        fi

        if [[ -n "${shell_rc}" && -w "${shell_rc}" ]]; then
            export_line="export PATH=\"${TARGET_DIR}:\$PATH\""
            if ! grep -qF "${TARGET_DIR}" "${shell_rc}" 2>/dev/null; then
                printf '\n# Added by minibox installer\n%s\n' "${export_line}" >> "${shell_rc}"
                info "Added '${TARGET_DIR}' to ${shell_rc}"
                info "Run 'source ${shell_rc}' or open a new terminal session to use minibox."
            fi
        else
            info "Add the following line to your ~/.bashrc or ~/.zshrc:"
            printf "    export PATH=\"%s:\$PATH\"\n" "${TARGET_DIR}"
        fi
        ;;
esac

# 5. Dependency check (Podman)
if ! command -v podman >/dev/null 2>&1; then
    warn "Podman is not installed on this system."
    warn "Minibox requires rootless Podman. Install it via your package manager:"
    warn "  - Fedora: sudo dnf install -y podman"
    warn "  - Ubuntu/Debian: sudo apt install -y podman"
    warn "  - Arch: sudo pacman -S podman"
fi

# 6. Verify installation
VERSION="$("${TARGET_BIN}" --version 2>/dev/null || echo "installed")"

printf "\n──────────────────────────────────────────────────────\n"
success "Minibox successfully installed! (${VERSION})"
printf "──────────────────────────────────────────────────────\n"

if [[ "${path_configured}" == "true" ]]; then
    printf "${C_BOLD}🚀 Quick Start:${C_RESET}\n"
    printf "   minibox create dev-box            # Create standard Debian container\n"
    printf "   minibox create --ai ai-box        # Create AI container with CUDA/PyTorch\n"
    printf "   minibox shell dev-box             # Open interactive shell\n"
    printf "   minibox list                      # List all managed containers\n"
    printf "   minibox help                      # Show all commands\n\n"
else
    printf "${C_BOLD}🚀 Quick Start (after reloading your shell):${C_RESET}\n"
    printf "   export PATH=\"%s:\$PATH\"\n" "${TARGET_DIR}"
    printf "   minibox --help\n\n"
fi
