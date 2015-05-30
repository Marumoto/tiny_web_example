#!/bin/bash


#############################################
# usage : ./this.sh ip_address_of_db_server
#############################################

set -eux
set -o pipefail


DBSERVER_IP=$1

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

cd /opt/axsh/tiny-web-example/spec_integration
bundle install

cd /opt/axsh/tiny-web-example/spec_integration/config
cp webapi.conf.example webapi.conf

sed -i -e "s|localhost|${DBSERVER_IP}|g" webapi.conf


cd /opt/axsh/tiny-web-example/spec_integration
bundle exec rspec ./spec/webapi_integration_spec.rb

