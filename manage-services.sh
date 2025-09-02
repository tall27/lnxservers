#!/usr/bin/env bash
set -euo pipefail

# Service Management Script
# This script provides easy management of Apache, Nginx, and Tomcat services

show_usage() {
    echo "Usage: $0 {start|stop|restart|status|logs|cleanup}"
    echo ""
    echo "Commands:"
    echo "  start     - Start all web servers"
    echo "  stop      - Stop all web servers"
    echo "  restart   - Restart all web servers"
    echo "  status    - Show status of all services"
    echo "  logs      - Show recent logs for all services"
    echo "  cleanup   - Remove Docker containers and images (cleanup old setup)"
    exit 1
}

start_services() {
    echo "🚀 Starting web servers..."
    sudo systemctl start apache2
    sudo systemctl start nginx
    sudo systemctl start tomcat10
    sudo systemctl start ssh
    echo "✅ All services started"
    show_status
}

stop_services() {
    echo "🛑 Stopping web servers..."
    sudo systemctl stop apache2
    sudo systemctl stop nginx
    sudo systemctl stop tomcat10
    echo "✅ All services stopped"
}

restart_services() {
    echo "🔄 Restarting web servers..."
    sudo systemctl restart apache2
    sudo systemctl restart nginx
    sudo systemctl restart tomcat10
    sudo systemctl restart ssh
    echo "✅ All services restarted"
    show_status
}

show_status() {
    echo ""
    echo "📊 Service Status:"
    printf "Apache:  "
    sudo systemctl is-active apache2 && echo "✅ Running" || echo "❌ Stopped"
    printf "Nginx:   "
    sudo systemctl is-active nginx && echo "✅ Running" || echo "❌ Stopped"
    printf "Tomcat:  "
    sudo systemctl is-active tomcat10 && echo "✅ Running" || echo "❌ Stopped"
    printf "SSH:     "
    sudo systemctl is-active ssh && echo "✅ Running" || echo "❌ Stopped"
    
    echo ""
    echo "🌐 Server URLs:"
    echo "Apache HTTP:  http://localhost:8080"
    echo "Apache HTTPS: https://localhost:8443"
    echo "Nginx HTTP:   http://localhost:8081"
    echo "Nginx HTTPS:  https://localhost:8444"
    echo "Tomcat HTTP:  http://localhost:8082"
    echo "Tomcat HTTPS: https://localhost:8445"
    
    echo ""
    echo "🔗 SSH Access:"
    echo "ssh $(whoami)@localhost"
}

show_logs() {
    echo "📋 Recent logs:"
    echo ""
    echo "--- Apache Logs ---"
    sudo tail -n 10 /var/log/apache2/error.log 2>/dev/null || echo "No Apache logs found"
    echo ""
    echo "--- Nginx Logs ---"
    sudo tail -n 10 /var/log/nginx/error.log 2>/dev/null || echo "No Nginx logs found"
    echo ""
    echo "--- Tomcat Logs ---"
    sudo tail -n 10 /var/log/tomcat10/catalina.out 2>/dev/null || echo "No Tomcat logs found"
}

cleanup_docker() {
    echo "🧹 Cleaning up Docker environment..."
    
    # Stop and remove containers
    docker stop $(docker ps -aq) 2>/dev/null || true
    docker rm $(docker ps -aq) 2>/dev/null || true
    
    # Remove images
    docker rmi $(docker images -q) 2>/dev/null || true
    
    # Remove Docker volumes
    docker volume prune -f 2>/dev/null || true
    
    # Remove .devcontainer directory
    if [ -d ".devcontainer" ]; then
        echo "Removing .devcontainer directory..."
        rm -rf .devcontainer
    fi
    
    echo "✅ Docker cleanup complete"
}

# Main script logic
case "${1:-}" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    cleanup)
        cleanup_docker
        ;;
    *)
        show_usage
        ;;
esac
