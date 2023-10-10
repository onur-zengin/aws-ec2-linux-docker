#!/bin/bash
echo "user_data script loaded"
## Update the system (Amazon Linux 2)
## Note that in Amazon Linux 2023 the package manager is changed from 'yum' to 'dnf'
sudo yum update -y
echo "system updated" 
## Install Docker, start it, and make sure it comes back up when system reboots 
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
echo "docker installed" 
## Install Docker compose plugin
sudo mkdir -p /usr/local/lib/docker/cli-plugins/
sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
echo "docker compose plugin installed" 
## Configure Linux user group ('ec2-user' comes with the Amazon Linux image)
sudo groupadd docker
sudo usermod -a -G docker ec2-user
## Download images
echo "pulling images" 
docker pull prom/prometheus
docker pull grafana/grafana
# sudo docker run --name mynginx1 -p 80:80 -d nginx
echo "user_data script completed" 
