data "cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = <<-EOF
      package_update: true
      package_upgrade: true
      packages:
      # These instructions try to use "apt-get" by default, whilst Amazon Linux 2 comes with "yum". Hence, commented out. See "runcmd:" below.
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
          content: ${base64encode(file("${path.module}/configs/compose.yml"))}
          owner: root:root
          permissions: '0644'
        - path: /etc/docker/prometheus/prometheus.yml
          encoding: b64
          content: ${base64encode(file("${path.module}/configs/prometheus.yml"))}
          owner: root:root
          permissions: '0644'
      bootcmd:
      # bootcmd runs on every boot.
        - echo "## Updating system $(hostnamectl | grep Kernel)" 
        - yum update -y
      # Ignore the 'command not found' error during first boot. runcmd (see below) will take it over & complete.
        - echo "## Booting up containers (1)" 
        - cd /etc/docker/
        - docker compose up -d 
      runcmd:
      # runcmd runs only during first boot. If there is an existing filesystem on the data volume, mkfs will detect it & skip.
        - echo "## Mounting data volume" 
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
        - yum install docker -y
        - systemctl start docker
        - systemctl enable docker
        - echo "## Installing the Compose plugin" 
        - sudo mkdir -p /usr/local/lib/docker/cli-plugins/
        - sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
        - sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
      # Can't leave this solely under bootcmd, since it is executed before runcmd during first boot
        - echo "## Booting up containers (2)" 
        - cd /etc/docker/
        - docker compose up -d 
      final_message: "## The system is up after $UPTIME seconds"
    EOF
  }
}