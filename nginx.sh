#!/bin/bash

# --- 1. Define Variables ---
# Use the static IPs defined in your Vagrantfile
NGINX_HOST="192.168.56.11"
TOMCAT_IP="192.168.56.12"

# --- 2. Install Nginx and Tools ---
apt update
apt install nginx -y
apt install openssl -y # Need openssl to generate self-signed certs

# --- 3. SSL Setup (Self-Signed Certificates) ---
# NOTE: For production, you would copy real certificates here.
# For Vagrant/testing, we generate self-signed certificates.

mkdir -p /etc/nginx/ssl/
cd /etc/nginx/ssl/

# Generate a self-signed certificate and key (valid for 365 days)
# -subj ensures the process is non-interactive
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout privkey.pem \
    -out fullchain.pem \
    -subj "/C=US/ST=NA/L=NA/O=VProfile/CN=$NGINX_HOST"

# Set permissions
chmod 600 privkey.pem fullchain.pem

# --- 4. Create Nginx Configuration File ---
# This configuration only contains the server blocks, which is the correct practice.
cat <<EOT > /etc/nginx/sites-available/vproapp
server {
    # HTTP server block: Redirects all HTTP traffic to HTTPS
    listen 80;
    listen [::]:80;
    server_name ${NGINX_HOST};  
    return 301 https://\$host\$request_uri;
}

server {
    # HTTPS server block
    listen 443 ssl default_server;
    listen [::]:443 ssl default_server;
    server_name ${NGINX_HOST};  

    # SSL Paths reference the files created above
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;

    # Basic security settings (optional but recommended)
    ssl_protocols TLSv1.2 TLSv1.3;

    location / {
        # Reverse Proxy to the Tomcat Application server
        proxy_pass http://${TOMCAT_IP}:8080;  
        
        # Pass essential headers to the backend application
        proxy_set_header Host \$host;  
        proxy_set_header X-Real-IP \$remote_addr;  
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;  
        proxy_set_header X-Forwarded-Proto \$scheme;  
    }
}
EOT

# --- 5. Enable Configuration ---
# Remove the default site
rm -f /etc/nginx/sites-enabled/default

# Create the symbolic link to enable the new config
ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp

# --- 6. Start and Enable Service ---
# Test the configuration file before restarting
nginx -t

# If the test passes, restart the service
systemctl restart nginx
systemctl enable nginx