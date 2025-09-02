#!/bin/bash
set -euo pipefail

# Service Health Check and Auto-Recovery Script
# This script ensures all services are running and healthy on every codespace start

echo "🔍 Ensuring all services are running and healthy..."

cd /workspaces/lnxservers

# Function to check if a service is active (container-compatible)
is_service_active() {
    case "$1" in
        ssh|sshd)
            pgrep -f sshd > /dev/null 2>&1
            ;;
        apache2)
            pgrep -f apache2 > /dev/null 2>&1
            ;;
        nginx)
            pgrep -f nginx > /dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to check if a port is responding
is_port_responding() {
    local port=$1
    local protocol=${2:-http}
    timeout 5 curl -s -f -k "${protocol}://localhost:${port}" >/dev/null 2>&1
}

# Function to start a service (container-compatible)
ensure_service() {
    local service=$1
    if ! is_service_active "$service"; then
        echo "⚡ Starting $service..."
        case "$service" in
            ssh|sshd)
                mkdir -p /run/sshd
                /usr/sbin/sshd -D -p 22 &
                ;;
            apache2)
                apache2ctl start
                ;;
            nginx)
                nginx
                ;;
        esac
        sleep 2
    fi
}

# Ensure SSH is running
ensure_service ssh
if ! is_service_active ssh; then
    echo "❌ SSH failed to start"
    exit 1
fi

# Ensure Apache is running
ensure_service apache2
if ! is_service_active apache2; then
    echo "❌ Apache failed to start"
    exit 1
fi

# Ensure Nginx is running
ensure_service nginx  
if ! is_service_active nginx; then
    echo "❌ Nginx failed to start"
    exit 1
fi

# Wait a moment for services to fully initialize
sleep 3

# Health checks with retries
echo "🏥 Performing health checks..."

# Check Apache ports
for i in {1..3}; do
    if is_port_responding 8080 && is_port_responding 8443 https; then
        echo "✅ Apache is responding on ports 8080 and 8443"
        break
    elif [ $i -eq 3 ]; then
        echo "⚠️  Apache health check failed after 3 attempts"
        pkill apache2 && sleep 1 && apache2ctl start
    else
        echo "⏳ Apache health check attempt $i failed, retrying..."
        sleep 2
    fi
done

# Check Nginx ports
for i in {1..3}; do
    if is_port_responding 8081 && is_port_responding 8444 https; then
        echo "✅ Nginx is responding on ports 8081 and 8444"
        break
    elif [ $i -eq 3 ]; then
        echo "⚠️  Nginx health check failed after 3 attempts"
        pkill nginx && sleep 1 && nginx
    else
        echo "⏳ Nginx health check attempt $i failed, retrying..."
        sleep 2
    fi
done

# Check SSH
if ! nc -z localhost 22 2>/dev/null; then
    echo "⚠️  SSH port 22 is not accessible"
else
    echo "✅ SSH is accessible on port 22"
fi

# Final status check
echo ""
echo "📊 Final Service Status:"
echo "SSH: $(is_service_active ssh && echo "✅ Running" || echo "❌ Not running")"
echo "Apache2: $(is_service_active apache2 && echo "✅ Running" || echo "❌ Not running")"  
echo "Nginx: $(is_service_active nginx && echo "✅ Running" || echo "❌ Not running")"

echo ""
echo "🌐 Your services are ready and accessible:"
echo "   - SSH:           Port 22 (public)"
echo "   - Apache HTTP:   Port 8080 (public)"
echo "   - Apache HTTPS:  Port 8443 (public)"  
echo "   - Nginx HTTP:    Port 8081 (public)"
echo "   - Nginx HTTPS:   Port 8444 (public)"
echo ""
echo "🚀 All services are running and ready for external access!"