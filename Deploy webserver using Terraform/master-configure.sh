#!/bin/bash

apt-get update
apt-get install software-properties-common

#python
apt install python3
python3 --version
apt install python3-pip
apt-get install -y python-simplejson

#ansible
apt-add-repository ppa:ansible/ansible
apt-get install ansible
ansible --version

#terraform
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
apt update && sudo apt install terraform

apt update
apt upgrade

#azure cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az account set --subscription "2fc0173e-cada-4000-82db-566c79d396db"

#install docker-compose
