#!/bin/bash

# Update and upgrade system packages
sudo apt update
sudo apt upgrade -y

# Install Java OpenJDK
sudo apt install openjdk-11-jdk -y

# Clear the terminal
clear

# Download and install Nexus
wget https://download.sonatype.com/nexus/3/nexus-3.70.1-02-java11-unix.tar.gz -P /opt
cd /opt
tar -xvzf nexus-3.70.1-02-java11-unix.tar.gz
mv nexus-3.70.1-02 nexus

# Create a new user for Nexus
sudo useradd nexus
sudo passwd nexus

# Edit sudoers file to allow Nexus user to run without a password
echo 'nexus ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers

# Change ownership of Nexus directories
sudo chown -R nexus:nexus /opt/nexus
sudo chown -R nexus:nexus /opt/sonatype-work

# Configure Nexus to run as the nexus user
cd /opt/nexus/bin/
sudo vim nexus.rc  # Add `run_as_user="nexus"` to the file
sudo vim nexus.vmoptions  # Adjust JVM options as needed

# Create a systemd service file for Nexus
sudo tee /etc/systemd/system/nexus.service <<EOF
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort
TimeoutSec=600

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Nexus service
sudo systemctl enable nexus
sudo systemctl start nexus
sudo systemctl status nexus

# Display admin password
cat /opt/sonatype-work/nexus3/admin.password

# Clear the terminal
clear
