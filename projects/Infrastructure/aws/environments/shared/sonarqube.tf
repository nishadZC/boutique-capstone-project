data "aws_vpc" "dev" {
  cidr_block = "10.1.0.0/16"
}

data "aws_subnets" "dev" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dev.id]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "sonarqube" {
  name        = "sonarqube-sg"
  description = "Security group for SonarQube"
  vpc_id      = data.aws_vpc.dev.id

  ingress {
    description = "SonarQube Web UI"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "sonarqube" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  key_name      = "devops-key"
  subnet_id     = data.aws_subnets.dev.ids[0]
  vpc_security_group_ids = [aws_security_group.sonarqube.id]

  user_data = replace(<<EOF
#!/bin/bash
# Trigger Terraform Cloud Replacement - V2

# Update and install dependencies
# Ubuntu often runs unattended-upgrades on boot which locks apt. This loop waits for it to finish.
until apt-get update -y; do sleep 5; done
until DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-17-jdk wget unzip acl postgresql postgresql-contrib; do sleep 5; done

# Configure PostgreSQL
sudo -u postgres psql -c "CREATE USER sonar WITH ENCRYPTED PASSWORD 'sonarpassword';"
sudo -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"

# Configure sysctl for Elasticsearch
echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
echo 'fs.file-max=65536' >> /etc/sysctl.conf
sysctl -p

# Add sonar user
groupadd sonar
useradd -c "Sonar System User" -d /opt/sonarqube -g sonar -s /bin/bash sonar

# Download and extract SonarQube
SONAR_VERSION="9.9.1.69595"
cd /tmp
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$${SONAR_VERSION}.zip
unzip sonarqube-$${SONAR_VERSION}.zip -d /opt/
mv /opt/sonarqube-$${SONAR_VERSION} /opt/sonarqube
chown -R sonar:sonar /opt/sonarqube

# Configure SonarQube JDBC settings
cat <<EOT >> /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=sonarpassword
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
EOT

# Create SystemD Service
cat <<EOT > /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOT

# Start and enable SonarQube
systemctl daemon-reload
systemctl enable sonarqube
systemctl start sonarqube
EOF
  , "\r", "")

  tags = {
    Name = "SonarQube-Server"
  }
}

output "sonarqube_public_ip" {
  value = aws_instance.sonarqube.public_ip
}
