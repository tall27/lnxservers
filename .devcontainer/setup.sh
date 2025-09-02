#!/bin/bash

# Auto-setup script for GitHub Codespaces
# This script will be called automatically when the codespace starts

set -e

echo "🚀 Setting up Native Web Servers Environment..."
echo "================================================"

# Change to workspace directory
cd /workspaces/lnxservers || cd "$(dirname "$0")/.."

# Make all scripts executable
echo "📁 Making scripts executable..."
chmod +x *.sh .devcontainer/*.sh

# Check if we should auto-install
if [ "$AUTO_INSTALL" = "true" ]; then
    echo "🔧 Auto-installing web servers..."
    sudo ./install-native-servers.sh
    
    echo "🔐 Configuring SSH..."
    ./configure-ssh.sh
    
    echo "⚡ Enabling services for auto-start..."
    sudo systemctl enable ssh apache2 nginx
    
    echo "🚀 Starting all services..."
    sudo systemctl start ssh apache2 nginx
    
    echo "📊 Checking service status..."
    ./manage-services.sh status
    
    echo ""
    echo "✅ Setup complete! Your servers are ready and will auto-start:"
    echo "   - SSH:    Port 22 (public access)"
    echo "   - Apache: Port 8080 (HTTP), 8443 (HTTPS) - public access"
    echo "   - Nginx:  Port 8081 (HTTP), 8444 (HTTPS) - public access"
    echo ""
    echo "🌐 All services are configured for automatic startup and external access!"
    echo "🔧 Use './manage-services.sh' for manual service management if needed"
else
    echo ""
    echo "⚡ Quick Start Commands:"
    echo "   sudo ./install-native-servers.sh  # Install web servers"
    echo "   ./configure-ssh.sh               # Configure SSH"
    echo "   ./manage-services.sh status      # Check status"
    echo ""
    echo "📖 See README.md for complete documentation"
    echo ""
    echo "💡 To enable auto-installation next time, set:"
    echo "   export AUTO_INSTALL=true"
fi

echo ""
echo "🎉 GitHub Codespace ready for native web server development!"
