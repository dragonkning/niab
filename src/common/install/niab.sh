#!/usr/bin/env bash

yum clean all
yum -y install epel-release
yum clean all
yum -y install niab
chmod +x -v /etc/yum.repos.d/niab.repo
chmod +x -v $INST_SCRIPTS/*.sh

## create index.html to forward automatically to `vnc_lite.html`

