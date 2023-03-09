#!/bin/bash
sudo apt update && sudo apt upgrade -y
sudo apt-get install mongodb -y
sudo systemctl start mongodb
sudo systemctl enable mongod
