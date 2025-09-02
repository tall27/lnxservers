# Native Web Servers Setup

This repository provides native OS-level installation of Apache, Nginx, and Tomcat web servers with SSL certificates and SSH access, optimized for GitHub Codespaces.

## GitHub Codespaces Quick Start

When you launch a new GitHub Codespace, the environment will be automatically configured:

1. **Automatic Setup** (recommended):
   ```bash
   export AUTO_INSTALL=true
   .devcontainer/setup.sh
   ```

2. **Manual Setup**:
   ```bash
   sudo ./install-native-servers.sh  # Install servers
   ./configure-ssh.sh               # Configure SSH  
   ./manage-services.sh status      # Check status
   ```

3. **Ports are automatically forwarded**:
   - Apache: 8080 (HTTP), 8443 (HTTPS)
   - Nginx: 8081 (HTTP), 8444 (HTTPS)
   - Tomcat: 8082 (HTTP), 8445 (HTTPS)

## Quick Start

1. **Install the servers natively:**
   ```bash
   chmod +x install-native-servers.sh
   sudo ./install-native-servers.sh
   ```

2. **Configure SSH access:**
   ```bash
   chmod +x configure-ssh.sh
   ./configure-ssh.sh
   ```

3. **Manage services:**
   ```bash
   chmod +x manage-services.sh
   ./manage-services.sh status
   ```

## Server Information

### Ports
- **Apache**: 8080 (HTTP), 8443 (HTTPS)
- **Nginx**: 8081 (HTTP), 8444 (HTTPS)
- **Tomcat**: 8082 (HTTP), 8445 (HTTPS)
- **SSH**: 22

### URLs
- Apache HTTP: http://localhost:8080
- Apache HTTPS: https://localhost:8443
- Nginx HTTP: http://localhost:8081
- Nginx HTTPS: https://localhost:8444
- Tomcat HTTP: http://localhost:8082
- Tomcat HTTPS: https://localhost:8445

## SSL Certificates

Self-signed certificates are generated for each server:
- **Apache**: `/etc/ssl/webservers/apache/`
- **Nginx**: `/etc/ssl/webservers/nginx/`
- **Tomcat**: `/etc/ssl/webservers/tomcat/`

## SSH Access

### Direct Connection
```bash
ssh $(whoami)@localhost
```

### Predefined SSH Configurations
After running `configure-ssh.sh`, you can use these shortcuts:

```bash
ssh apache-server   # Connect with Apache port forwarding
ssh nginx-server    # Connect with Nginx port forwarding
ssh tomcat-server   # Connect with Tomcat port forwarding
ssh all-servers     # Connect with all ports forwarded
```

## Service Management

Use the `manage-services.sh` script:

```bash
# Start all services
./manage-services.sh start

# Stop all services
./manage-services.sh stop

# Restart all services
./manage-services.sh restart

# Check service status
./manage-services.sh status

# View recent logs
./manage-services.sh logs

# Clean up old Docker setup (run once after migration)
./manage-services.sh cleanup
```

## File Locations

### Web Content
- Apache: `/var/www/apache/`
- Nginx: `/var/www/nginx/`
- Tomcat: `/var/lib/tomcat10/webapps/ROOT/`

### Configuration Files
- Apache: `/etc/apache2/`
- Nginx: `/etc/nginx/`
- Tomcat: `/etc/tomcat10/`

### Log Files
- Apache: `/var/log/apache2/`
- Nginx: `/var/log/nginx/`
- Tomcat: `/var/log/tomcat10/`

## Security Notes

- Self-signed certificates will show browser warnings - this is expected
- SSH is configured with key-based authentication
- Firewall (UFW) is enabled with only necessary ports open
- Services run with dedicated system users for better security

## Troubleshooting

### Check Service Status
```bash
sudo systemctl status apache2
sudo systemctl status nginx
sudo systemctl status tomcat10
sudo systemctl status ssh
```

### View Logs
```bash
sudo journalctl -u apache2 -f
sudo journalctl -u nginx -f
sudo journalctl -u tomcat10 -f
```

### Test Connectivity
```bash
curl -k http://localhost:8080  # Apache HTTP
curl -k https://localhost:8443 # Apache HTTPS
curl -k http://localhost:8081  # Nginx HTTP
curl -k https://localhost:8444 # Nginx HTTPS
curl -k http://localhost:8082  # Tomcat HTTP
curl -k https://localhost:8445 # Tomcat HTTPS
```

### Regenerate Certificates
If you need to regenerate certificates, you can extract the certificate generation commands from `install-native-servers.sh` and run them individually.

## Migration from Docker

If you're migrating from the previous Docker setup:

1. Run `./manage-services.sh cleanup` to remove Docker containers and images
2. Remove the `.devcontainer` directory
3. Follow the Quick Start guide above

The native installation provides better performance and direct OS integration compared to the containerized approach.
