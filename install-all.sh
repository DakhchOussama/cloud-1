#!/usr/bin/env bash

set -e
set -o pipefail

# ============================
# User-level binary setup
# ============================
BIN_DIR="$HOME/goinfre/.bin"
LOCAL_BIN="$HOME/goinfre/.local/bin"
LOCAL_TMP="$HOME/goinfre/tmp"

mkdir -p "$BIN_DIR"
mkdir -p "$LOCAL_BIN"
mkdir -p "$LOCAL_TMP"

export PATH="$BIN_DIR:$LOCAL_BIN:$PATH"

# ============================
# Load environment variables
# ============================
set -a
source .env
set +a

echo "=== Starting Project Automation ==="

# ============================
# Step 0: Install Terraform (user-level)
# ============================
if ! command -v terraform >/dev/null 2>&1; then
    echo "Installing Terraform locally..."

    TF_VERSION="1.14.3"
    TF_ZIP="terraform_${TF_VERSION}_linux_amd64.zip"
	TF_ZIP_PATH="$LOCAL_TMP/$TF_ZIP"

    curl -fsSL -o $TF_ZIP_PATH \
        "https://releases.hashicorp.com/terraform/${TF_VERSION}/${TF_ZIP}"

    unzip -o "$TF_ZIP_PATH" -d "$BIN_DIR"
    chmod +x "$BIN_DIR/terraform"

    rm $TF_ZIP_PATH
else
    echo "Terraform already installed: $(terraform version | head -n1)"
fi

# ============================
# Step 1: Install Ansible (user-level)
# ============================
if ! command -v ansible-playbook >/dev/null 2>&1; then
    echo "Installing Ansible locally via pip..."
    python3 -m pip install --user --upgrade pip
    python3 -m pip install --user ansible
else
    echo "Ansible already installed: $(ansible --version | head -n1)"
fi