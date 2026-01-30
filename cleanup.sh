#!/usr/bin/env bash

set -e

echo "=== Cleaning up user-level dependencies ==="

BIN_DIR="$HOME/goinfre/.bin"
LOCAL_DIR="$HOME/goinfre/.local"
PIP_CACHE="$HOME/goinfre/.cache/pip"

# ----------------------------
# Remove Terraform
# ----------------------------
if [ -f "$BIN_DIR/terraform" ]; then
    echo "Removing Terraform..."
    rm -f "$BIN_DIR/terraform"
else
    echo "Terraform not found in $BIN_DIR"
fi

# ----------------------------
# Remove Ansible (pip --user)
# ----------------------------
echo "Removing Ansible (pip --user)..."

if command -v python3 >/dev/null 2>&1; then
    python3 -m pip uninstall -y ansible ansible-core >/dev/null 2>&1 || true
else
    echo "python3 not found, skipping pip uninstall"
fi

# Remove leftover ansible binaries
for bin in ansible ansible-playbook ansible-galaxy ansible-inventory ansible-config; do
    if [ -f "$LOCAL_DIR/bin/$bin" ]; then
        rm -f "$LOCAL_DIR/bin/$bin"
        echo "Removed $bin"
    fi
done

# ----------------------------
# Optional: Clean pip cache
# ----------------------------
if [ -d "$PIP_CACHE" ]; then
    echo "Cleaning pip cache..."
    rm -rf "$PIP_CACHE"
fi

# ----------------------------
# Optional: Remove empty dirs
# ----------------------------
rmdir "$BIN_DIR" 2>/dev/null || true
rmdir "$LOCAL_DIR/bin" 2>/dev/null || true
rmdir "$LOCAL_DIR" 2>/dev/null || true

rm -rf ~/.ssh/ec2_instance
rm -rf ~/.ssh/ec2_instance.pub

# ----------------------------
# Final verification
# ----------------------------
echo
echo "Verification:"
command -v terraform >/dev/null 2>&1 \
    && echo "Terraform still found in PATH" \
    || echo "Terraform removed"

command -v ansible-playbook >/dev/null 2>&1 \
    && echo "Ansible-playbook still found in PATH" \
    || echo "Ansible removed"

echo
echo "Cleanup complete."
