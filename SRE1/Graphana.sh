#!/bin/bash


sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

#Update package manager
sudo apt-get update -y

#Install Graphana
sudo apt-get install grafana
sudo systemctl daemon-reload

#Start and enable the service
sudo systemctl start grafana-server
sudo systemctl enable grafana-server.service