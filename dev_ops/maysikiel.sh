#!/bin/bash

MYSQL_ROOT_PASSWORD='PASSWOT'
MYSQL_MASTER_USER='master'
MYSQL_MASTER_PASSWORD='PASSWOT'

install_mysql() {
    sudo apt update
    sudo apt install -y mysql-server
    if [ $? -ne 0 ]; then
        echo "MySQL installation failed"
        exit 1
    fi
}

set_root_password() {
    sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';"
    if [ $? -ne 0 ]; then
        echo "Failed to set root password"
        exit 1
    fi
    sudo mysql -e "FLUSH PRIVILEGES;"
}

allow_remote_access() {
    sudo sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
    if [ $? -ne 0 ]; then
        echo "Failed to configure MySQL to allow remote access"
        exit 1
    fi
}

create_master_user() {
    sudo mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE USER '$MYSQL_MASTER_USER'@'%' IDENTIFIED WITH mysql_native_password BY '$MYSQL_MASTER_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_MASTER_USER'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT
EOF

    if [ $? -ne 0 ]; then
        echo "Failed to create user or set privileges"
        existing_user=$(sudo mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SELECT User, Host FROM mysql.user WHERE User='$MYSQL_MASTER_USER' AND Host='%';")
        if [ -n "$existing_user" ]; then
            echo "User already exists. Altering the existing user."
            sudo mysql -u root -p$MYSQL_ROOT_PASSWORD -e "ALTER USER '$MYSQL_MASTER_USER'@'%' IDENTIFIED WITH mysql_native_password BY '$MYSQL_MASTER_PASSWORD';"
            sudo mysql -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_MASTER_USER'@'%' WITH GRANT OPTION;"
            sudo mysql -u root -p$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"
        else
            echo "Unexpected error in user creation. Exiting."
            exit 1
        fi
    fi
}

restart_mysql() {
    sudo systemctl restart mysql
    if [ $? -ne 0 ]; then
        echo "Failed to restart MySQL"
        exit 1
    fi
}

allow_firewall_access() {
    sudo ufw allow 3306/tcp
    if [ $? -ne 0 ]; then
        echo "Failed to allow MySQL port 3306 in firewall"
        exit 1
    fi
}

install_mysql
set_root_password
allow_remote_access
create_master_user
restart_mysql
allow_firewall_access

echo "MySQL installation and configuration completed. Remote access is enabled for the 'master' user."
