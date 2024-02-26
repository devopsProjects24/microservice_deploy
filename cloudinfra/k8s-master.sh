#!/bin/bash

sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
sudo hostnamectl set-hostname "master-node"
exec bash
sudo vi /etc/hosts

echo "Private IP Address: ${aws_instance.k8s_instances_master.private_ip}" master-node  >> /etc/hosts
echo "Private IP Address: ${aws_instance.k8s_instances_slave.private_ip}" worker-node  >> /etc/hosts

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo mkdir /etc/apt/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt install -y kubelet=1.26.5-00 kubeadm=1.26.5-00 kubectl=1.26.5-00
sudo apt install docker.io -y
sudo mkdir /etc/containerd
sudo sh -c "containerd config default > /etc/containerd/config.toml"
sudo sed -i 's/ SystemdCgroup = false/ SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd.service
sudo systemctl restart kubelet.service
sudo systemctl enable kubelet.service
sudo kubeadm config images pull
sudo kubeadm init --pod-network-cidr=10.10.0.0/16 > /tmp/kubeadm_init_output.txt
grep -oP 'kubeadm join \S+' /tmp/kubeadm_init_output.txt | sed 's/kubeadm join //g' > /tmp/kubeadm_token.txt
sudo apt-get install -y apache2
sudo cp /tmp/kubeadm_token.txt /var/www/html/kubeadm_token.txt
sudo systemctl restart apache2
rm /tmp/kubeadm_init_output.txt /tmp/kubeadm_token.txt
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O
sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.10.0.0\/16/g' custom-resources.yaml
kubectl create -f custom-resources.yaml


