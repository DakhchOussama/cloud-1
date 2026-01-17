#!/usr/bin/env bash
set -e

INSTALL_DIR="/usr/local/bin"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

install_packages() {
  echo "Installing missing dependencies: $*"

  if command_exists apt-get; then
    sudo apt-get update -y
    sudo apt-get install -y "$@"
  else
    echo "Unsupported package manager. Install dependencies manually."
    exit 1
  fi
}

check_dependencies() {
  local -n deps=$1
  local -n missing=$2
  
  echo "Checking required dependencies..."
  for pkg in "${deps[@]}"; do
    if ! command_exists "$pkg"; then
      missing+=("$pkg")
      echo "   $pkg is missing"
    else
      echo "   $pkg is installed"
    fi
  done
}

install_terraform() {
  if command_exists terraform; then
    echo "Terraform is already installed:"
    terraform version
    return 0
  fi

  echo -e "\n=== Installing Terraform ==="
  
  local deps=(curl wget unzip)
  local missing_pkgs=()
  check_dependencies deps missing_pkgs
  
  if [ "${#missing_pkgs[@]}" -ne 0 ]; then
    install_packages "${missing_pkgs[@]}"
  fi

  local os="$(uname | tr '[:upper:]' '[:lower:]')"
  local arch="$(uname -m)"

  case "$arch" in
    x86_64) arch="amd64" ;;
    aarch64 | arm64) arch="arm64" ;;
    *)
      echo "Unsupported architecture: $arch"
      return 1
      ;;
  esac

  local version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform \
    | grep -oP '"current_version":"\K[^"]+')

  echo "Installing Terraform v$version ($os/$arch)"

  local tmp_dir="$(mktemp -d)"
  cd "$tmp_dir"

  local zip="terraform_${version}_${os}_${arch}.zip"
  local url="https://releases.hashicorp.com/terraform/${version}/${zip}"

  curl -fsSL "$url" -o "$zip"
  unzip -q "$zip"

  chmod +x terraform
  sudo mv terraform "$INSTALL_DIR/terraform"

  cd /
  rm -rf "$tmp_dir"

  echo "Terraform installed successfully:"
  terraform version
}

install_ansible() {
  if command_exists ansible; then
    echo "Ansible is already installed:"
    ansible --version
    return 0
  fi

  echo -e "\n=== Installing Ansible ==="
  
  local deps=(python3 python3-pip)
  local missing_pkgs=()
  check_dependencies deps missing_pkgs
  
  if [ "${#missing_pkgs[@]}" -ne 0 ]; then
    install_packages "${missing_pkgs[@]}"
  fi

  echo "Installing Ansible via pip..."
  sudo pip3 install ansible

  echo "Ansible installed successfully:"
  ansible --version
}

main() {
  echo "=== Installation Script for Terraform and Ansible ==="
  
  install_terraform
  install_ansible
  
  echo -e "\n=== Installation Complete ==="
  echo "All tools are installed and ready to use."
}

main
