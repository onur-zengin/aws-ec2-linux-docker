# morangie

1. DESCRIPTION

![readme_image](https://github.com/onur-zengin/morangie/assets/10590811/023dd08c-0832-4d85-a358-5c84890d438e)

Containerized Prometheus & Grafana installation with Docker Compose on AWS EC2 (Ubuntu Linux), packaged as a Terraform IaC project (codename: morangie).

Monitoring & visualization solution pair that can be configured to collect metrics from other systems (multi-cloud VMs & containers) via HTTP pull. The metrics are then visualized as Grafana dashboards which can be accessed through the co-hosted Nginx web server, and optionally sent out to pre-configured destinations via Prometheus alerting.

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
│   │   ├── nginx_http.conf
│   │   ├── nginx.conf          #
│   ├── prometheus
│   │   ├── alerts.yml
│   │   ├── prometheus.yml      #
│   │   ├── records.yml         #
├── images                        
│   ├── ...
├── keys                        
│   ├── ...
├── modules                        
│   ├── ...
├── policies                        
│   ├── ...
├── scripts                        
│   ├── getSecrets.py
...

```

3. DEPENDENCIES

node_exporter binary on the target hosts

4. HOW TO INSTALL (LINUX)



5. HOW TO INSTALL (MacOS)


6. DEMO SETUP
7. KNOWN ISSUES
8. PLANNED FEATURES