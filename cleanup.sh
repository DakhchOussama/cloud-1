#!/usr/bin/env bash
set -e

INSTALL_DIR="/usr/local/bin"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

uninstall_terraform() {
  if ! command_exists terraform; then
    echo "Terraform is not installed. Skipping..."
    return 0
  fi

  echo -e "\n=== Uninstalling Terraform ==="
  echo "Current version:"
  terraform version
  
  if [ -f "$INSTALL_DIR/terraform" ]; then
    sudo rm -f "$INSTALL_DIR/terraform"
    echo "✓ Terraform removed from $INSTALL_DIR"
  else
    echo "✗ Terraform binary not found in $INSTALL_DIR"
  fi
  
  if ! command_exists terraform; then
    echo "✓ Terraform successfully uninstalled"
  else
    echo "⚠ Terraform still found in PATH. May be installed in another location."
    which terraform
  fi
}

uninstall_ansible() {
  if ! command_exists ansible; then
    echo "Ansible is not installed. Skipping..."
    return 0
  fi

  echo -e "\n=== Uninstalling Ansible ==="
  echo "Current version:"
  ansible --version
  
  if command_exists pip3; then
    echo "Removing Ansible via pip..."
    sudo pip3 uninstall -y ansible ansible-core || true
    echo "✓ Ansible removed via pip"
  else
    echo "✗ pip3 not found. Cannot uninstall Ansible."
    return 1
  fi
  
  if ! command_exists ansible; then
    echo "✓ Ansible successfully uninstalled"
  else
    echo "⚠ Ansible still found in PATH. May be installed in another location."
    which ansible
  fi
}

main() {
  echo -e "\n=== Starting Cleanup Process ==="
  echo -e "\nDestroying any existing Terraform-managed infrastructure is recommended before uninstalling."
  cd ./src/terraform || { echo "Terraform directory not found!"; exit 1; }
  if command_exists terraform; then
	terraform destroy -auto-approve || echo "Terraform destroy failed or no infrastructure to destroy."
  else
	echo "Terraform not found, skipping destroy step."
  fi
  cd - || exit 1
  echo "=== Cleanup Script for Terraform and Ansible ==="
  echo "This will remove Terraform and Ansible from your system."
  echo ""
  read -p "Do you want to continue? (y/N): " -n 1 -r
  echo
  
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
  fi
  
  uninstall_terraform
  uninstall_ansible
  
  echo -e "\n=== Cleanup Complete ==="
}

main
