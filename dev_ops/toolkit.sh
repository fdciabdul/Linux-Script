#!/bin/bash

# devops_toolkit.sh
# A useful script for DevOps tasks like checking server status, syncing files, etc.

SERVER_LIST=("server1.example.com" "server2.example.com")
REMOTE_SYNC_DIR="/path/to/remote/sync/dir"
LOCAL_SYNC_DIR="/path/to/local/sync/dir"

function check_server_status {
  echo "Checking server status..."
  for server in "${SERVER_LIST[@]}"; do
    echo -n "Checking ${server}: "
    ping -c 1 $server &> /dev/null
    if [ $? -eq 0 ]; then
      echo "Online"
    else
      echo "Offline"
    fi
  done
}

function sync_files {
  echo "Syncing files with remote server..."
  rsync -avz --progress $LOCAL_SYNC_DIR user@remote-server:$REMOTE_SYNC_DIR
}

function check_disk_usage {
  echo "Checking disk usage..."
  df -h
}

function main_menu {
  echo "DevOps Toolkit"
  echo "1) Check Server Status"
  echo "2) Sync Files with Remote"
  echo "3) Check Disk Usage"
  echo "4) Exit"
  read -p "Please choose an option: " choice

  case $choice in
    1)
      check_server_status
      ;;
    2)
      sync_files
      ;;
    3)
      check_disk_usage
      ;;
    4)
      exit 0
      ;;
    *)
      echo "Invalid option, please try again."
      ;;
  esac
}

while true; do
  main_menu
done
