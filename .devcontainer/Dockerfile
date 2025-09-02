# Ubuntu base with sudo
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       apache2 \
       nginx \
       tomcat9 \
       ca-certificates \
       curl \
       jq \
    && rm -rf /var/lib/apt/lists/*

# Make sure services don't try to use systemd
ENV APACHE_RUN_USER=vscode \
    APACHE_RUN_GROUP=vscode \
    APACHE_PID_FILE=/tmp/apache2.pid \
    APACHE_RUN_DIR=/tmp/apache2 \
    APACHE_LOCK_DIR=/tmp/apache2 \
    APACHE_LOG_DIR=/var/log/apache2

# Simple landing pages so you can tell which server you hit
RUN echo '<h1>Apache on 8080</h1>' | tee /var/www/html/index.html \
 && mkdir -p /var/www/nginx/html \
 && echo '<h1>Nginx on 8081</h1>' | tee /var/www/nginx/html/index.html \
 && mkdir -p /var/lib/tomcat9/webapps/ROOT \
 && echo '<h1>Tomcat on 8082</h1>' | tee /var/lib/tomcat9/webapps/ROOT/index.html

# Copy scripts
COPY scripts /workspaces/scripts
RUN chmod +x /workspaces/scripts/*.sh

# Default workdir
WORKDIR /workspaces
