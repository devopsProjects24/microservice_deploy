#!/bin/bash

sudo kubectl create namespace argocd
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sudo curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
sudo rm argocd-linux-amd64

sudo kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

sudo argocd admin initial-password -n argocd # password generator

# username admin
# will be generated from the last command
