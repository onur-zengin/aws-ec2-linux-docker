data "cloudinit_config" "demo_config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = <<-EOF
      package_update: true
      package_upgrade: true
      users:
        - default
        - name: pne
          lock_passwd: true
          gecos: Prom-NE Deployer
          sudo: ["ALL=(ALL) NOPASSWD:ALL"]
          shell: /bin/bash
      write_files:
        - path: /etc/cron.d/stress
          content: |
            */5 * * * * root stress --cpu 8 --io 4 --vm 2 --vm-bytes 128M --timeout 120s
          owner: root:root
          permissions: '0644'
      bootcmd:
      # bootcmd runs on every boot.
        # During first boot, runcmd (see below) will take this over & complete. 
        - echo "## Launching Node Exporter" 
        - cd /usr/local/bin/prometheus_ne/node_exporter-1.6.1.linux-amd64/
        - ./node_exporter --web.listen-address 127.0.0.1:9100 &
      runcmd:
      # runcmd runs only during first boot, after bootcmd.
        - echo "## Installing the stress utility"
        - amazon-linux-extras install epel -y
        - yum install stress -y
        #- echo "## Installing stunnel"
        #- yum install stunnel -y
        #- stunnel /etc/stunnel/stunnel.conf
        - echo "## Downloading & installing node exporter"
        - mkdir -p /usr/local/bin/prometheus_ne
        - cd /usr/local/bin/prometheus_ne
        - wget -q https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
        - tar -xzvf node_exporter-1.6.1.linux-amd64.tar.gz
        - chown -R pne:pne /usr/local/bin/prometheus_ne
        # The following is executed in place of its copy under bootcmd during first boot
        - echo "## Launching Node Exporter" 
        - cd node_exporter-1.6.1.linux-amd64/
        - su pne -c "./node_exporter --web.listen-address 0.0.0.0:9100 &"
      final_message: "## The system is up after $UPTIME seconds"
    EOF
  }
}



