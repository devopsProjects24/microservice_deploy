#!/bin/bash
#Download the package 

sudo wget https://github.com/prometheus/alertmanager/releases/download/v0.16.2/alertmanager-0.16.2.linux-amd64.tar.gz

#Exract 
sudo tar -xvzf alertmanager-0.16.2.linux-amd64.tar.gz

#move the binary to bin 
sudo mv alertmanager-0.16.2.linux-amd64/alertmanager /usr/local/bin/
