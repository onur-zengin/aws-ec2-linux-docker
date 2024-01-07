# morangie

![readme_image](https://github.com/onur-zengin/morangie/assets/10590811/023dd08c-0832-4d85-a358-5c84890d438e)

**[1. Description](## 1. DESCRIPTION)**<br>
**[2. Directory Structure](## 2. DIRECTORY STRUCTURE)**<br>
**[3. Cloud Deployment (Linux VM)](## 3. CLOUD DEPLOYMENT)**<br>
**[4. Updating Deployment]()**<br>
**[5. Removing Deployment]()**<br>
**[6. Local Deployment (MacOS)]()**<br>
**[7. Known Issues](#known-issues)**<br>
**[8. Planned Features](#planned-features)**<br>

## 1. DESCRIPTION

Containerized Prometheus & Grafana installation with Docker Compose on Ubuntu Linux, packaged as a Terraform IaC project (codename: morangie).

Designed as a single-instance monitoring & visualization solution (on AWS EC2) that can be configured to collect metrics from other systems (multi-cloud VMs & containers) via Prometheus HTTP pull. Collected metrics & syntethic alerts are then visualized on Grafana dashboards, which can be accessed through the co-hosted Nginx web server. 

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
ansible.cfg                     # Ansible configuration with Python interpreter auto-detection disabled
backend.tf                      # Terraform remote backend on AWS S3 & DynamoDB
bootstrap.tf                    # Cloud-init configuration to upload files & install packages on EC2 instance during boot
demo.tf                         # (optional) Configuration settings for the demo setup
deploy-infrastructure.yml       # Ansible playbook file to deploy IaC 
destroy-infrastructure.yml      # Ansible playbook file to destroy IaC
main.tf
outputs.tf
providers.tf
README.md                       # This file
variables.tf                    # Environment variables for the main instance. Submodule variables under respective directories
```

## 3. CLOUD DEPLOYMENT

#### 3.1. PRE-REQUISITES

* An AWS account (with administrative rights to execute step #3.2.1)
* AWS CLI, Terraform, and Git to be installed on the local machine
* Python3, PIP3, Boto3, and Ansible to be installed on the local machine

#### 3.2. PROCEDURE

3.2.1. Go to AWS Console & create a dedicated user for automation tasks; 

</tbc> define least privilege permissions </tbc> 

3.2.2. Configure AWS CLI environment on the local machine with the access keys obtained from #3.2.1
```
aws configure
```
Follow the prompts to configure AWS Access Key ID and the Secret Access Key.

3.2.3. Clone the remote repository into local machine;
```
git clone https://github.com/onur-zengin/aws-ec2-linux-docker.git
cd aws-ec2-linux-docker/
```

3.2.4. (optional) Upload the TLS certificate for Nginx Web Server to AWS Secrets Manager;

</tbc> [automate this with Python / Ansible / CloudFormation & merge into step #3.2.5]

3.2.5. Execute the Ansible playbook to deploy the Infrastructure-as-Code;
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
    
* If you had completed the optional step #3.2.4 above, then the web server will redirect you to the secure URLs instead.


## 4. UPDATING DEPLOYMENT

- updating configuration - update prom config with new targets
node_exporter binary to be installed on the target hosts

4.2.6. Create an execution plan;
```
terraform plan -out="tfplan"
```

4.2.7. Apply the planned configuration;
```
terraform apply "tfplan"
```


#### 4.3. DEMO SETUP

</tbc>optional</tbc>


## 5. REMOVING DEPLOYMENT

Execute the Ansible playbook to destroy the TF Infrastructure and Remote Backend;
```
ansible-playbook destroy-infrastructure.yml -i localhost,
```
* The command will prompt for the AWS region and S3 backend bucket name that was used during the initial deployment, which may be found both in the deployment logs and the AWS S3 console.


## 6. LOCAL INSTALLATION (MacOS)

#### 6.1. PRE-REQUISITES

docker
docker compose

#### 6.2. DEPLOYING WITH DOCKER COMPOSE


## 7. KNOWN ISSUES
## 8. PLANNED FEATURES

- Alerts to be sent as emails
