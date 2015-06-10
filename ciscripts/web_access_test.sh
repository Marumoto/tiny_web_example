
#!/bin/bash

#############################################
# usage : ./this.sh 
#############################################

set -exu
set -o pipefail

LB_IP=10.0.22.104

#install bundle
cd /opt/axsh/tiny-web-example/spec_integration
bundle install

#edit conf file
cd /opt/axsh/tiny-web-example/spec_integration/config
cp webapi.conf.example webapi.conf

# set LB address to conf files.
sed -i -e "s|localhost|${LB_IP}|g" /opt/axsh/tiny-web-example/spec_integration/config/webapi.conf

#execute test
cd /opt/axsh/tiny-web-example/spec_integration
bundle exec rspec ./spec/webapi_integration_spec.rb
