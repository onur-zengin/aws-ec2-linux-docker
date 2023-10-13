#!/bin/bash
echo "installing stress utility"
sudo amazon-linux-extras install epel -y
sudo yum install stress -y
echo "downloading & installing node exporter"
sudo mkdir /prom_ne
cd /prom_ne
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
sudo tar -xzvf node_exporter-1.6.1.linux-amd64.tar.gz 
cd node_exporter-1.6.1.linux-amd64/
./node_exporter --web.listen-address 0.0.0.0:8080

#stress --cpu 3