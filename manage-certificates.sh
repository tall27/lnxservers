#!/usr/bin/env bash
set -euo pipefail

# Certificate Management Script
# This script helps manage SSL certificates for the web servers

show_usage() {
    echo "Usage: $0 {generate|renew|info|trust}"
    echo ""
    echo "Commands:"
    echo "  generate  - Generate new self-signed certificates for all servers"
    echo "  renew     - Renew existing certificates (generates new ones)"
    echo "  info      - Show certificate information"
    echo "  trust     - Add certificates to system trust store (optional)"
    exit 1
}

generate_certificates() {
    echo "🔐 Generating self-signed certificates..."
    
    # Create directory for certificates
    sudo mkdir -p /etc/ssl/webservers/{apache,nginx} # ,tomcat}  # Tomcat commented out
    
    # Generate Apache certificate
    echo "Generating Apache certificate..."
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/webservers/apache/apache-selfsign.key \
        -out /etc/ssl/webservers/apache/apache-selfsign.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=apache.local"
    
    # Generate Nginx certificate
    echo "Generating Nginx certificate..."
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/webservers/nginx/nginx-selfsign.key \
        -out /etc/ssl/webservers/nginx/nginx-selfsign.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=nginx.local"
    
    # Generate Tomcat certificate - COMMENTED OUT (Tomcat not installed)
    # echo "Generating Tomcat certificate..."
    # sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    #     -keyout /etc/ssl/webservers/tomcat/tomcat-selfsign.key \
    #     -out /etc/ssl/webservers/tomcat/tomcat-selfsign.crt \
    #     -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=tomcat.local"
    # 
    # sudo openssl pkcs12 -export -in /etc/ssl/webservers/tomcat/tomcat-selfsign.crt \
    #     -inkey /etc/ssl/webservers/tomcat/tomcat-selfsign.key \
    #     -out /etc/ssl/webservers/tomcat/tomcat-selfsign.p12 \
    #     -name tomcat-selfsign -password pass:changeit
    
    # Set proper permissions
    sudo chmod 600 /etc/ssl/webservers/apache/apache-selfsign.key
    sudo chmod 644 /etc/ssl/webservers/apache/apache-selfsign.crt
    sudo chmod 600 /etc/ssl/webservers/nginx/nginx-selfsign.key
    sudo chmod 644 /etc/ssl/webservers/nginx/nginx-selfsign.crt
    # sudo chmod 600 /etc/ssl/webservers/tomcat/tomcat-selfsign.key  # Commented out
    # sudo chmod 644 /etc/ssl/webservers/tomcat/tomcat-selfsign.crt  # Commented out
    # sudo chmod 600 /etc/ssl/webservers/tomcat/tomcat-selfsign.p12  # Commented out
    
    echo "✅ Certificates generated successfully"
    
    # Restart services to pick up new certificates
    echo "🔄 Restarting services to load new certificates..."
    sudo systemctl restart apache2
    sudo systemctl restart nginx
    # sudo systemctl restart tomcat10  # Commented out - Tomcat not installed
    
    echo "✅ Services restarted with new certificates"
}

show_certificate_info() {
    echo "📋 Certificate Information:"
    echo ""
    
    if [ -f /etc/ssl/webservers/apache/apache-selfsign.crt ]; then
        echo "--- Apache Certificate ---"
        sudo openssl x509 -in /etc/ssl/webservers/apache/apache-selfsign.crt -text -noout | grep -E "(Subject:|Not Before|Not After)"
        echo ""
    fi
    
    if [ -f /etc/ssl/webservers/nginx/nginx-selfsign.crt ]; then
        echo "--- Nginx Certificate ---"
        sudo openssl x509 -in /etc/ssl/webservers/nginx/nginx-selfsign.crt -text -noout | grep -E "(Subject:|Not Before|Not After)"
        echo ""
    fi
    
    # if [ -f /etc/ssl/webservers/tomcat/tomcat-selfsign.crt ]; then  # Commented out - Tomcat not installed
    #     echo "--- Tomcat Certificate ---"
    #     sudo openssl x509 -in /etc/ssl/webservers/tomcat/tomcat-selfsign.crt -text -noout | grep -E "(Subject:|Not Before|Not After)"
    #     echo ""
    # fi
}

trust_certificates() {
    echo "🔒 Adding certificates to system trust store..."
    
    if [ -f /etc/ssl/webservers/apache/apache-selfsign.crt ]; then
        sudo cp /etc/ssl/webservers/apache/apache-selfsign.crt /usr/local/share/ca-certificates/apache-selfsign.crt
    fi
    
    if [ -f /etc/ssl/webservers/nginx/nginx-selfsign.crt ]; then
        sudo cp /etc/ssl/webservers/nginx/nginx-selfsign.crt /usr/local/share/ca-certificates/nginx-selfsign.crt
    fi
    
    # if [ -f /etc/ssl/webservers/tomcat/tomcat-selfsign.crt ]; then  # Commented out - Tomcat not installed
    #     sudo cp /etc/ssl/webservers/tomcat/tomcat-selfsign.crt /usr/local/share/ca-certificates/tomcat-selfsign.crt
    # fi
    
    sudo update-ca-certificates
    
    echo "✅ Certificates added to system trust store"
    echo "Note: Browsers may still show warnings for self-signed certificates"
}

# Main script logic
case "${1:-}" in
    generate|renew)
        generate_certificates
        ;;
    info)
        show_certificate_info
        ;;
    trust)
        trust_certificates
        ;;
    *)
        show_usage
        ;;
esac
