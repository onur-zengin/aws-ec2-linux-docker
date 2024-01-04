# morangie

1. DESCRIPTION

![readme_image](https://github.com/onur-zengin/morangie/assets/10590811/023dd08c-0832-4d85-a358-5c84890d438e)

Containerized Prometheus & Grafana installation with Docker Compose on AWS EC2 (Ubuntu Linux), packaged as a Terraform IaC project (codename: morangie).

Designed as a single-instance monitoring & visualization solution that can be configured to collect metrics from other systems (multi-cloud VMs & containers) via Prometheus HTTP pull. Collected metrics & syntethic alerts are then visualized on Grafana dashboards, which can be accessed through the co-hosted Nginx web server. 

### Table of Contents
**[1. Description](#description)**<br>
**[2. Directory Structure](#directory-structure)**<br>
**[3. Dependencies](#dependencies)**<br>
**[4. How To Install (Linux)](#how-to-install-linux)**<br>
**[5. How To Install (MacOS)](#how-to-install-macos)**<br>
**[6. Demo Setup](#demo-setup)**<br>
**[7. Known Issues](#known-issues)**<br>
**[8. Planned Features](#planned-features)**<br>

2. DIRECTORY STRUCTURE

```
.
├── configs                        
│   ├── docker
│   │   ├── compose.yml
│   │   ├── daemon.json         #
│   ├── grafana
│   │   ├── db_map.json
│   │   ├── db_ne.json          #
│   │   ├── geo.json            #
│   ├── nginx
│   │   ├── nginx_http.conf     # 
│   │   ├── nginx.conf          # Secure web server configuration
│   ├── prometheus
│   │   ├── alerts.yml
│   │   ├── prometheus.yml      #
│   │   ├── records.yml         #
├── images                        
│   ├── logo_circle_base.svg    # (optional) Company logo to be displayed as a node on Grafana Worldmap Dashboard
│   ├── logo_circle_red.svg     # 
├── keys                        
│   ├── aws_linux.pub           # SSH public key file for remote access to main EC2 host
│   ├── demo_linux.pub          # (optional) SSH public key file for remote access to demo EC2 hosts
├── modules                        
│   │   ├── demo_ec2            # (optional) Demo module to setup EC2 VMs as synthetic targets for Prometheus
│   │   ├── demo_fargate        # (optional) Demo module to setup Fargate Containers as synthetic targets for Prometheus
│   │   ├── grafana             # Grafana dashboard configuration as Terraform IaC
├── policies                        
│   ├── ec2_assumeRole.json
│   ├── ec2_getSecrets.json
├── scripts                        
│   ├── getSecrets.py           # Python script to download TLS cert from AWS Secrets Manager and configure Nginx 
backend.tf                      # Terraform remote backend on AWS S3 & DynamoDB
bootstrap.tf                    # Cloud-init configuration to upload files & install packages on EC2 instance during boot
demo.tf                         # (optional) Configuration settings for the demo setup
main.tf
outputs.tf
providers.tf
README.md                       # This file
variables.tf                    # Environment variables for the main instance. Submodule variables under respective directories
```

3. DEPENDENCIES

terraform cli installed
aws cli installed
git installed

4. CLOUD INSTALLATION (LINUX)

4.1. PRE-REQUISITES

aws account
aws terraform remote backend
aws terraform user (access keys)
conf aws cli
```
$ aws configure
```
follow the prompts to configure aws access key ID and secret access key

git clone ...
cd vmon

tls cert on aws secrets manager

terraform installed on the local machine

4.2. DEPLOYING WITH TERRAFORM

4.2.a. Initialize the working directory and install required providers;
```
terraform init --upgrade
```

4.2.b. Create an execution plan and save to ...
```
terraform plan --...
```

4.2.c. Apply the planned configuration;
```
terraform apply --...
```

4.3. DEMO SETUP

node_exporter binary on the target hosts

4.4. DASHBOARD SETUP



5. LOCAL INSTALLATION (MacOS)

5.1. PRE-REQUISITES

docker
docker compose

5.2. DEPLOYING WITH DOCKER COMPOSE


6. ...
7. KNOWN ISSUES
8. PLANNED FEATURES

    . Alerts to be sent as emails
