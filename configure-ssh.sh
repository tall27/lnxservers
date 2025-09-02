#!/usr/bin/env bash
set -euo pipefail

# SSH Configuration Script for Web Server Access
# This script sets up SSH key-based authentication and configures SSH access to each server

echo "🔐 Configuring SSH access for web servers..."

# Ensure SSH directory exists
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Generate SSH key if it doesn't exist
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generating SSH key pair..."
    ssh-keygen -t rsa -b 4096 -C "webserver-access" -f ~/.ssh/id_rsa -N ""
fi

# Add public key to authorized_keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Configure SSH daemon for security
sudo tee /etc/ssh/sshd_config.d/webserver-access.conf > /dev/null <<EOF
# Web Server SSH Configuration
Port 22
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
X11Forwarding no
AllowTcpForwarding yes
GatewayPorts no
ClientAliveInterval 60
ClientAliveCountMax 3
EOF

# Restart SSH service
sudo systemctl restart ssh

# Create simplified SSH config (port forwarding not needed in Codespaces)
tee ~/.ssh/config > /dev/null <<EOF
# Basic SSH Configuration for Codespace environment
# Port forwarding disabled - direct access available via Codespace URLs

Host localhost
    HostName localhost
    User $(whoami)
    Port 22
    IdentityFile ~/.ssh/id_rsa

# Legacy port forwarding configurations (DISABLED for Codespaces)
# Host apache-server
#     HostName localhost
#     User $(whoami)
#     Port 22
#     IdentityFile ~/.ssh/id_rsa
#     LocalForward 8080 localhost:8080
#     LocalForward 8443 localhost:8443
# 
# Host nginx-server
#     HostName localhost
#     User $(whoami)
#     Port 22
#     IdentityFile ~/.ssh/id_rsa
#     LocalForward 8081 localhost:8081
#     LocalForward 8444 localhost:8444
# 
# Host tomcat-server (DISABLED - Tomcat not installed)
#     HostName localhost
#     User $(whoami)
#     Port 22
#     IdentityFile ~/.ssh/id_rsa
#     LocalForward 8082 localhost:8082
#     LocalForward 8445 localhost:8445
# 
# Host all-servers
#     HostName localhost
#     User $(whoami)
#     Port 22
#     IdentityFile ~/.ssh/id_rsa
#     LocalForward 8080 localhost:8080
#     LocalForward 8443 localhost:8443
#     LocalForward 8081 localhost:8081
#     LocalForward 8444 localhost:8444
#     LocalForward 8082 localhost:8082
#     LocalForward 8445 localhost:8445
EOF

chmod 600 ~/.ssh/config

echo "✅ SSH configuration complete!"
echo ""
echo "ℹ️  SSH is configured for internal use only."
echo "ℹ️  In Codespaces, you have direct terminal access - no port forwarding needed!"
echo ""
echo "� Basic SSH connection (if needed):"
echo "ssh $(whoami)@localhost"
echo ""
echo "🔑 SSH key location: ~/.ssh/id_rsa"
echo "🔑 Public key: ~/.ssh/id_rsa.pub"
echo ""
echo "🌐 Access your web servers directly through Codespace URLs!"
