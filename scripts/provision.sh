#!/usr/bin/env bash
set -euo pipefail

# Detect Codespaces URL pattern
CODESPACE_NAME=${CODESPACE_NAME:-""}
FWD_DOMAIN=${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-"app.github.dev"}

apache_port=8080
nginx_port=8081
tomcat_port=8082

sudo mkdir -p /tmp/apache2

# Configure Apache -> 8080
if grep -q "Listen 80" /etc/apache2/ports.conf; then
  sudo sed -i 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf || true
fi
if [ -f /etc/apache2/sites-available/000-default.conf ]; then
  sudo sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-available/000-default.conf || true
fi

# Configure Nginx -> 8081
if [ -f /etc/nginx/sites-available/default ]; then
  sudo sed -i 's/listen 80 default_server;/listen 8081 default_server;/' /etc/nginx/sites-available/default || true
  sudo sed -i 's/listen \[::\]:80 default_server;/listen [::]:8081 default_server;/' /etc/nginx/sites-available/default || true
  # Serve a distinct page
  sudo sed -i 's#root /var/www/html;#root /var/www/nginx/html;#' /etc/nginx/sites-available/default || true
fi

# Configure Tomcat -> 8082
if [ -f /etc/tomcat9/server.xml ]; then
  sudo sed -i 's/\(Connector port=\)"8080"/\1"8082"/' /etc/tomcat9/server.xml || true
fi

# Start/restart services
sudo service apache2 restart || sudo apache2ctl -k restart || true
sudo service nginx restart || true
sudo service tomcat9 restart || true

# Build URLs
apache_url="https://${CODESPACE_NAME}-${apache_port}.${FWD_DOMAIN}/"
nginx_url="https://${CODESPACE_NAME}-${nginx_port}.${FWD_DOMAIN}/"
tomcat_url="https://${CODESPACE_NAME}-${tomcat_port}.${FWD_DOMAIN}/"

# Show info
cat <<EOF
✅ Provisioned web servers:
- Apache: ${apache_url}
- Nginx:  ${nginx_url}
- Tomcat: ${tomcat_url}

If links show 404 initially, wait a few seconds for ports to become active.
EOF

# Try email if env vars present
if [[ -n "${SENDGRID_API_KEY:-}" && -n "${EMAIL_TO:-}" && -n "${EMAIL_FROM:-}" ]]; then
  /workspaces/scripts/send-ready-email.sh \
    "${EMAIL_TO}" "${EMAIL_FROM}" \
    "${apache_url}" "${nginx_url}" "${tomcat_url}" || echo "(Email attempt failed)"
else
  echo "ℹ️ Email not sent (set SENDGRID_API_KEY, EMAIL_TO, EMAIL_FROM in devcontainer.json)."
fi
