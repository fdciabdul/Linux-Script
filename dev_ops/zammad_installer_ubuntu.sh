#!/usr/bin/env bash

# Zammad installer
#
# Updated to use Certbot for SSL certificate generation for helpdesk.imtaqin.id

# Variables
zammad_fqdn="helpdesk.imtaqin.id"             # Define the domain for Zammad
ssl_crt=/etc/letsencrypt/live/${zammad_fqdn}/fullchain.pem
ssl_key=/etc/letsencrypt/live/${zammad_fqdn}/privkey.pem
ssl_dhp=/etc/nginx/ssl/dhparam.pem
dns1=8.8.8.8    # DNS Server 1
dns2=8.8.4.4    # DNS Server 2

# Output everything to a log file
zammadLog=./zammad_install-$(date +"%Y%m%d-%T").log
exec > >(tee -i $zammadLog)
exec 2>&1

# Check if the script is being run as root
if [ $UID -ne 0 ]; then
  echo -e "\n ERROR - you must be root to run this installer.\n"
  exit 1
fi

function checkStatus() {
    if [ $? -eq 0 ]; then
        echo -e "[  OK!  ]\n"
    else 
        echo -e "[ ERROR ]\n"
        exit 1
    fi
}

# Install prerequisites
echo -e "== Installing prerequisites..."
apt-get update -y
apt-get install apt-transport-https wget firewalld nginx certbot python3-certbot-nginx -y

# Remove default nginx configuration for Zammad
echo -e "== Removing default nginx configuration (no SSL support)"
rm -f /etc/nginx/sites-enabled/zammad.conf
checkStatus

# Installing Zammad
echo -e "== Installing Zammad..."
# Add Zammad repo
ubuntu_version=$(grep DISTRIB_RELEASE /etc/lsb-release | awk -F= '{ print $2 }')
wget -qO - https://dl.packager.io/srv/zammad/zammad/key | apt-key add -
wget -O /etc/apt/sources.list.d/zammad.list https://dl.packager.io/srv/zammad/zammad/stable/installer/ubuntu/${ubuntu_version}.repo
apt-get update -y
apt-get install zammad -y

# Fix file permissions for Zammad's public directory
echo -e "== Fixing file permissions for Zammad's public directory"
find /opt/zammad/public -type f -exec chmod 644 {} \;
checkStatus

# Certbot for SSL
echo -e "== Generating SSL certificate with Certbot for $zammad_fqdn..."
certbot --nginx -d $zammad_fqdn
checkStatus

# Generate DH parameters
echo -e "== Generating dhparam.pem file..."
mkdir -p /etc/nginx/ssl
openssl dhparam -out $ssl_dhp 4096

# Nginx configuration for Zammad with SSL
echo -e "== Creating Nginx configuration with SSL for Zammad"
cat > /etc/nginx/conf.d/zammad_ssl.conf <<EOF
upstream zammad-railsserver {
  server 127.0.0.1:3000;
}

upstream zammad-websocket {
  server 127.0.0.1:6042;
}

server {
  listen 80;
  server_name $zammad_fqdn;

  # Redirect all HTTP requests to HTTPS
  return 301 https://\$server_name\$request_uri;
}

server {
  listen 443 ssl http2;
  server_name $zammad_fqdn;

  ssl_certificate $ssl_crt;
  ssl_certificate_key $ssl_key;
  ssl_dhparam $ssl_dhp;

  ssl_protocols TLSv1.2;
  ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 180m;

  add_header Strict-Transport-Security "max-age=31536000" always;

  access_log /var/log/nginx/zammad.access.log;
  error_log /var/log/nginx/zammad.error.log;

  root /opt/zammad/public;
  client_max_body_size 50M;

  location ~ ^/(assets/|robots.txt|humans.txt|favicon.ico) {
    expires max;
  }

  location /ws {
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_set_header CLIENT_IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_read_timeout 86400;
    proxy_pass http://zammad-websocket;
  }

  location / {
    proxy_set_header Host \$http_host;
    proxy_set_header CLIENT_IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_read_timeout 180;
    proxy_pass http://zammad-railsserver;

    gzip on;
    gzip_types text/plain text/xml text/css image/svg+xml application/javascript application/x-javascript application/json application/xml;
    gzip_proxied any;
  }
}
EOF

checkStatus

# Set up firewall
echo -e "== Setting up firewall rules"
firewall-cmd -q --zone=public --add-service=http --permanent
firewall-cmd -q --zone=public --add-service=https --permanent
firewall-cmd -q --reload
checkStatus

# Restart services
echo -e "== Restarting services..."
systemctl restart elasticsearch
systemctl restart zammad
systemctl restart nginx
checkStatus

echo -e "\n\n== Zammad is ready at: https://$zammad_fqdn \n"
