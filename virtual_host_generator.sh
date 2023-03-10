#!/bin/bash

read -p "Enter the domain name: " domain_name

sudo mkdir /var/www/$domain_name
sudo chown -R $USER:$USER /var/www/$domain_name
sudo chmod -R 755 /var/www/$domain_name
sudo nano /var/www/$domain_name/index.html
sudo nano /etc/apache2/sites-available/$domain_name.conf

echo "<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName $domain_name
    ServerAlias www.$domain_name
    DocumentRoot /var/www/$domain_name
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" | sudo tee /etc/apache2/sites-available/$domain_name.conf > /dev/null

sudo a2ensite $domain_name.conf
sudo apache2ctl configtest
sudo systemctl restart apache2

read -p "Do you want to set up a reverse proxy? (y/n): " proxy_answer

if [[ "$proxy_answer" == "y" ]]; then
    
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
fi

read -p "Do you want to set up SSL? (y/n): " ssl_answer

if [[ "$ssl_answer" == "y" ]]; then
    sudo certbot --apache -d $domain_name
fi
