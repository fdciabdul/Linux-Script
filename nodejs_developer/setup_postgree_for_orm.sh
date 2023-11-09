#!/bin/bash

# Function to install PostgreSQL
install_postgresql() {
    echo "Installing PostgreSQL..."
    sudo apt update
    sudo apt install -y postgresql postgresql-contrib
}

# Function to create a database, a user, and grant permissions
create_database_and_user() {
    # Prompt for database information
    read -p "Enter the database name: " dbname
    read -p "Enter the database user: " dbuser
    read -s -p "Enter the database password: " dbpass
    echo

    # Switch to the postgres user to create the database and user
    sudo -u postgres psql <<EOF
    CREATE DATABASE $dbname;
    CREATE USER $dbuser WITH ENCRYPTED PASSWORD '$dbpass';
    GRANT ALL PRIVILEGES ON DATABASE $dbname TO $dbuser;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $dbuser;
EOF

    echo "Database and user created with privileges granted."
}

# Function to adjust the PostgreSQL configuration to allow local connections
configure_postgresql() {
    echo "Configuring PostgreSQL to allow local connections..."
    # Replace "peer" with "md5" in pg_hba.conf to allow password authentication
    sudo sed -i "s/local   all             all                                     peer/local   all             all                                     md5/" /etc/postgresql/*/main/pg_hba.conf
    sudo systemctl restart postgresql
    echo "PostgreSQL configured."
}

# Main execution flow
install_postgresql
configure_postgresql
create_database_and_user
