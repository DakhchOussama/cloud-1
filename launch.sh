#!/usr/bin/env bash

# check if ssh key exists
SSH_KEY_PATH=$TF_VAR_ssh_public_key_path
if [ -z "$SSH_KEY_PATH" ]; then
	echo "No SSH key path"
	exit 1
fi
if [ ! -f "$SSH_KEY_PATH" ]; then
	echo "SSH key not found. Generating one..."
	ssh-keygen -t rsa -b 4096 -N "" -f "$HOME/.ssh/ec2_instance"
else
	echo "SSH key already exists."
fi
