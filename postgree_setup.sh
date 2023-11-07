#!/bin/bash

# Update package list
sudo apt update

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Start the PostgreSQL service
sudo systemctl start postgresql

# Enable PostgreSQL to start on boot
sudo systemctl enable postgresql

# Prompt to create a new database
read -p "Do you want to create a new database? (y/n): " create_db
if [[ "$create_db" == "y" ]]; then
  read -p "Enter database name: " dbname
  sudo -u postgres createdb "$dbname"
  echo "Database $dbname created."
fi

# List PostgreSQL users
echo "PostgreSQL users:"
sudo -u postgres psql -c '\du'

# Check if users exist
user_count=$(sudo -u postgres psql -tAc "SELECT COUNT(*) FROM pg_roles WHERE rolname NOT IN ('pg_signal_backend', 'postgres')")
if [[ $user_count -eq 0 ]]; then
  # No users exist, prompt to create a new one
  read -p "No users exist. Do you want to create a new one? (y/n): " create_user
  if [[ "$create_user" == "y" ]]; then
    read -p "Enter new username: " username
    read -s -p "Enter password for new user: " password
    echo
    sudo -u postgres psql -c "CREATE USER $username WITH PASSWORD '$password';"
    echo "User $username created."
  fi
else
  # Prompt for permission assignment
  read -p "Do you want to assign permissions to a user for the database? (y/n): " assign_perm
  if [[ "$assign_perm" == "y" ]]; then
    read -p "Enter username: " username
    read -p "Enter database name: " dbname
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $dbname TO $username;"
    echo "Permissions assigned to user $username for database $dbname."
  fi
fi
