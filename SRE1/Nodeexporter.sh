#!/bin/bash

#download and extract the package for node exporter 

cd /tmp/
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.0-rc.0/node_exporter-1.0.0-rc.0.linux-amd64.tar.gz
tar -zxvf node_exporter-1.0.0-rc.0.linux-amd64.tar.gz 
cp node_exporter-1.0.0-rc.0.linux-amd64/node_exporter /usr/local/bin/