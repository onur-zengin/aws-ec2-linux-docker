# morangie

![readme_image](https://github.com/onur-zengin/morangie/assets/10590811/023dd08c-0832-4d85-a358-5c84890d438e)

**[1. Description](#description)**<br>
**[2. Directory Structure](#directory-structure)**<br>
**[3. Dependencies](#dependencies)**<br>
**[4. How To Install (Linux)](#how-to-install-linux)**<br>
**[5. How To Install (MacOS)](#how-to-install-macos)**<br>
**[6. Demo Setup](#demo-setup)**<br>
**[7. Known Issues](#known-issues)**<br>
**[8. Planned Features](#planned-features)**<br>

## 1. DESCRIPTION

Containerized Prometheus & Grafana installation with Docker Compose on AWS EC2 (Ubuntu Linux), packaged as a Terraform IaC project (codename: morangie).

Designed as a single-instance monitoring & visualization solution that can be configured to collect metrics from other systems (multi-cloud VMs & containers) via Prometheus HTTP pull. Collected metrics & syntethic alerts are then visualized on Grafana dashboards, which can be accessed through the co-hosted Nginx web server. 

## 2. DIRECTORY STRUCTURE

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
│   │   ├── nginx_http.conf     # Basic (non-secure) web server configuration
│   │   ├── nginx.conf          # Secure web server configuration
│   ├── prometheus
│   │   ├── alerts.yml
│   │   ├── prometheus.yml      #
│   │   ├── records.yml         #
├── images                      # (optional) image files to be displayed as nodes on Grafana dashboard  
│   ├── logo_circle_base.svg    
│   ├── logo_circle_red.svg      
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

## 3. CLOUD DEPLOYMENT (AUTOMATED)

#### 3.1. PRE-REQUISITES

* An AWS account (with administrative rights to execute #3.2.1)
* AWS CLI, Terraform, and Git to be installed on the local machine
* Python3, PIP3, Boto3, and Ansible to be installed on the local machine

#### 3.2. PROCEDURE

3.2.1. Go to AWS Console to create a dedicated user for automation tasks; 

...
Note: This step may be considered optional, however, recommended as an AWS account governance & security best practice.

3.2.2. Configure AWS CLI environment on the local machine with the access keys obtained from #3.2.1
```
aws configure
```
Follow the prompts to configure AWS Access Key ID and the Secret Access Key.

3.2.3. Configure Ansible environment on the local machine;

- Add the following line to /etc/ansible/hosts;
```
localhost              ansible_connection=local
```

- Add the following line to /etc/ansible/ansible.cfg 
```
interpreter_python=/usr/bin/python3
display_args_to_stdout=True
```

3.2.4. Clone the remote repository into local machine;
```
git clone https://github.com/onur-zengin/aws-ec2-linux-docker.git
cd aws-ec2-linux-docker/
```

3.2.5. Execute the Ansible playbook to deploy the Infrastructure-as-Code;
```
ansible-playbook create-backend.yml 
```




## 4. CLOUD DEPLOYMENT (MANUAL)

#### 4.1. PRE-REQUISITES

* An AWS account (with administrative rights to execute #4.2.1)
* AWS CLI, Terraform, Ansible, and Git to be installed on the local machine

#### 4.2. PROCEDURE

4.2.0. Variables

AWS_REGION = ""
GRAFANA_PW = ""

4.2.1. Create a user account & remote backend on AWS for Terraform 

[todo: automate this with Ansible / CloudFormation]

IAM user        [..., access keys]
S3 bucket       [name:S3_BUCKET_NAME, versioning:enabled]  
DynamoDB table  [tableName:tfstate-lock-vmon, partitionKey:LockID]
Secrets Manager [grafana_auth:GRAFANA_PW]

Note: S3 bucket and DynamoDB table should be created in AWS_REGION.

4.2.2. (optional) Upload the TLS certificate for Nginx Web Server to AWS Secrets Manager

[todo: automate this with Python / Ansible / CloudFormation & merge into #4.2.1]

4.2.3. Configure AWS CLI with the access keys obtained from #4.2.1
```
aws configure
```
Follow the prompts to configure AWS Access Key ID and the Secret Access Key.

4.2.4. Clone the remote repository into local machine;
```
git clone https://github.com/onur-zengin/aws-ec2-linux-docker.git
cd aws-ec2-linux-docker/
```

4.2.5. Initialize working directory, install required providers and create the state file in the remote backend;
```
terraform init -backend-config="bucket=S3_BUCKET_NAME"
terraform init -backend-config="bucket=tfstate-vmon-04012024"
```

4.2.6. Create an execution plan;
```
terraform plan -out="tfplan"
```

4.2.7. Apply the planned configuration;
```
terraform apply "tfplan"
```


#### 4.3. DEMO SETUP

node_exporter binary to be installed on the target hosts


#### 4.4. DASHBOARD SETUP


## 5. REMOVING DEPLOYMENT
```
terraform destroy
```


## 6. LOCAL INSTALLATION (MacOS)

#### 6.1. PRE-REQUISITES

docker
docker compose

#### 6.2. DEPLOYING WITH DOCKER COMPOSE


## 7. KNOWN ISSUES
## 8. PLANNED FEATURES

- Alerts to be sent as emails
