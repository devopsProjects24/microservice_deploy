#!/bin/bash
sudo apt-get update -y
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update -y
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql
sudo systemctl start postgresql
echo "postgres:adminpass" | sudo chpasswd

sudo -u postgres bash <<EOF
# Create user 'sonar'
createuser sonar
# Launch PostgreSQL CLI
psql <<SQL
-- Alter password for 'sonar' user
ALTER USER sonar WITH ENCRYPTED PASSWORD 'sonar';
-- Create database 'sonarqube' with owner 'sonar'
CREATE DATABASE sonarqube OWNER sonar;
-- Grant all privileges on database 'sonarqube' to 'sonar' user
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;
\q
SQL
EOF

sudo apt update -y
sudo apt install openjdk-17-jdk openjdk-17-jre -y

cat <<EOT> /etc/sysctl.conf
vm.max_map_count=524288
fs.file-max=131072
EOT

cat <<EOT> /etc/security/limits.conf
sonarqube   -   nofile   131072
sonarqube   -   nproc    8192
EOT

cd /opt/
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.3.79811.zip
sudo apt install unzip -y
sudo unzip sonarqube-9.9.3.79811.zip 
rm -rf sonarqube-9.9.3.79811.zip
sudo mv /opt/sonarqube-9.9.3.79811 /opt/sonarqube
sudo groupadd sonar
sudo useradd -g sonar sonar -d /opt/sonarqube
sudo chown -R sonar:sonar /opt/sonarqube

cat <<EOT>> /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar
sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube
EOT

cat <<EOT>> /etc/systemd/system/sonar.service
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

LimitNOFILE=131072
LimitNPROC=8192

[Install]
WantedBy=multi-user.target
EOT

sudo systemctl start sonar
sudo systemctl enable sonar
sudo echo "sonarqube" > /etc/hostname
echo "System reboot in 30 sec..."
sleep 30
reboot