data "cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = <<-EOF
      package_update: true
      package_upgrade: true
      packages:
        - docker.io
        - docker-compose
      groups:
        - docker
      system_info:
        default_user:
          groups: [docker]
      write_files:
        - path: /usr/local/lib/docker/compose.yml
          encoding: b64
          content: ${base64encode(file("${path.module}/configs/compose.yml"))}
          owner: root:root
          permissions: '0644'
        - path: /opt/docker/prometheus/prometheus.yml
          encoding: b64
          content: ${base64encode(file("${path.module}/configs/prometheus.yml"))}
          owner: root:root
          permissions: '0644'
      runcmd:
        - echo "## Updating system $(hostnamectl | grep Kernel)" 
        - yum update -y
        - echo "## Installing Docker" 
        - yum install docker -y
        - systemctl start docker
        - systemctl enable docker
        - echo "## Installing the Compose plugin" 
        - sudo mkdir -p /usr/local/lib/docker/cli-plugins/
        - sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
        - sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
        - echo "## Booting up containers" 
        - cd /usr/local/lib/docker/
        - docker compose up -d 
      final_message: "## The system is up after $UPTIME seconds"
    EOF
  }
}