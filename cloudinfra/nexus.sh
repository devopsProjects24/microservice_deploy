#!/bin/bash
sudo yum install java-1.8.0-amazon-corretto-devel.x86_64 -y
cd /opt
sudo wget https://download.sonatype.com/nexus/3/nexus-3.64.0-04-unix.tar.gz
sudo tar -xvzf nexus-3.64.0-04-unix.tar.gz
sudo mv nexus-3.64.0-04 nexus
sudo useradd nexus
sudo chown -R nexus:nexus sonatype-work
sudo chown -R nexus:nexus nexus

#provide root access to nexus
cd /
cd /etc/
#add below
sudo echo "nexus ALL=(ALL)    NOPASSWD: ALL" | tee -a sudoers

cd /opt/nexus/bin
sudo echo "run_as_user="nexus"" | tee -a nexus.rc

#give soft link
sudo ln -s /opt/nexus/bin/nexus /etc/init.d/nexus
cd /etc/init.d
sudo chkconfig --add nexus
sudo chkconfig --levels 345 nexus on
su nexus
service nexus start
service nexus enable
service nexus run
service nexus restart
service nexus status