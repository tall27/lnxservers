# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Automatic Operation (Zero Manual Intervention)
- **Auto-install everything**: Services auto-start on codespace creation via `AUTO_INSTALL=true` environment variable
- **Health checks**: `/.devcontainer/ensure-services.sh` runs automatically on every codespace start
- **All services enabled**: SSH, Apache, Nginx auto-start and recover automatically

### Manual Service Management (If Needed)
- **Start all services**: `./manage-services.sh start`
- **Stop all services**: `./manage-services.sh stop`
- **Restart all services**: `./manage-services.sh restart`
- **Check service status**: `./manage-services.sh status`
- **View recent logs**: `./manage-services.sh logs`
- **Clean up old Docker setup**: `./manage-services.sh cleanup`

### Manual Installation (For Troubleshooting)
- **Install servers natively**: `sudo ./install-native-servers.sh`
- **Configure SSH access**: `./configure-ssh.sh`

### Testing Connectivity
- **Test Apache**: `curl -k http://localhost:8080` (HTTP), `curl -k https://localhost:8443` (HTTPS)
- **Test Nginx**: `curl -k http://localhost:8081` (HTTP), `curl -k https://localhost:8444` (HTTPS)
- **Test SSH**: `ssh $(whoami)@localhost`

### System Commands
- **Check individual service status**: `sudo systemctl status apache2|nginx|ssh`
- **View service logs**: `sudo journalctl -u apache2|nginx -f`

## Architecture

This is a native web server setup repository that installs and configures Apache, Nginx, and SSH services directly on Ubuntu 22.04, optimized for GitHub Codespaces.

### Key Components
- **install-native-servers.sh**: Main installation script that sets up Apache, Nginx, SSL certificates, and firewall rules
- **manage-services.sh**: Service management utility for starting/stopping/monitoring all services
- **configure-ssh.sh**: SSH key generation and configuration for secure access
- **.devcontainer/setup.sh**: Automated setup script called by GitHub Codespaces

### Server Configuration
- **Apache**: Runs on ports 8080 (HTTP) and 8443 (HTTPS)
- **Nginx**: Runs on ports 8081 (HTTP) and 8444 (HTTPS)  
- **SSH**: Runs on port 22 with key-based authentication
- **Tomcat**: Currently commented out but supported on ports 8082/8445

### File Locations
- **Web content**: `/var/www/apache/`, `/var/www/nginx/`
- **SSL certificates**: `/etc/ssl/webservers/apache/`, `/etc/ssl/webservers/nginx/`
- **Configuration files**: `/etc/apache2/`, `/etc/nginx/`
- **Log files**: `/var/log/apache2/`, `/var/log/nginx/`

### Security Features
- Self-signed SSL certificates for HTTPS
- UFW firewall with only necessary ports open
- SSH key-based authentication
- Services run with dedicated system users

## GitHub Codespaces Integration

The repository is configured for **maximum robustness** with zero manual intervention:
- **Automatic installation**: `postCreateCommand` installs all services on codespace creation
- **Automatic health checks**: `postStartCommand` ensures services are healthy on every start
- **Public external access**: SSH (port 22), Apache (8080/8443), Nginx (8081/8444) all publicly accessible
- **Auto-recovery**: Health checks restart failed services automatically
- **Service persistence**: All services enabled for automatic startup via systemctl
- **Port auto-forwarding**: `onAutoForward: "openPreview"` immediately exposes services