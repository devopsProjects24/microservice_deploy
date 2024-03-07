#!/bin/bash

# Download GPG key and add it to apt keyring
wget -qO- https://s3-eu-west-1.amazonaws.com/deb.robustperception.io/41EFC99D.gpg | sudo apt-key add -

# Update package index
sudo apt-get update -y

# Install Prometheus and related components
sudo apt-get install prometheus prometheus-node-exporter prometheus-pushgateway prometheus-alertmanager -y

sudo systemctl start prometheus
sudo systemctl enable prometheus