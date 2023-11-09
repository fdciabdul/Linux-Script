#!/bin/bash

echo "Select the database to install:"
echo "1. MySQL"
echo "2. PostgreSQL"
echo "3. MariaDB"
echo "4. MongoDB"
echo "5. SQLite"

read -p "Enter your choice (1-5): " DB_CHOICE

case $DB_CHOICE in
  1)
    echo "Installing MySQL..."
    sudo apt update
    sudo apt install mysql-server
    ;;
  2)
    echo "Installing PostgreSQL..."
    sudo apt update
    sudo apt install postgresql postgresql-contrib
    ;;
  3)
    echo "Installing MariaDB..."
    sudo apt update
    sudo apt install mariadb-server
    ;;
  4)
    echo "Installing MongoDB..."
    sudo apt update
    sudo apt install mongodb
    ;;
  5)
    echo "Installing SQLite..."
    sudo apt update
    sudo apt install sqlite3
    ;;
  *)
    echo "Invalid option selected"
    exit 1
    ;;
esac

read -p "Do you wish to create a new database? (y/n) " CREATE_DB

if [ "$CREATE_DB" = "y" ]; then
  read -p "Enter the database name: " DB_NAME
  read -p "Enter the database username: " DB_USER
  read -s -p "Enter the database password: " DB_PASS
  echo ""

  case $DB_CHOICE in
    1)
      # MySQL/MariaDB
      sudo mysql -e "CREATE DATABASE ${DB_NAME};"
      sudo mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
      sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
      sudo mysql -e "FLUSH PRIVILEGES;"
      ;;
    2)
      # PostgreSQL
      sudo -u postgres psql -c "CREATE DATABASE ${DB_NAME};"
      sudo -u postgres psql -c "CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASS}';"
      sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};"
      ;;
    3)
      # MariaDB, same as MySQL
      sudo mysql -e "CREATE DATABASE ${DB_NAME};"
      sudo mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
      sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
      sudo mysql -e "FLUSH PRIVILEGES;"
      ;;
    4)
      # MongoDB
      mongo ${DB_NAME} --eval "db.createUser({user: '${DB_USER}', pwd: '${DB_PASS}', roles: [{role: 'readWrite', db: '${DB_NAME}'}]});"
      ;;
    5)
      # SQLite does not have user management
      sqlite3 ${DB_NAME}.db ".quit"
      echo "SQLite database '${DB_NAME}.db' created."
      ;;
  esac
fi

echo "Database installation and setup completed."
