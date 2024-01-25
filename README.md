# morangie

![readme_image](https://github.com/onur-zengin/morangie/assets/10590811/023dd08c-0832-4d85-a358-5c84890d438e)

**[1. Description](#1-description)**<br>
**[2. Cloud Deployment](#3-cloud-deployment)**<br>
**[3. Updating Cloud Deployment](#4-updating-cloud-deployment)**<br>
**[4. Removing Cloud Deployment](#5-removing-cloud-deployment)**<br>
**[5. Local Deployment](#6-local-deployment)**<br>
**[6. Changelog](#7-changelog)**<br>
**[7. Known Issues](#8-known-issues)**<br>
**[8. Planned For Later](#9-planned-for-later)**<br>
**[Appendix. Directory Structure](#2-directory-structure)**<br>


## 1. DESCRIPTION

Containerized Prometheus & Grafana installation with Docker Compose on Ubuntu Linux, packaged as a Terraform IaC project.

Designed as a single-instance monitoring & visualization solution (on AWS EC2) that can be configured to collect metrics from other systems (multi-cloud VMs & containers) via Prometheus HTTP pull. Collected metrics & syntethic alerts are then visualized on Grafana dashboards, which can be accessed through the co-hosted Nginx web server. 


## 2. CLOUD DEPLOYMENT

#### 2.1. PREREQUISITES

* An AWS account (with administrative rights to perform step #2.2.1)
* Following packages & dependencies to be installed on the local terminal (or a cloud-based IDE such as AWS Cloud9)

|                | release    |
| -------------- | ----------:|
| AWS CLI        | >= 2.11    |
| Terraform      | >= 1.5.5   |
| Git            | >= 2.42.0  |
| Python3        | >= 3.9.6   |
| Pip3           | >= 23.3.2  |
| Boto3          | >= 1.34.23 |
| Botocore       | >= 1.34.23 |
| Ansible        | >= 2.15.8  |


#### 2.2. PROCEDURE

**2.2.1.** Go to AWS Console & create an IAM user for the infrastructure automation tasks;

* It is strongly recommended by AWS not to create access keys for the root account.
```
AWS Console > IAM > Users:
- Create User > Specify User Name
- Set Permissions > Attach Policies Directly > Choose 'Administrator Access'
- Create Access Key > Other
```
* 'Administrator Access' may be replaced with a custom least-privilege permissions policy in a future release. 


**2.2.2.** Configure AWS CLI environment on the local terminal (or cloud-based IDE) with the access keys obtained from #2.2.1;
```
aws configure
```
* Follow the prompts to configure AWS Access Key ID and the Secret Access Key.

**2.2.3.** Clone the remote repository onto the local terminal and change working directory;
```
git clone https://github.com/onur-zengin/aws-ec2-linux-docker.git
cd aws-ec2-linux-docker/
```

**2.2.4.** Create an RSA key pair in your home directory and copy the public key `aws_linux.pub` here under the `./keys` directory;
```
ssh-keygen -t rsa -m PEM -f ~/.ssh/aws_linux
chmod 400 ~/.ssh/aws_linux
cp ~/.ssh/aws_linux.pub ./keys
```
* The key pair will be used for SSH access to the EC2 instance later.

**2.2.5.** Execute the Ansible playbook to deploy the Terraform infrastructure;
```
ansible-playbook ansible-deploy.yml -i localhost,
```
* Do not skip the trailing comma (,) after localhost

* Specify an AWS deployment region at the prompt or click enter to accept default (eu-central-1)


#### 2.3. VERIFICATION

* Collect the HOST_IP_ADDRESS from the output of step #2.2.5, 

* And try the following URLs on a web browser;
```
    http://[HOST_IP_ADDRESS]/prom
    http://[HOST_IP_ADDRESS]/graf
```

* Both Prometheus & Grafana will be installed with the default admin password: `admin`. See procedure #3.4 below to change it.

* If / when you also complete procedure #3.5 (optional), then the web server will redirect connections to secure (HTTPS) URLs instead.


## 3. POST-DEPLOYMENT ACTIONS

#### 3.1. Prometheus Targets Setup

**3.1.1.** Install the Prometheus node_exporter binary on the target hosts and make sure it is running;

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

- **Note:** If / when working with a large number of targets, these steps may also be automated with Ansible.

**3.1.2.** **Important:** Make sure to update the AWS Security Group and / or external firewalls fronting the target hosts, to allow incoming connections on TCP port 9100 **only from** the HOST_IP_ADDRESS which was listed in the output of step #3.2.5.

**3.1.3.** Inside the local working directory, edit `configs/prometheus/prometheus.yml` to add new targets to the configuration as applicable

**3.1.4.** Go to step #4 Updating Cloud Deployment


#### 3.2. Updating Prometheus Alerting Rules

**3.2.1.** Inside the local working directory, edit `configs/prometheus/alerts.yml` as necessary.

**3.2.2.** Save the changes made inside the local working directory and/or its subfolders.

**3.2.3.** Apply changes;
```
ansible-playbook update-infrastructure.yml -i localhost,
```
* By design; changes made to configuration files will trigger the EC2 instance to be re-created, while its static IP address and application data are persisted.

- **Note:** These steps may be replaced with a CI/CD pipeline.


#### 3.3. Grafana Dashboards Setup

* This step is merged into #3.2.4; the Ansible playbook will install two dashboards (Sys Charts & World Map) into Grafana after creating the AWS infrastructure.

* However, if you make any modifications to these pre-installed dashboards through the Grafana web interface, then do remember to save & export your updated configuration as JSON file(s). Those then can be placed under `configs/grafana/dashboard_*.json` to be auto-installed in a new deployment.


#### 3.4. Prometheus & Grafana Admin Password Resets

**3.4.1.** Connect to the EC2 instance;
```
ssh -i ~/.ssh/aws_linux ubuntu@[HOST_IP_ADRESS]
```

**3.4.2.** Prometheus; 
```
tbc
```

**3.4.3.** Grafana;
```
sudo docker exec -u root $(docker ps | grep graf | awk {'print $1'}) grafana cli admin reset-admin-password [NEW_PASSWORD]
```


#### 3.5. Domain Setup (optional)

**3.5.1.** Go to your DNS zone configuration and create an A record for the static IP address;
```
DOMAIN_NAME     A       HOST_IP_ADDRESS
vmon.foo.com    A       XX.XX.XX.XX
```

**3.5.2.** Obtain a TLS certificate for the DOMAIN_NAME created above (note that you may also use an _existing_ wildcard cert for the parent domain).

* Sample instructions for requesting a certificate from Let's Encrypt can be found at;
```
https://certbot.eff.org/
```

* Sample output;
```
sudo certbot certonly --dns-route53 -d *.foo.com

Saving debug log to /var/log/letsencrypt/letsencrypt.log
Requesting a certificate for *.foo.com

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/foo.com/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/foo.com/privkey.pem
This certificate expires on 2024-04-21.
These files will be updated when the certificate renews.
```

**3.5.3.** Upload the TLS certificate to AWS Secrets Manager;
```
chmod +x ./scripts/putSecrets.py
sudo ./scripts/putSecrets.py PATH_TO_PEM_FILES DOMAIN_NAME AWS_REGION
```
* The Python script will look for `fullchain.pem` and `privkey.pem` inside the specified path and upload them to AWS Secrets Manager. Subsequently, it will update the local configuration files for Docker & Nginx.

* Sample usage;
```
sudo ./scripts/putSecrets.py /etc/letsencrypt/live/foo.com vmon.foo.com eu-central-1
```

**3.5.4.** Apply changes;
```
ansible-playbook ansible-update.yml -i localhost,
```
* By design; changes made to configuration files will trigger the EC2 instance to be re-created, while its static IP address and application data are going to be persisted.



## 6. IN-SERVER CONFIG UPDATES >>> CONSIDER MOVING THIS UNDER LOCAL DEPL.

In certain use cases (esp. for test & development purposes), it may be handy to modify configuration directly on the server, rather than locally updating config files (#4) and then pushing a new deployment (#5).

The following is an example of how #4.2 can be performed directly on the server; 

#### 6.1. Prerequisites

- SSH access aws_linux.pub

#### 6.2. Updating Prometheus Alerting Rules

- **6.2.1.** (optional) SSH into the EC2 instance, and edit `/etc/prometheus/alerts.yml` as necessary

- **6.2.2.** Validate the syntax;
```
docker exec -u root $(docker ps | grep prom | awk {'print $1'}) promtool check rules /etc/prometheus/alerts.yml
```
- **6.2.3.** Restart the Prometheus container;
```
cd /etc/docker
docker compose kill -s SIGHUP prometheus 
```


## 7. REMOVING CLOUD DEPLOYMENT

#### 7.1. PREREQUISITES

Same as #3.1

#### 7.2. PROCEDURE

- **7.2.1.** Execute the following Ansible playbook to destroy the Terraform infrastructure;
```
ansible-playbook ansible-destroy.yml -i localhost,
```
* The command will look for the AWS region information and S3 bucket names inside `ansible-state.json` which was auto-created during the initial deployment.

- **7.2.2.** If you had also uploaded your TLS certificate to AWS Secrets Manager (as shown in #4.5.3), then remove it with the following command;
```
aws secretsmanager delete-secret --secret-id cert-encoded --force-delete-without-recovery --region [AWS_REGION]
```

## 8. LOCAL DEPLOYMENT 

For test & development purposes.

#### 8.1. PRE-REQUISITES

* Following packages & dependencies to be installed on the local terminal;

|                | release    |
| -------------  | ----------:|
| docker         | >=         |
| docker-compose | >=         |

#### 8.2. PROCEDURE

</tbc>


## 9. CHANGELOG

n/a


## 10. KNOWN ISSUES

n/a


## 11. PLANNED FOR LATER

* Email alerts
* Add authentication to Prometheus web interface
* Prometheus alerts & records configuration to be optimized 
* Optimize memory usage on the main host
* Test & document local deployment procedure (on MacOS)
* Define least-privilege permissions for AWS IAM policies
* Complete the demo_fargate module to demonstrate container monitoring 
* Automate certificate renewal


## APPENDIX. DIRECTORY STRUCTURE

```
.
├── configs                        
│   ├── docker
│   │   ├── compose.yml         # Sets up Docker bridge network and container runtime
│   │   ├── daemon.json         # Sets Docker root directory on the EBS drive (for data persistence)
│   ├── grafana
│   │   ├── db_worldmap.json    # Dashboard configuration (World Map view)
│   │   ├── db_syscharts.json   # Dashboard configuration (CPU, Mem, Disk, & NW-interface utilization charts)
│   │   ├── geo.json            # Geo-coordinates of AWS regions for visualization purposes on Grafana dashboard
│   ├── nginx
│   │   ├── nginx_http.conf     # Basic (non-secure) web server configuration (used when TLS cert not found)
│   │   ├── nginx.conf          # Secure web server configuration
│   ├── prometheus
│   │   ├── alerts.yml
│   │   ├── prometheus.yml      # Main configuration file for Prometheus (including targets)
│   │   ├── records.yml         # Frequently queried metrics to pre-populate TSDB
├── images                      # (optional) Image files to be displayed as nodes on Grafana dashboard  
│   ├── logo_base.svg    
│   ├── logo_alert.svg      
├── keys                        
│   ├── aws_linux.pub           # SSH public key file for remote access to the main EC2 host (not included)
├── modules                        
│   │   ├── demo_ec2            # (optional) Demo module to setup EC2 VMs as synthetic targets for Prometheus
│   │   ├── demo_fargate        # (optional) Demo module to setup Fargate Containers as synthetic targets for Prometheus
│   │   ├── grafana             # Post-installation Grafana setup as Terraform IaC (deprecated & replaced with Ansible tasks)
├── policies                    # AWS IAM resource-based policies                        
│   ├── ec2_assumeRole.json
│   ├── ec2_getSecrets.json
│   ├── s3_bucketPolicy.json
├── scripts                     # Python scripts to upload & download TLS certs to & from AWS Secrets Manager                   
│   ├── getSecrets.py           # Executed on EC2 
│   ├── putSecrets.py           # Executed on the local terminal
│   ├── requirements.txt        # Python requirements for putSecrets.py
ansible-deploy.yml              # Ansible playbook file to deploy Terraform IaC 
ansible-destroy.yml             # Ansible playbook file to destroy Terraform IaC 
ansible-update.yml              # Ansible playbook file to modify Terraform IaC 
ansible.cfg                     # Ansible configuration with Python interpreter auto-detection disabled
backend.tf                      # Terraform remote backend on AWS S3 & DynamoDB
bootstrap.tf                    # Cloud-init configuration to upload files & install packages on EC2 instance during boot
demo.tf                         # Configuration settings for the demo setup (default: off)
LICENCE                         # MIT License
main.tf                         # Main Terraform IaC build
outputs.tf                      # Terraform outputs (modifications to this file will impact ansible-deploy procedure)
providers.tf                    # Terraform providers
README.md                       # This file
variables.tf                    # Environment variables for the main instance. Sub-modules' variables placed under their respective directories.
```
