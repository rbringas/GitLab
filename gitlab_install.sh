#!/bin/bash

# Quick and Dirty script to install GitLab on CentOS
# This is meant for spinning up a quick lab environment
# Production instances should have the appropriate firewall and selinux settings


# Author: Raul Bringas (@raulbringasjr)
# Tested on: CentOS 7
# Version: 0.1 - 8/27/2019

# Check to ensure the platform is CentOS
osRelease=`cat /etc/redhat-release | cut -f1 -d" "`

if [[ "$osRelease" == "CentOS" ]]; then
        echo "CentOS detected..."
else
        echo "Silly Rabbit, this is the Wrong OS!"
        echo "Exiting..."
        exit 1
fi

# Install Dependencies
echo "Installing Dependencies..."
sudo yum install epel-release curl policycoreutils-python openssh-server wget -y

# Enable sshd
echo "Enabling sshd..."
sudo systemctl enable sshd
sudo systemctl start sshd

# Allowing http traffic through the firewall
echo "Allowing http traffic through the firewall..."
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-service=http
sudo systemctl reload firewalld

# Install and enable postfix
echo "Installing and enabling postfix..."
sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix

# Download and install the gitlab repository
echo "Installing gitlab repository..."
wget -O /tmp/script.rpm.sh https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh
(($? != 0)) && { printf '%s\n' "Failed to download gitlab repository script, check internet connection!"; exit 1; }
sh /tmp/script.rpm.sh

# Set GitLab URL and install GitLab
read -p "Enter a url for your GitLab instance (ex. https://git.example.com): " gitLabURL
echo "Installing GitLab using the following URL: $gitLabURL"
sudo EXTERNAL_URL="$gitLabURL" yum install -y gitlab-ee
