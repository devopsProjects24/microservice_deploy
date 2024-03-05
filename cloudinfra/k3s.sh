#!/bin/bash
sudo apt update  -y
sudo apt upgrade -y 
sudo curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" sh -s - --disable traefik
sudo mkdir .kube
sudo cp /etc/rancher/k3s/k3s.yaml ./config
sudo chown dmistry:dmistry config
sudo chmod 400 config
sudo export KUBECONFIG=~/.kube/config
sudo snap install kubectl --classic

