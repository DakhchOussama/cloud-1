#!/usr/bin/env bash
set -e

# Source environment variables
set -a
source .env
set +a

echo "=== Starting Project Automation ==="

# Step 1: Install dependencies
echo "Step 1: Installing dependencies..."
./install-all.sh

# Step 2: Generate SSH key
echo "Step 2: Generating SSH key..."
./launch.sh

# Step 3: Terraform provisioning
echo "Step 3: Provisioning infrastructure with Terraform..."
cd src/terraform

terraform init

# First, try to apply - if key exists, it will error
echo "Attempting to provision infrastructure..."
if ! terraform apply -auto-approve 2>&1 | tee /tmp/tf_output.log; then
    # Check if the error is about duplicate key
    if grep -q "InvalidKeyPair.Duplicate" /tmp/tf_output.log || grep -q "already exists" /tmp/tf_output.log; then
        echo "Key pair already exists in AWS. Importing into Terraform state..."
        terraform import module.security_group.aws_key_pair.ec2 "ec2-key"
        echo "Re-running terraform apply..."
        terraform apply -auto-approve
    else
        echo "Terraform apply failed with unexpected error"
        cat /tmp/tf_output.log
        exit 1
    fi
fi

# Get the public IP from Terraform output
PUBLIC_IP=$(terraform output instance_public_ip | tr -d '"')
echo "EC2 Public IP: $PUBLIC_IP"

# Step 4: Update Ansible inventory
echo "Step 4: Updating Ansible inventory..."
cd ../ansible
cat > inventory.ini << EOF
[webservers]
ec2_instance ansible_host=$PUBLIC_IP ansible_user=ubuntu ansible_python_interpreter=/usr/bin/python3

[webservers:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_ssh_private_key_file=$ANSIBLE_PRIVATE_KEY_FILE
EOF
echo "Updated inventory.ini with IP: $PUBLIC_IP and key: $ANSIBLE_PRIVATE_KEY_FILE"

# Step 5: Update DuckDNS
echo "Step 5: Updating DuckDNS record..."
if [ -n "$DUCKDNS_TOKEN" ] && [ -n "$DUCKDNS_DOMAIN" ]; then
    DUCKDNS_RESPONSE=$(curl -s "https://www.duckdns.org/update?domains=$DUCKDNS_DOMAIN&token=$DUCKDNS_TOKEN&ip=$PUBLIC_IP")
    if [ "$DUCKDNS_RESPONSE" = "OK" ]; then
        echo "DuckDNS updated successfully."
    else
        echo "DuckDNS update failed: $DUCKDNS_RESPONSE"
        exit 1
    fi
else
    echo "Warning: DUCKDNS_TOKEN or DUCKDNS_DOMAIN not set. Skipping DuckDNS update."
fi

# Step 6: Ansible deployment
echo "Step 6: Deploying with Ansible..."
echo "Waiting for SSH to be available on $PUBLIC_IP..."
for i in {1..30}; do
    if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i "$ANSIBLE_PRIVATE_KEY_FILE" ubuntu@$PUBLIC_IP 'echo SSH ready' >/dev/null 2>&1; then
        echo "SSH is ready."
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 10
done

ansible-playbook -i inventory.ini playbook.yml

echo "=== Project Automation Complete ==="
echo "Access your WordPress site at: https://$DUCKDNS_DOMAIN.duckdns.org"
echo "phpMyAdmin: http://$PUBLIC_IP:8080"