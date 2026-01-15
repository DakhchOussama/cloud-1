#!/bin/bash

# Ansible Deployment Script for WordPress Stack
# This script automates the deployment process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== WordPress Stack Ansible Deployment ===${NC}\n"

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo -e "${RED}Error: Ansible is not installed${NC}"
    echo "Install it with: sudo apt install ansible (Ubuntu/Debian) or brew install ansible (macOS)"
    exit 1
fi

# Check if Terraform output exists
if [ ! -f "../terraform/terraform.tfstate" ]; then
    echo -e "${YELLOW}Warning: Terraform state not found${NC}"
    echo "Make sure you've run 'terraform apply' in ../terraform first"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install Ansible collections
echo -e "${GREEN}Installing required Ansible collections...${NC}"
ansible-galaxy collection install -r requirements.yml

# Get EC2 IP from Terraform
if [ -f "../terraform/terraform.tfstate" ]; then
    EC2_IP=$(cd ../terraform && terraform output -raw instance_public_ip 2>/dev/null)
    if [ ! -z "$EC2_IP" ]; then
        echo -e "${GREEN}Found EC2 IP from Terraform: ${YELLOW}$EC2_IP${NC}"
        
        # Ask if user wants to update inventory
        read -p "Update inventory.ini with this IP? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Update inventory with the IP
            sed -i.bak "s/ansible_host=<EC2_PUBLIC_IP>/ansible_host=$EC2_IP/" inventory.ini
            sed -i.bak "s/ansible_host=[0-9.]\+/ansible_host=$EC2_IP/" inventory.ini
            echo -e "${GREEN}Updated inventory.ini${NC}"
        fi
    fi
fi

# Check SSH key
echo -e "\n${YELLOW}Make sure your SSH key is configured in inventory.ini${NC}"
grep "ansible_ssh_private_key_file" inventory.ini || echo -e "${RED}Warning: SSH key not found in inventory${NC}"

# Ask for deployment confirmation
echo -e "\n${YELLOW}Ready to deploy. This will:${NC}"
echo "1. Install Docker and Docker Compose on EC2"
echo "2. Copy all application files"
echo "3. Build and start containers"
echo ""
read -p "Continue with deployment? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 0
fi

# Run playbook
echo -e "\n${GREEN}Running Ansible playbook...${NC}\n"
ansible-playbook playbook.yml "$@"

# Check deployment status
if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}=== Deployment Completed Successfully! ===${NC}"
    if [ ! -z "$EC2_IP" ]; then
        echo -e "\nYour services are available at:"
        echo -e "  ${GREEN}WordPress (HTTPS):${NC} https://$EC2_IP"
        echo -e "  ${GREEN}phpMyAdmin:${NC} http://$EC2_IP:8080"
        echo -e "  ${YELLOW}Note: MariaDB is only accessible internally${NC}"
    fi
else
    echo -e "\n${RED}Deployment failed. Check the output above for errors.${NC}"
    exit 1
fi
