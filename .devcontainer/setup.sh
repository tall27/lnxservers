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
    
    echo "📊 Checking service status..."
    ./manage-services.sh status
    
    echo ""
    echo "✅ Setup complete! Your servers are ready:"
    echo "   - Apache: http://localhost:8080 (HTTPS: 8443)"
    echo "   - Nginx:  http://localhost:8081 (HTTPS: 8444)" 
    echo "   - Tomcat: http://localhost:8082 (HTTPS: 8445)"
    echo ""
    echo "🔧 Use './manage-services.sh' to manage services"
    echo "📖 Check README.md for detailed usage instructions"
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
