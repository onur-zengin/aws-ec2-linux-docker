#!/bin/bash
echo "## Installing the stress utility"
sudo amazon-linux-extras install epel -y
sudo yum install stress -y
echo "## Downloading & installing node exporter"
sudo mkdir -p /downloads/prometheus_ne
sudo chmod 757 /downloads/prometheus_ne
cd /downloads/prometheus_ne
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar -xzvf node_exporter-1.6.1.linux-amd64.tar.gz
cd node_exporter-1.6.1.linux-amd64/
./node_exporter --web.listen-address 0.0.0.0:9100 &
#stress --cpu 3