# morangie

![readme_image](https://github.com/onur-zengin/morangie/assets/10590811/023dd08c-0832-4d85-a358-5c84890d438e)

**[1. Description](#1-description)**<br>
**[2. Directory Structure](#2-directory-structure)**<br>
**[3. Cloud Deployment](#3-cloud-deployment)**<br>
**[4. Updating Cloud Deployment](#4-updating-cloud-deployment)**<br>
**[5. Removing Cloud Deployment](#5-removing-cloud-deployment)**<br>
**[6. Local Deployment](#6-local-deployment)**<br>
**[7. Changelog](#7-changelog)**<br>
**[8. Known Issues](#8-known-issues)**<br>
**[9. Planned For Later](#9-planned-for-later)**<br>

## 1. DESCRIPTION

Containerized Prometheus & Grafana installation with Docker Compose on Ubuntu Linux, packaged as a Terraform IaC project (codename: morangie).

Designed as a single-instance monitoring & visualization solution (on AWS EC2) that can be configured to collect metrics from other systems (multi-cloud VMs & containers) via Prometheus HTTP pull. Collected metrics & syntethic alerts are then visualized on Grafana dashboards, which can be accessed through the co-hosted Nginx web server. 

## 2. DIRECTORY STRUCTURE

```
.
├── configs                        
│   ├── docker
│   │   ├── compose.yml
│   │   ├── daemon.json         # Setting Docker root directory on the EBS drive
│   ├── grafana
│   │   ├── db_map.json         # Dashboard configuration (world map view)
│   │   ├── db_ne.json          # Dashboard configuration (CPU, Mem, Disk, & NW-interface utilization charts)
│   │   ├── geo.json            # Geo-coordinates of AWS regions for visualization purposes on Grafana dashboard
│   ├── nginx
│   │   ├── nginx_http.conf     # Basic (non-secure) web server configuration (used when TLS cert not found)
│   │   ├── nginx.conf          # Secure web server configuration
│   ├── prometheus
│   │   ├── alerts.yml
│   │   ├── prometheus.yml      # Main configuration file for Prometheus (including targets)
│   │   ├── records.yml         
├── images                      # (optional) Image files to be displayed as nodes on Grafana dashboard  
│   ├── logo_circle_base.svg    
│   ├── logo_circle_red.svg      
├── keys                        
│   ├── aws_linux.pub           # SSH public key file for remote access to main EC2 host
│   ├── demo_linux.pub          # (optional) SSH public key file for remote access to demo EC2 hosts
├── modules                        
│   │   ├── demo_ec2            # (optional) Demo module to setup EC2 VMs as synthetic targets for Prometheus
│   │   ├── demo_fargate        # (optional) Demo module to setup Fargate Containers as synthetic targets for Prometheus
│   │   ├── grafana             # Post-installation Grafana setup as Terraform IaC
├── policies                        
│   ├── ec2_assumeRole.json
│   ├── ec2_getSecrets.json
├── scripts                     # Python scripts to upload & download TLS certs to & from AWS Secrets Manager                   
│   ├── getSecrets.py           # Executed on EC2 
│   ├── putSecrets.py           # Executed on the local machine
│   ├── requirements.txt        # Python requirements for putSecrets.py
ansible.cfg                     # Ansible configuration with Python interpreter auto-detection disabled
backend.tf                      # Terraform remote backend on AWS S3 & DynamoDB
bootstrap.tf                    # Cloud-init configuration to upload files & install packages on EC2 instance during boot
demo.tf                         # (optional) Configuration settings for the demo setup
deploy-infrastructure.yml       # Ansible playbook file to deploy Terraform IaC 
destroy-infrastructure.yml      # Ansible playbook file to destroy Terraform IaC
main.tf
outputs.tf
providers.tf
README.md                       # This file
variables.tf                    # Environment variables for the main instance. Sub-modules' variables placed under their respective directories.
```


## 3. CLOUD DEPLOYMENT

#### 3.1. PREREQUISITES

* An AWS account (with administrative rights to perform step #3.2.1)
* Following packages & dependencies to be installed on the local machine (or a cloud-based IDE such as AWS Cloud9)

|                | release    |
| -------------- | ----------:|
| AWS CLI        | >= 2.11    |
| Terraform      | >= 1.5.5   |
| Git            | >= 2.42.0  |
| Python3        | >= 3.9.6   |
| Pip3           | >= 23.3.2  |
| Boto3          | >= 1.33.2  |
| Ansible        | >= 2.15.8  |

#### 3.2. PROCEDURE

**3.2.1.** Go to AWS Console & create a dedicated user for the infrastructure automation tasks;

</tbc> define least privilege permissions </tbc> 

**3.2.2.** Configure AWS CLI environment on the local machine (or cloud-based IDE) with the access keys obtained from #3.2.1
```
aws configure
```
Follow the prompts to configure AWS Access Key ID and the Secret Access Key.

**3.2.3.** Clone the remote repository into local machine and change working directory;
```
git clone https://github.com/onur-zengin/aws-ec2-linux-docker.git
cd aws-ec2-linux-docker/
```

**3.2.4.** Execute the Ansible playbook to deploy the Terraform infrastructure;
```
ansible-playbook deploy-infrastructure.yml -i localhost,
```
* Do note the trailing comma after localhost

</tbc> install grafana dashboards </tbc>

#### 3.3. VERIFICATION

* Collect the HOST_IP_ADDRESS from the output of step #3.2.5, 

* And try the following URLs on a web browser;
    http://[HOST_IP_ADDRESS]/prom
    http://[HOST_IP_ADDRESS]/graf
    
* If you have completed the optional step #3.2.4 above, then the web server will redirect you to secure (HTTPS) URLs instead.


## 4. POST-DEPLOYMENT ACTIONS

#### 4.1. Prometheus Targets Setup

**4.1.1.** Install the Prometheus node_exporter binary on the target hosts and make sure it is running;

|                | release    |
| -------------  | ----------:|
| node_exporter  | >= 1.6.1   |

* Sample installation procedure for Ubuntu Linux;
```
sudo su -
useradd pne
mkdir -p /usr/local/bin/prometheus_ne
cd /usr/local/bin/prometheus_ne
wget -q https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar -xzvf node_exporter-1.6.1.linux-amd64.tar.gz
chown -R pne /usr/local/bin/prometheus_ne
cd node_exporter-1.6.1.linux-amd64/
su pne -c "./node_exporter --web.listen-address 0.0.0.0:9100 &"
```

* Note: If / when working with a large number of targets, these steps may also be automated with Ansible.

**4.1.2.** **Important:** Make sure to update the AWS Security Group and / or external firewalls fronting the target hosts, to allow incoming connections on TCP port 9100 **only from** the HOST_IP_ADDRESS which was listed in the output of step #3.2.5.

**4.1.3.** In the local directory; ... to add new targets to the collector, the file that has to be edited is configs/prometheus/prometheus.yml.

**4.1.4.** Go to step #5 Updating Cloud Deployment

#### 4.2. Grafana Dashboards Setup

* This step is merged into #3.2.4.

#### 4.3. Prometheus & Grafana Password Resets

* 
* 

#### 4.3. Domain Setup (optional)

**4.3.1.** Create a DNS record for the HOST_IP_ADDRESS

**4.3.2.** Obtain a TLS certificate 

**4.3.3.** Upload the TLS certificate to AWS Secrets Manager;

</tbc> [this will be automated with Python (putSecrets.py)]

**4.3.4.** Go to step #5 Updating Cloud Deployment


## 5. UPDATING CLOUD DEPLOYMENT

#### 5.1. PREREQUISITES

Same as #3.1

#### 5.2. PROCEDURE

**5.2.0.** Save the changes made in the local working directory / its subfolders.

**5.2.1.** Create a new execution plan (Terraform will auto-detect the changes);
```
terraform plan -out="tfplan"
```

**5.2.2.** Apply the planned configuration;
```
terraform apply "tfplan" [-auto-approve]
```
* Review changes and respond with 'yes' to the prompt, or use the '-auto-approve' option.


## 6. REMOVING CLOUD DEPLOYMENT

#### 6.1. PREREQUISITES

Same as #3.1

#### 6.2. PROCEDURE

Execute the following Ansible playbook to destroy the Terraform infrastructure;
```
ansible-playbook destroy-infrastructure.yml -i localhost,
```
* The command will prompt for the AWS region and S3 backend bucket name that was used during the initial deployment, which may be found both in the deployment logs and the AWS S3 console.


## 7. LOCAL DEPLOYMENT 

For test & development purposes.

#### 7.1. PRE-REQUISITES

* Following packages & dependencies to be installed on the local machine 

|                | release    |
| -------------  | ----------:|
| docker         | >=         |
| docker-compose | >=         |

#### 7.2. PROCEDURE

</tbc>

## 8. CHANGELOG

n/a


## 9. KNOWN ISSUES

n/a


## 10. PLANNED FOR LATER

* Email alerts
* Prometheus records & alerts configuration to be optimized 
* Automate TLS cert upload to AWS Secrets Manager
* Test & document local deployment procedure (on MacOS)
