#!/bin/bash

####
# 
# This Script install:
# - Phabricator on port 80
# - Jenkins on port 81
# - SonarQube on port 82 
#
# Note that has been tested on Ubuntu Server 14.04
####

ROOT_FOLDER=/vagrant
MYSQL_ROOT_PASSWORD=CSk7jHw9Rkc=h5f

cd $ROOT_FOLDER
. install_phabricator.sh
. install_jenkins.sh
. install_sonarqube.sh

install_phabricator
install_jenkins
install_sonarqube