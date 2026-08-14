#!/bin/bash
# Install SonarQube Dependencies
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
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip
unzip sonarqube-${SONAR_VERSION}.zip -d /opt/
mv /opt/sonarqube-${SONAR_VERSION} /opt/sonarqube
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
