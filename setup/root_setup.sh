#!/bin/bash
apt-get update

# installing and configuring nvidia DRIVERS
apt-get install build-essential -y
apt install nvidia-driver-470 libnvidia-gl-470 libnvidia-compute-470 libnvidia-decode-470 libnvidia-encode-470 libnvidia-ifr1-470 libnvidia-fbc1-470 -y

# Docker
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install docker-ce docker-ce-cli containerd.io -y
# 'systemctl status docker' to check the service status
# allow docker to be used without sudo - THIS REQUIRES TO LOGOUT AND LOGIN AGAIN!!!
usermod -aG docker ubuntu # assuming "ubuntu" is the user name

# Nvidia Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
apt-get update -y
apt-get install -y nvidia-docker2