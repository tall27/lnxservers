#!/bin/bash
set -euo pipefail

# Container-Compatible Service Startup Script
# This script starts services in container environments without systemd

echo "🚀 Starting services for container environment..."

# Function to check if a process is running
is_running() {
    pgrep -f "$1" > /dev/null 2>&1
}

# Function to wait for port to be available
wait_for_port() {
    local port=$1
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if nc -z localhost "$port" 2>/dev/null; then
            echo "✅ Port $port is ready"
            return 0
        fi
        echo "⏳ Waiting for port $port (attempt $attempt/$max_attempts)..."
        sleep 1
        ((attempt++))
    done
    
    echo "❌ Port $port failed to become ready after $max_attempts attempts"
    return 1
}

# Install openssh-server if not already installed
if ! dpkg -l | grep -q openssh-server; then
    echo "📦 Installing openssh-server..."
    apt-get update && apt-get install -y openssh-server
fi

# Set up SSH
echo "🔐 Setting up SSH..."
mkdir -p /run/sshd ~/.ssh
chmod 700 ~/.ssh

# Generate SSH key if it doesn't exist
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -C "container-access" -f ~/.ssh/id_rsa -N ""
fi

# Set up authorized keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys 2>/dev/null || true
chmod 600 ~/.ssh/authorized_keys

# Start SSH daemon
if ! is_running sshd; then
    echo "🚀 Starting SSH daemon..."
    /usr/sbin/sshd -D -p 22 &
    wait_for_port 22
fi

# Configure and start Apache
echo "🌐 Configuring and starting Apache..."
# Update ports configuration
sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf
sed -i 's/Listen 443/Listen 8443/' /etc/apache2/ports.conf
sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-enabled/000-default.conf

if ! is_running apache2; then
    apache2ctl start
    wait_for_port 8080
fi

# Configure and start Nginx  
echo "🌐 Configuring and starting Nginx..."
sed -i 's/listen 80/listen 8081/' /etc/nginx/sites-enabled/default
sed -i 's/listen \[::\]:80/listen [::]:8081/' /etc/nginx/sites-enabled/default

if ! is_running nginx; then
    nginx
    wait_for_port 8081
fi

echo ""
echo "🎉 All services started successfully!"
echo "📊 Service Status:"
echo "   - SSH:    Port 22  ✅"
echo "   - Apache: Port 8080 ✅"  
echo "   - Nginx:  Port 8081 ✅"
echo ""
echo "🌐 Services are ready for external access via GitHub Codespaces port forwarding!"