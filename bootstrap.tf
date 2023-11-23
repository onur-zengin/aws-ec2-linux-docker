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
      groups:
        - docker
      system_info:
        default_user:
          groups: [docker]
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
        - path: /etc/docker/prometheus/prometheus.alerts.yml
          encoding: b64
          content: ${base64encode(file("${path.module}/configs/prometheus/alerts.yml"))}
          owner: root:root
          permissions: '0644'
      bootcmd:
      # bootcmd runs on every boot.
        # During first boot, runcmd (see below) will take this over & complete. 
        - echo "## Booting up containers" 
        - cd /etc/docker/
        - docker compose up -d 
      runcmd:
      # runcmd runs only during first boot, after bootcmd.
        - echo "## Mounting data volume" 
        # If there is an existing filesystem on the data volume, mkfs (by default) will detect it & skip.
        - sudo mkfs -t xfs /dev/xvdf
        - sudo xfs_admin -L data /dev/xvdf
        - sudo mkdir /data
        - sudo mount -t xfs -o defaults,nofail /dev/xvdf /data
        - echo "## Updating fstab for future reboots" 
        - sudo chmod 666 /etc/fstab
        - echo $(sudo blkid | grep -i "label=\"data\"" |  awk '{print $3}')$'\t'/data$'\t'xfs$'\t'defaults,nofail$'\t'0$'\t'2 >> /etc/fstab
        - echo $(cat /etc/fstab) 
        - sudo chmod 644 /etc/fstab
        - echo "## Installing Docker" 
        - sudo apt install docker.io -y
        - systemctl start docker
        - systemctl enable docker
        - echo "## Installing Docker Compose plugin" 
        - sudo mkdir -p /usr/local/lib/docker/cli-plugins/
        - sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
        - sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
        - echo "## Downloading & installing node exporter"
        - sudo mkdir -p /usr/local/bin/prometheus_ne
        - sudo chmod 757 /usr/local/bin/prometheus_ne
        - cd /usr/local/bin/prometheus_ne
        - wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
        - tar -xzvf node_exporter-1.6.1.linux-amd64.tar.gz
        - cd node_exporter-1.6.1.linux-amd64/
        - ./node_exporter --web.listen-address 0.0.0.0:9100 &
        # The following is executed in place of its copy under bootcmd during first boot
        - echo "## Downloading & Booting up containers" 
        - cd /etc/docker/
        - docker compose up -d 
      final_message: "## The system is up after $UPTIME seconds"
    EOF
  }
}



