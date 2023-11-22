#!/bin/bash
echo "## Installing the stress utility"
sudo amazon-linux-extras install epel -y
sudo yum install stress -y
echo "## Downloading & installing node exporter"
sudo mkdir -p /usr/local/bin/prometheus_ne
sudo chmod 757 /usr/local/bin/prometheus_ne
cd /usr/local/bin/prometheus_ne
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar -xzvf node_exporter-1.6.1.linux-amd64.tar.gz
cd node_exporter-1.6.1.linux-amd64/
./node_exporter --web.listen-address 0.0.0.0:9100 &


#cloud-config 

#write_files:
#  - owner: root:root
#    path: /etc/cron.d/your_cronjob
#    content: * */2 * * * [USER] du -s njain/

# stress --cpu 8 --io 4 --vm 2 --vm-bytes 128M --timeout 10s