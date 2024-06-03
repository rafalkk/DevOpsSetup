#!/bin/bash

cd /etc/ssh

# Write CA private key to host_ca file
echo "$CA_PRIV_KEY" > host_ca
chmod 600 host_ca

# Generate host certificate from host pub key
sudo ssh-keygen -s host_ca -I $(hostname) -h ssh_host_rsa_key.pub

# Configure SSH to use the host certificate
echo "HostCertificate /etc/ssh/ssh_host_rsa_key-cert.pub" | sudo tee -a /etc/ssh/sshd_config

# Clean up
sudo rm host_ca

# Restart SSH service
sudo systemctl restart sshd
