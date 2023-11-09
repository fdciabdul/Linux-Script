#!/bin/bash

###########################################################################
# Script Name: setup_postgresql.sh
# Author: fdciabdul
# Date: 07/11/2024
###########################################################################


# Function to install PostgreSQL
install_postgresql() {
    echo "Installing PostgreSQL..."
    sudo apt update
    sudo apt install -y postgresql postgresql-contrib
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
}

# Function to create a new PostgreSQL database
create_database() {
    read -p "Enter the name of the new database: " dbname
    sudo -u postgres psql -c "CREATE DATABASE $dbname;"
}

# Function to list all PostgreSQL users for a database
list_users() {
    read -p "Enter the name of the database to list users for: " dbname
    sudo -u postgres psql -d $dbname -c "\du"
}

# Function to create a new PostgreSQL user
create_user() {
    read -p "Enter the name of the new user: " username
    sudo -u postgres psql -c "CREATE USER $username WITH PASSWORD 'password';"
}

# Function to grant permission to a user on a database
grant_permission() {
    read -p "Enter the name of the database: " dbname
    read -p "Enter the name of the user: " username
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $dbname TO $username;"
}

# Starting point of the script
echo "PostgreSQL Installation & Setup Script"

# Install PostgreSQL
install_postgresql

# Ask if the user wants to create a new database
read -p "Do you want to create a new database? [y/n]: " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    create_database
fi

# Ask if the user wants to list users of a database
read -p "Do you want to list users of a specific database? [y/n]: " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    list_users
fi

# Ask if the user wants to create a new PostgreSQL user
read -p "Do you want to create a new PostgreSQL user? [y/n]: " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    create_user
fi

# Ask if the user wants to grant permissions to a user
read -p "Do you want to grant permissions to a user on a database? [y/n]: " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    grant_permission
fi

echo "PostgreSQL setup is complete."
