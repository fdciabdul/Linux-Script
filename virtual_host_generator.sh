#!/bin/bash

read -p "Enter the domain name: " domain_name

sudo mkdir -p /var/www/$domain_name && sudo chown -R $USER:$USER /var/www/$domain_name && sudo chmod -R 755 /var/www/$domain_name

printf "<VirtualHost *:80>\n\tServerAdmin webmaster@localhost\n\tServerName $domain_name\n\tServerAlias www.$domain_name\n\tDocumentRoot /var/www/$domain_name\n\tErrorLog \${APACHE_LOG_DIR}/error.log\n\tCustomLog \${APACHE_LOG_DIR}/access.log combined\n</VirtualHost>" | sudo tee /etc/apache2/sites-available/$domain_name.conf > /dev/null

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
        printf "<IfModule mod_ssl.c>\n\t<VirtualHost *:443>\n\t\tServerAdmin webmaster@localhost\n\t\tServerName $domain_name\n\t\tServerAlias www.$domain_name\n\t\tDocumentRoot /var/www/$domain_name\n\t\tErrorLog \${APACHE_LOG_DIR}/error.log\n\t\tCustomLog \${APACHE_LOG_DIR}/access.log combined\n\t\t<Directory /var/www/$domain_name/>\n\t\t\tOptions Indexes FollowSymLinks MultiViews\n\t\t\tAllowOverride All\n\t\t\tOrder allow,deny\n\t\t\tallow from all\n\t\t</Directory>\n\t\tInclude /etc/letsencrypt/options-ssl-apache.conf\n\t\tSSLCertificateFile /etc/letsencrypt/live/$domain_name/fullchain.pem\n\t\tSSLCertificateKeyFile /etc/letsencrypt/live/$domain_name/privkey.pem\n\t</VirtualHost>\n</IfModule>" | sudo tee -a /etc/apache2/sites-available/$domain_name-le-ssl.conf > /dev/null

        sudo a2ensite $domain_name-le-ssl.conf
        sudo apache2ctl configtest
        sudo systemctl restart apache2
        ;;
esac
