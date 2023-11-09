# Linux Scripts

This repository contains a collection of bash scripts to assist with setting up development environments, servers, and other operations related to DevOps tasks.

## Folder Structure

The repository is organized into the following directories:

- `dev_ops`: Scripts related to DevOps tasks, including Docker installation and PostgreSQL setup.
- `nodejs_developer`: A collection of scripts for Node.js developers, such as installing Node.js, MongoDB, and setting up Google Chrome.
- `programmer`: General scripts for programmers, such as database installation and programming language setup.
- `server`: Scripts for setting up server-related tasks, including email configuration and WordPress site installation.

## Scripts Overview

### DevOps Scripts

- `docker_installer.sh`: Installs Docker on the system.
- `postgree_setup.sh`: Sets up PostgreSQL database server.
- `toolkit.sh`: Miscellaneous tools helpful for DevOps practices.

[DevOps Scripts](./dev_ops/)

### Node.js Developer Scripts

- `google_chrome.sh`: Installs Google Chrome browser.
- `install_docker.sh`: Installs the latest version of Docker.
- `install_latest_node.sh`: Installs the latest version of Node.js.
- `mongodb.sh`: Installs MongoDB NoSQL database.
- `prune.sh`: A script to clean up the system, such as removing unused Docker containers.
- `setup_nodejs_npm.sh`: Sets up Node.js environment along with npm.
- `setup_postgree_for_orm.sh`: Prepares PostgreSQL database for use with an ORM.

[Node.js Developer Scripts](./nodejs_developer/)

### Programmer Scripts

- `install_database.sh`: A script that provides a menu for installing different databases.
- `install_programming_language.sh`: Helps with the installation of various programming languages.

[Programmer Scripts](./programmer/)

### Server Setup Scripts

- `emailwiz.sh`: Configures the server to send and receive emails.
- `virtual_host_generator.sh`: Generates virtual host configurations.
- `webserver_installer.sh`: Installs and configures a web server.
- `worpress_site_installer.sh`: Automates the installation of WordPress sites.

[Server Setup Scripts](./server/)

## Usage

To use these scripts, navigate to the corresponding folder and run the script you need with appropriate permissions, typically with `sudo` if you are installing or configuring software:

```bash
cd <folder_name>
sudo ./<script_name>.sh
