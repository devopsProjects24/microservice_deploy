#!/bin/bash
sudo useradd jenkins
sudo yum update -y
sudo yum install git -y
sudo yum install java-17-amazon-corretto-devel -y
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
sudo yum install jenkins -y
sudo systemctl daemon-reload
sudo systemctl start jenkins
sudo systemctl enable jenkins