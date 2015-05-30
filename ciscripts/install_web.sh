#!/bin/bash

#############################################
# usage : ./this.sh ip_address_of_db_server
#############################################

set -eux
set -o pipefail


DBSERVER_IP=$1

# add epel
rpm -ivh http://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm

yum repolist

yum -y install git

# install rbenv
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile

# isntall some packages for build ruby
yum install -y gcc openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel

# install ruby-build
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

# build ruby
rbenv install -v 2.0.0-p598
rbenv rehash
rbenv versions

# set default ruby
rbenv global 2.0.0-p598
ruby -v

# install bundler
gem install bundler --no-ri --no-rdoc


# install tiny-web-example
# TODO Should install by RPM
curl -fsSkL https://raw.githubusercontent.com/axsh/tiny_web_example/master/rpmbuild/tiny-web-example.repo  -o /etc/yum.repos.d/tiny-web-example.repo

git clone https://github.com/Marumoto/tiny_web_example.git
mkdir -p /opt/axsh
mv -i tiny_web_example /opt/axsh/tiny-web-example

yum install -y nginx mysql-server mysql-devel


# bundle install in webapi and frontend
cd /opt/axsh/tiny-web-example/webapi
bundle install
cd /opt/axsh/tiny-web-example/frontend
bundle install


# deploy init script
cd /opt/axsh/tiny-web-example/contrib/etc
cp default/* /etc/default/
cp init/* /etc/init/

# deploy config files
mkdir -p /etc/tiny-web-example
cp tiny-web-example/* /etc/tiny-web-example/

# create log dir
mkdir -p /var/log/tiny-web-example


#cp tiny-web-example-webapi /etc/default/
#cp tiny-web-example-webapp /etc/default/

# set DB_SERVER address to conf files.
sed -i -e "s|localhost|${DBSERVER_IP}|g" /etc/tiny-web-example/webapi.conf /etc/tiny-web-example/webapp.yml

# cd /opt/axsh/tiny-web-example/webapi/
# bundle exec rake db:up

# start App
initctl start tiny-web-example-webapi RUN=yes
initctl start tiny-web-example-webapp RUN=yes

# check webapi
echo "checking webapi ...."
curl -fs -X POST --data-urlencode display_name='webapi test' --data-urlencode comment='sample message.' http://localhost:8080/api/0.0.1/comments

# check get command
echo "checking GET ...."
curl -fs -X GET http://localhost:8080/api/0.0.1/comments

# check get(show) command
echo "checking GET(show) ...."
curl -fs -X GET http://localhost:8080/api/0.0.1/comments/1
