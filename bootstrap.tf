data "cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = <<-EOF
      package_update: true
      package_upgrade: true
      packages:
      # Replaced by manual installation. See "runcmd:" below.
      #  - docker.io
      #  - docker-compose
      users:
        - default
        - name: pne
          lock_passwd: true
          gecos: Prom-NE Deployer
          sudo: ["ALL=(ALL) NOPASSWD:ALL"]
          shell: /bin/bash
        - name: docker
          lock_passwd: true
          gecos: Container Manager
          #groups: [root]
          sudo: ["ALL=(ALL) NOPASSWD:ALL"]
          shell: /bin/bash
      # Cloud-init documentation confirms that disk definitions for AWS not yet implemented at the time of writing. https://cloudinit.readthedocs.io/en/23.2.2/reference/examples.html
      # fs_setup:
      #  - filesystem: xfs
      #  - device: /dev/xvdf
      #  - overwrite: FALSE
      # mounts:
      #  - [ "xvdf", "/data", "xfs", "defaults,nofail", "0", "2" ]
      # "0" to prevent the FS from being dumped, and "2" to indicate that it is a non-root device.
      write_files:
        - path: /etc/docker/compose.yml
          encoding: b64
          content: ${base64encode(file("${path.module}/configs/docker/compose.yml"))}
          owner: root:root
          permissions: '0644'
        - path: /etc/docker/daemon.json
          encoding: b64
          content: ${base64encode(file("${path.module}/configs/docker/daemon.json"))}
          owner: root:root
          permissions: '0644'
        - path: /etc/docker/prometheus/prometheus.yml
          encoding: b64
          content: ${base64encode(file("${path.module}/configs/prometheus/prometheus.yml"))}
          owner: root:root
          permissions: '0644'
        - path: /etc/docker/prometheus/alerts.yml
          encoding: b64
          content: ${base64encode(file("${path.module}/configs/prometheus/alerts.yml"))}
          owner: root:root
          permissions: '0644'
        - path: /etc/docker/nginx/conf.d/nginx.conf
          encoding: b64
          content: ${base64encode(file("${path.module}/configs/nginx/nginx.conf"))}
          owner: root:root
          permissions: '0644'
        - path: /etc/docker/nginx/conf.d/nginx_http.conf
          encoding: b64
          content: ${base64encode(file("${path.module}/configs/nginx/nginx_http.conf"))}
          owner: root:root
          permissions: '0644'
        - path: /etc/docker/nginx/ssl/getSecrets.py
          encoding: b64
          content: ${base64encode(file("${path.module}/scripts/getSecrets.py"))}
          owner: root:root
          permissions: '0744'
      bootcmd:
      # bootcmd runs on every boot.
        # During first boot, runcmd (see below) will take this over & complete. 
      #  - echo "## Booting up containers" 
      #  - cd /etc/docker/
      #  - docker compose up -d 
      runcmd:
      # runcmd runs only during first boot, after bootcmd.
        - echo "## Mounting data volume" 
        # If there is an existing filesystem on the data volume, mkfs (by default) will detect it & skip.
        - export EBS_DEVICE_NAME=$(lsblk | grep disk | grep -v 8G | awk {'print $1'})
        - mkfs -t xfs /dev/$EBS_DEVICE_NAME
        - xfs_admin -L data /dev/$EBS_DEVICE_NAME
        - mkdir /data
        - mount -t xfs -o defaults,nofail /dev/$EBS_DEVICE_NAME /data
        - echo "## Updating fstab for future reboots" 
        - echo $(sudo blkid | grep -i "label=\"data\"" |  awk '{print $3}')$'\t'/data$'\t'xfs$'\t'defaults,nofail$'\t'0$'\t'2 >> /etc/fstab
        - echo $(cat /etc/fstab) 
        - echo "## Downloading & installing node exporter"
        - mkdir -p /usr/local/bin/prometheus_ne
        - cd /usr/local/bin/prometheus_ne
        - wget -q https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
        - tar -xzvf node_exporter-1.6.1.linux-amd64.tar.gz
        - chown -R pne:pne /usr/local/bin/prometheus_ne
        - cd node_exporter-1.6.1.linux-amd64/
        - su pne -c "./node_exporter --web.listen-address 0.0.0.0:9100 &"
        - echo "## Installing Docker" 
        - apt-get install docker.io -y
        #- systemctl start docker
        #- systemctl enable docker
        - echo "## Installing Docker Compose plugin" 
        - [ mkdir, -p, /usr/local/lib/docker/cli-plugins/ ]
        - [ curl, -SL, "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64", -o, /usr/local/lib/docker/cli-plugins/docker-compose ]
        - [ chmod, +x, /usr/local/lib/docker/cli-plugins/docker-compose ]
        - echo "## Installing AWS SDK boto3 with Python PIP" 
        #- [ apt-get, install, -y, python3.10-venv ]
        #- [ python3, -m, venv, secret-env ]
        #- [ source, secret-env/bin/activate ]
        - [ apt-get, install, python3-pip, -y ]
        - [ pip, install, boto3 ]
        - echo "## Importing TLS certificate from AWS Secrets Manager"
        - [ chown, -R, docker:docker, /etc/docker ]
        - [ cd, /etc/docker/nginx/ssl ]
        - [ su, docker, -c, "./getSecrets.py cert_encoded ${var.region}" ]
        #- [ deactivate ]
        # The following is executed in place of its copy under bootcmd during first boot
        - echo "## Downloading & Booting up containers" 
        - [ cd, /etc/docker/ ]
        - [ su, docker, -c, "docker compose up -d" ]
      final_message: "## The system is up after $UPTIME seconds"
    EOF
  }
}