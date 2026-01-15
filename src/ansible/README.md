# Ansible Configuration for WordPress Stack Deployment

This Ansible configuration deploys a complete WordPress stack with Docker Compose on an AWS EC2 instance.

## Architecture

- **nginx**: Web server with SSL (Port 443) - Publicly accessible
- **WordPress**: PHP-FPM application (Port 9000) - Accessible through nginx
- **MariaDB**: Database (Port 3306) - Internal only, not exposed
- **phpMyAdmin**: Database management (Port 8080) - Publicly accessible

## Prerequisites

1. **Terraform**: Infrastructure must be provisioned first
   ```bash
   cd ../terraform
   terraform init
   terraform apply
   ```

2. **AWS SSH Key**: Ensure you have the SSH key pair for EC2 access

3. **Ansible**: Install Ansible on your local machine
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install ansible

   # macOS
   brew install ansible
   ```

4. **Ansible Collections**: Install required collections
   ```bash
   ansible-galaxy collection install community.docker
   ```

## Configuration Steps

### 1. Update Inventory

Edit `inventory.ini` and replace `<EC2_PUBLIC_IP>` with your actual EC2 public IP from Terraform output:

```bash
# Get the IP from Terraform
cd ../terraform
terraform output instance_public_ip
```

Update the inventory file:
```ini
[webservers]
ec2_instance ansible_host=YOUR_EC2_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/your-key.pem
```

### 2. Customize Variables (Optional)

Edit `group_vars/webservers.yml` to customize:
- Database credentials
- WordPress admin credentials
- Site title and configuration

### 3. Verify SSH Access

Test SSH connection to your EC2 instance:
```bash
ssh -i ~/.ssh/your-key.pem ubuntu@YOUR_EC2_IP
```

## Deployment

### Run the Playbook

```bash
# Deploy everything
ansible-playbook playbook.yml

# Run with verbose output
ansible-playbook playbook.yml -v

# Check what would be changed (dry-run)
ansible-playbook playbook.yml --check
```

### Deploy Specific Roles

```bash
# Only install Docker
ansible-playbook playbook.yml --tags docker

# Only deploy application
ansible-playbook playbook.yml --tags deploy
```

## Accessing Services

After deployment, access your services:

- **WordPress (HTTPS)**: `https://YOUR_EC2_IP`
- **phpMyAdmin**: `http://YOUR_EC2_IP:8080`
- **MariaDB**: Only accessible internally within Docker network

## Security Notes

1. **Database Security**: MariaDB is not exposed to the public internet. It's only accessible within the Docker network.

2. **AWS Security Groups**: Ensure your Terraform configuration includes:
   - Port 443 (HTTPS) - Open to 0.0.0.0/0
   - Port 8080 (phpMyAdmin) - Open to your IP or 0.0.0.0/0
   - Port 22 (SSH) - Open to your IP only
   - Port 3306 (MySQL) - Should NOT be exposed publicly

3. **Change Default Passwords**: Update all passwords in `group_vars/webservers.yml` before deployment

4. **SSL Certificates**: The nginx configuration should use proper SSL certificates. Update the nginx config with valid certificates for production.

## Troubleshooting

### Check Container Status
```bash
# SSH into EC2
ssh -i ~/.ssh/your-key.pem ubuntu@YOUR_EC2_IP

# Check running containers
docker ps

# Check container logs
docker logs nginx
docker logs wordpress
docker logs mariadb
docker logs phpmyadmin

# Check Docker Compose status
cd /opt/inception
docker compose ps
```

### Restart Services
```bash
cd /opt/inception
docker compose restart
```

### Rebuild and Restart
```bash
cd /opt/inception
docker compose down
docker compose up -d --build
```

## Directory Structure

```
ansible/
├── ansible.cfg                 # Ansible configuration
├── inventory.ini               # EC2 hosts inventory
├── playbook.yml               # Main playbook
├── group_vars/
│   └── webservers.yml         # Variables for customization
└── roles/
    ├── docker/                # Docker installation role
    │   └── tasks/
    │       └── main.yaml
    └── deploy/                # Application deployment role
        ├── tasks/
        │   └── main.yaml
        └── templates/
            └── env.j2         # Environment variables template
```

## Maintenance

### Update Application
```bash
# Re-run the deployment
ansible-playbook playbook.yml

# Or just the deploy role
ansible-playbook playbook.yml --tags deploy
```

### Backup Database
```bash
# SSH to EC2
ssh -i ~/.ssh/your-key.pem ubuntu@YOUR_EC2_IP

# Backup database
docker exec mariadb mysqldump -u root -p wordpress > backup.sql
```

## Clean Up

To destroy everything:
```bash
# Stop and remove containers (on EC2)
cd /opt/inception
docker compose down -v

# Destroy infrastructure (from local machine)
cd ../terraform
terraform destroy
```
