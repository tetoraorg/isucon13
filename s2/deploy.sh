#!/bin/bash

if [ $0 != "./deploy.sh" ]; then
  echo "Run this script from \$SERVER directory"
  exit 1
fi

set -eux

# Environment
# env_file_from=$HOME/env.sh
# env_file_to=./$(basename $env_file_from)
# if [ ! -e $env_file_to ]; then
#   if [ -e $env_file_from ]; then
#     cp -f $env_file_from $env_file_to
#   else
#     touch $env_file_to
#   fi

#   cat << EOF >> $env_file_to
export APP=isupipe-go
export SERVICE=$APP.service
export SERVER=s2
export GIT_REPO_DIR=$HOME/webapp
export BASE_DIR=$GIT_REPO_DIR/$SERVER
export PPROTEIN_GIT_REPOSITORY=$GIT_REPO_DIR
export PATH=$PATH:$BASE_DIR/bin


# Copy files
sudo cp -f $BASE_DIR/env.sh $HOME/env.sh
sudo cp -f $BASE_DIR/etc/nginx/nginx.conf /etc/nginx/nginx.conf
sudo cp -f $BASE_DIR/etc/nginx/sites-available/default /etc/nginx/sites-available/default
sudo cp -f $BASE_DIR/etc/nginx/sites-enabled/isupipe.conf /etc/nginx/sites-enabled/isupipe.conf

sudo cp -f $BASE_DIR/etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
sudo cp -f $BASE_DIR/etc/sysctl.conf /etc/sysctl.conf
sudo sysctl -p


# Build
# cd $GIT_REPO_DIR/go && go build -o $APP
make -C $HOME/webapp/go build


# Log
# NOTE: mysql-slow.log must be readable by both mysql and isucon user
sudo chmod +r /var/log/*
sudo sudo usermod -aG mysql isucon
sudo rm -rf /var/log/mysql/mysql-slow.log \
  && sudo touch /var/log/mysql/mysql-slow.log \
  && sudo chmod +r /var/log/mysql/mysql-slow.log \
  && sudo chown mysql:mysql /var/log/mysql \
  && sudo chown mysql:mysql /var/log/mysql/mysql-slow.log
sudo rm -rf /var/log/nginx/access.log \
  && sudo touch /var/log/nginx/access.log \
  && sudo chmod +r /var/log/nginx/access.log

# Restart
sudo systemctl restart mysql
sudo systemctl restart nginx
sudo systemctl restart $SERVICE

# Slow Query Log
# sudo mysql -uisucon -pisucon -e 'SET GLOBAL long_query_time = 0; SET GLOBAL slow_query_log = ON; SET GLOBAL slow_query_log_file = "/var/log/mysql/mysql-slow.log";'
sudo mysql -uisucon -pisucon -e 'SET GLOBAL slow_query_log = OFF; SET GLOBAL slow_query_log_file = "/var/log/mysql/mysql-slow.log";'
