#!/usr/bin/env bash

yum update
yum install docker -y

#sudo usermode -aG docker ec2-user
systemctl enable docker
systemctl start docker

#docker login -u eldarmustafayev -p 3ab5d002-4f05-4136-99e7-bf5591179c94
sudo docker run -p 8080:8080                       \
                -e DB_HOST=${DB_HOST}              \
                -e DB_USER=${DB_USER}              \
                -e DB_PASSWORD=${DB_PASSWORD}      \
                -e DB_NAME=${DB_NAME}              \
                eldarmustafayev/abbtech-backend 
           