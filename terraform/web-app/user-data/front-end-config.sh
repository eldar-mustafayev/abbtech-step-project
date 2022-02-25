#!/usr/bin/env bash

yum update
yum install docker -y

#usermode -aG docker ec2-user
systemctl enable docker
systemctl start docker

#docker login -u eldarmustafayev -p 3ab5d002-4f05-4136-99e7-bf5591179c94
sudo docker run -p 80:80 -e BACKEND_HOST=${BACKEND_HOST} eldarmustafayev/abbtech-frontend