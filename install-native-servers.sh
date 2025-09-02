#!/usr/bin/env bash
set -euo pipefail

# Native Installation Script for Apache, Nginx, and Tomcat
# This script installs and configures the three web servers directly on the OS
# with self-signed certificates and SSH access

echo "🚀 Installing Apache, Nginx, and Tomcat natively on the OS..."

# Update package lists
sudo apt-get update

# Install required packages
sudo apt-get install -y \
    apache2 \
    nginx \
    # tomcat10 \
    openssh-server \
    openssl \
    ca-certificates \
    curl \
    jq \
    ufw

echo "📦 Packages installed successfully"

# Configure SSH
echo "🔐 Configuring SSH server..."
sudo systemctl enable ssh
sudo systemctl start ssh

# Configure firewall for SSH and web services
sudo ufw allow ssh
sudo ufw allow 8080/tcp  # Apache HTTP
sudo ufw allow 8443/tcp  # Apache HTTPS
sudo ufw allow 8081/tcp  # Nginx HTTP
sudo ufw allow 8444/tcp  # Nginx HTTPS
# sudo ufw allow 8082/tcp  # Tomcat HTTP
# sudo ufw allow 8445/tcp  # Tomcat HTTPS
sudo ufw --force enable

echo "🔥 Firewall configured for SSH and web services"

# Create directory for certificates
sudo mkdir -p /etc/ssl/webservers/{apache,nginx} # ,tomcat}

echo "🔒 Generating self-signed certificates..."

# Generate self-signed certificate for Apache
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/webservers/apache/apache.key \
    -out /etc/ssl/webservers/apache/apache.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=apache.local"

# Generate self-signed certificate for Nginx
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/webservers/nginx/nginx.key \
    -out /etc/ssl/webservers/nginx/nginx.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=nginx.local"

# Generate self-signed certificate for Tomcat (PKCS12 format) - COMMENTED OUT
# sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
#     -keyout /etc/ssl/webservers/tomcat/tomcat.key \
#     -out /etc/ssl/webservers/tomcat/tomcat.crt \
#     -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=tomcat.local"

# sudo openssl pkcs12 -export -in /etc/ssl/webservers/tomcat/tomcat.crt \
#     -inkey /etc/ssl/webservers/tomcat/tomcat.key \
#     -out /etc/ssl/webservers/tomcat/tomcat.p12 \
#     -name tomcat-selfsign -password pass:changeit

# Set proper permissions
sudo chmod 600 /etc/ssl/webservers/apache/apache.key
sudo chmod 644 /etc/ssl/webservers/apache/apache.crt
sudo chmod 600 /etc/ssl/webservers/nginx/nginx.key
sudo chmod 644 /etc/ssl/webservers/nginx/nginx.crt
# sudo chmod 600 /etc/ssl/webservers/tomcat/tomcat.key      # Commented out - Tomcat not installed
# sudo chmod 644 /etc/ssl/webservers/tomcat/tomcat.crt      # Commented out - Tomcat not installed
# sudo chmod 600 /etc/ssl/webservers/tomcat/tomcat.p12     # Commented out - Tomcat not installed

echo "✅ Self-signed certificates generated"

# Configure Apache
echo "🌐 Configuring Apache..."

# Update Apache ports
sudo sed -i 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf
echo "Listen 8443" | sudo tee -a /etc/apache2/ports.conf

# Configure Apache virtual host for HTTP
sudo tee /etc/apache2/sites-available/apache-http.conf > /dev/null <<EOF
<VirtualHost *:8080>
    ServerName apache.local
    DocumentRoot /var/www/apache
    ErrorLog \${APACHE_LOG_DIR}/apache_error.log
    CustomLog \${APACHE_LOG_DIR}/apache_access.log combined
</VirtualHost>
EOF

# Configure Apache virtual host for HTTPS
sudo tee /etc/apache2/sites-available/apache-https.conf > /dev/null <<EOF
<VirtualHost *:8443>
    ServerName apache.local
    DocumentRoot /var/www/apache
    SSLEngine on
    SSLCertificateFile /etc/ssl/webservers/apache/apache.crt
    SSLCertificateKeyFile /etc/ssl/webservers/apache/apache.key
    ErrorLog \${APACHE_LOG_DIR}/apache_ssl_error.log
    CustomLog \${APACHE_LOG_DIR}/apache_ssl_access.log combined
</VirtualHost>
EOF

# Create Apache document root and landing page
sudo mkdir -p /var/www/apache
echo '<h1>Apache Server - Native Installation</h1><p>Running on port 8080 (HTTP) and 8443 (HTTPS)</p>' | sudo tee /var/www/apache/index.html

# Enable Apache modules and sites
sudo a2enmod ssl
sudo a2ensite apache-http
sudo a2ensite apache-https
sudo a2dissite 000-default

echo "✅ Apache configured"

# Configure Nginx
echo "🔧 Configuring Nginx..."

# Create Nginx document root and landing page
sudo mkdir -p /var/www/nginx
echo '<h1>Nginx Server - Native Installation</h1><p>Running on port 8081 (HTTP) and 8444 (HTTPS)</p>' | sudo tee /var/www/nginx/index.html

# Configure Nginx HTTP server
sudo tee /etc/nginx/sites-available/nginx-http > /dev/null <<EOF
server {
    listen 8081;
    server_name nginx.local;
    root /var/www/nginx;
    index index.html;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Configure Nginx HTTPS server
sudo tee /etc/nginx/sites-available/nginx-https > /dev/null <<EOF
server {
    listen 8444 ssl;
    server_name nginx.local;
    root /var/www/nginx;
    index index.html;
    
    ssl_certificate /etc/ssl/webservers/nginx/nginx.crt;
    ssl_certificate_key /etc/ssl/webservers/nginx/nginx.key;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Enable Nginx sites
sudo ln -sf /etc/nginx/sites-available/nginx-http /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/nginx-https /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

echo "✅ Nginx configured"

# Configure Tomcat - COMMENTED OUT (not installing Tomcat)
# echo "🍅 Configuring Tomcat..."
# 
# # Update Tomcat server.xml for custom ports and SSL
# sudo cp /etc/tomcat10/server.xml /etc/tomcat10/server.xml.backup
# 
# # Configure Tomcat ports and SSL
# sudo tee /etc/tomcat10/server.xml > /dev/null <<EOF
# <?xml version="1.0" encoding="UTF-8"?>
# <Server port="8005" shutdown="SHUTDOWN">
#   <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
#   <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
#   <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
#   <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
#   <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />
# 
#   <GlobalNamingResources>
#     <Resource name="UserDatabase" auth="Container"
#               type="org.apache.catalina.UserDatabase"
#               description="User database that can be updated and saved"
#               factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
#               pathname="conf/tomcat-users.xml" />
#   </GlobalNamingResources>
# 
#   <Service name="Catalina">
#     <!-- HTTP Connector on port 8082 -->
#     <Connector port="8082" protocol="HTTP/1.1"
#                connectionTimeout="20000"
#                redirectPort="8445" />
#     
#     <!-- HTTPS Connector on port 8445 -->
#     <Connector port="8445" protocol="HTTP/1.1" SSLEnabled="true"
#                maxThreads="150" scheme="https" secure="true"
#                clientAuth="false" sslProtocol="TLS"
#                keystoreFile="/etc/ssl/webservers/tomcat/tomcat.p12"
#                keystoreType="PKCS12"
#                keystorePass="changeit" />
# 
#     <Engine name="Catalina" defaultHost="localhost">
#       <Realm className="org.apache.catalina.realm.LockOutRealm">
#         <Realm className="org.apache.catalina.realm.UserDatabaseRealm"
#                resourceName="UserDatabase"/>
#       </Realm>
# 
#       <Host name="localhost" appBase="webapps"
#             unpackWARs="true" autoDeploy="true">
#         <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
#                prefix="localhost_access_log" suffix=".txt"
#                pattern="%h %l %u %t &quot;%r&quot; %s %b" />
#       </Host>
#     </Engine>
#   </Service>
# </Server>
# EOF

# Create Tomcat landing page - COMMENTED OUT
# sudo mkdir -p /var/lib/tomcat10/webapps/ROOT
# echo '<h1>Tomcat Server - Native Installation</h1><p>Running on port 8082 (HTTP) and 8445 (HTTPS)</p>' | sudo tee /var/lib/tomcat10/webapps/ROOT/index.html

# echo "✅ Tomcat configured"

# Create dedicated users for each service (optional security enhancement)
echo "👥 Creating service users..."
sudo useradd -r -s /bin/false apache-user || true
sudo useradd -r -s /bin/false nginx-user || true
# sudo useradd -r -s /bin/false tomcat-user || true  # Commented out - Tomcat not installed

# Set ownership
sudo chown -R www-data:www-data /var/www/apache
sudo chown -R www-data:www-data /var/www/nginx
# sudo chown -R tomcat:tomcat /var/lib/tomcat10/webapps/ROOT  # Commented out - Tomcat not installed

# Start and enable services
echo "🚀 Starting services..."
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl enable nginx
sudo systemctl start nginx
# sudo systemctl enable tomcat10  # Commented out - Tomcat not installed
# sudo systemctl start tomcat10   # Commented out - Tomcat not installed

# Wait a moment for services to start
sleep 3

# Check service status
echo "📊 Service Status:"
sudo systemctl is-active apache2 && echo "✅ Apache is running" || echo "❌ Apache failed to start"
sudo systemctl is-active nginx && echo "✅ Nginx is running" || echo "❌ Nginx failed to start"
# sudo systemctl is-active tomcat10 && echo "✅ Tomcat is running" || echo "❌ Tomcat failed to start"  # Commented out
sudo systemctl is-active ssh && echo "✅ SSH is running" || echo "❌ SSH failed to start"

# Display connection information
echo ""
echo "🌐 Server URLs:"
echo "Apache HTTP:  http://localhost:8080"
echo "Apache HTTPS: https://localhost:8443"
echo "Nginx HTTP:   http://localhost:8081"
echo "Nginx HTTPS:  https://localhost:8444"
# echo "Tomcat HTTP:  http://localhost:8082"   # Commented out - Tomcat not installed
# echo "Tomcat HTTPS: https://localhost:8445"  # Commented out - Tomcat not installed
echo ""
echo "🔐 SSH Connection:"
echo "ssh $(whoami)@localhost"
echo ""
echo "📁 Certificate locations:"
echo "Apache:  /etc/ssl/webservers/apache/"
echo "Nginx:   /etc/ssl/webservers/nginx/"
# echo "Tomcat:  /etc/ssl/webservers/tomcat/"  # Commented out - Tomcat not installed
echo ""
echo "✨ Installation complete! Apache and Nginx services are running natively on the OS."
