#!/bin/bash

echo "Select the programming language you want to install:"
echo "1) Python"
echo "2) Node.js"
echo "3) Ruby"
echo "4) Java"
echo "5) Go"
echo "6) Rust"
echo "7) PHP"
echo "8) Kotlin"
echo "9) Scala"
echo "10) Elixir"
echo "11) Perl"
echo "12) Swift"
echo "13) R"
echo "14) Dart"
echo "15) Clojure"
read -p "Enter choice [1-15]: " language_choice

case $language_choice in
  1)
    sudo apt update
    sudo apt install -y python3
    ;;
  2)
    curl -sL https://deb.nodesource.com/setup_current.x | sudo -E bash -
    sudo apt-get install -y nodejs
    ;;
  3)
    sudo apt-get install -y ruby-full
    ;;
  4)
    sudo apt update
    sudo apt install -y default-jdk
    ;;
  5)
    wget https://golang.org/dl/go1.18.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.18.linux-amd64.tar.gz
    echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
    source ~/.profile
    ;;
  6)
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    ;;
  7)
    sudo apt update
    sudo apt install -y php
    ;;
  8)
    sudo snap install --classic kotlin
    ;;
  9)
    sudo apt install -y scala
    ;;
  10)
    wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
    sudo dpkg -i erlang-solutions_2.0_all.deb
    sudo apt update
    sudo apt install -y elixir
    ;;
  11)
    sudo apt update
    sudo apt install -y perl
    ;;
  12)
    sudo apt-get install -y clang
    curl -s https://swift.org/install.sh | sh
    ;;
  13)
    sudo apt update
    sudo apt install -y r-base
    ;;
  14)
    sudo apt update
    sudo apt install -y dart
    ;;
  15)
    sudo apt update
    sudo apt install -y leiningen
    ;;
  *)
    echo "Invalid selection"
    exit 1
    ;;
esac

echo "Installation complete."
