#!/bin/bash

# Function to install Nginx
install_nginx() {
    echo "Installing Nginx..."
    sudo apt-get update
    sudo apt-get install -y nginx
    echo "Nginx installed."
}

# Function to configure Nginx for load balancing
configure_nginx() {
    echo "Configuring Nginx for load balancing..."

    # Backup the original configuration file
    sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup

    # Start load balance configuration
    echo "upstream backend {" > /etc/nginx/conf.d/load_balance.conf

    # Adding server details to the configuration
    for server in "${SERVERS[@]}"; do
        echo "    server $server;" >> /etc/nginx/conf.d/load_balance.conf
    done

    # Completing the configuration
    cat <<EOF >> /etc/nginx/conf.d/load_balance.conf
}

server {
    listen 80;

    location / {
        proxy_pass http://backend;
    }
}
EOF

    # Restart Nginx to apply the new configuration
    sudo systemctl restart nginx
    echo "Nginx configured for load balancing."
}

# Function to test load balancing
test_load_balance() {
    echo "Testing load balancing..."
    curl -I http://localhost
}

# Main script starts here
echo "Load Balancer Setup for Apache Servers"

# Prompt for Apache server details
SERVERS=()
while true; do
    read -p "Enter Apache server IP and port (format: ip:port), or 'done' to finish: " input
    if [[ "$input" == "done" ]]; then
        break
    fi
    SERVERS+=("$input")
done

# Install and configure Nginx
install_nginx
configure_nginx

# Verify and test load balancing
test_load_balance
echo "Load balancing setup complete. Test above should show Nginx serving the page."
