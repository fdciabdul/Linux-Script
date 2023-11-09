#!/bin/bash

read -p "Enter the domain name: " domain_name

sudo mkdir -p /var/www/$domain_name && sudo chown -R $USER:$USER /var/www/$domain_name && sudo chmod -R 755 /var/www/$domain_name

sudo bash -c 'cat << EOF > /etc/apache2/sites-available/$domain.conf
<VirtualHost *:80>
    ServerAdmin admin@$domain
    ServerName $domain_name
    ServerAlias www.$domain_name
    DocumentRoot /var/www/$domain_name
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF'

sudo a2ensite $domain_name.conf
sudo apache2ctl configtest
sudo systemctl restart apache2

read -p "Do you want to set up a reverse proxy? (y/n): " proxy_answer

case "$proxy_answer" in
    y|Y )
        read -p "Enter the port number you want to reverse proxy: " port_number
        # update virtual host configuration file with reverse proxy settings
        echo "<VirtualHost *:80>
        ServerName $domain_name
        ServerAlias www.$domain_name

        ProxyRequests Off
        ProxyPreserveHost On
        ProxyVia Full

        <Proxy *>
            Require all granted
        </Proxy>

        ProxyPass / http://127.0.0.1:$port_number/
        ProxyPassReverse / http://127.0.0.1:$port_number/
        </VirtualHost>" | sudo tee -a /etc/apache2/sites-available/$domain_name.conf > /dev/null

        sudo a2ensite $domain_name.conf
        sudo apache2ctl configtest
        sudo systemctl restart apache2
        ;;
esac

read -p "Do you want to set up SSL? (y/n): " ssl_answer

case "$ssl_answer" in
    y|Y )
        # Install certbot and obtain SSL certificate
        sudo apt-get update
        sudo apt-get install certbot python3-certbot-apache -y
        sudo certbot --apache -d $domain_name

        # Configure HTTPS virtual host
      sudo bash -c '<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerAdmin webmaster@localhost
    ServerName $domain_name
    ServerAlias www.$domain_name
    DocumentRoot /var/www/$domain_name
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
  ProxyRequests Off
    ProxyPreserveHost On
    ProxyVia Full

    <Proxy *>
        Require all granted
    </Proxy>

    ProxyPass / http://localhost:3000/
    ProxyPassReverse / http://localhost:3000/
RewriteEngine on
#RewriteCond %{SERVER_NAME} =www.app.imtaqin.id [OR]
#RewriteCond %{SERVER_NAME} =app.imtaqin.id
#RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]

SSLCertificateFile /etc/letsencrypt/live/app.imtaqin.id/fullchain.pem
SSLCertificateKeyFile /etc/letsencrypt/live/app.imtaqin.id/privkey.pem
Include /etc/letsencrypt/options-ssl-apache.conf
</VirtualHost>
</IfModule>

'
        sudo a2ensite $domain_name-le-ssl.conf
        sudo apache2ctl configtest
        sudo systemctl restart apache2
        ;;
esac
