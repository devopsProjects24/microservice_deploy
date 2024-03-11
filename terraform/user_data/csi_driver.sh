#!/bin/bash

# Install helm
wget https://get.helm.sh/helm-v3.14.2-linux-amd64.tar.gz
sudo tar -xzvf helm-v3.14.2-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
rm -rf helm-v3.14.2-linux-amd64.tar.gz

# Install EFS CSI Driver
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
helm repo update aws-efs-csi-driver
helm upgrade --install aws-efs-csi-driver --namespace kube-system aws-efs-csi-driver/aws-efs-csi-driver