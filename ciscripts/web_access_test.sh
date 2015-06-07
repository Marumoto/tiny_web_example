
#!/bin/bash

#############################################
# usage : ./this.sh 
#############################################

set -exu
set -o pipefail

LB_IP=10.0.22.104

# check webapi
echo "checking webapi ...."
curl -fs -X POST --data-urlencode display_name='webapi test' --data-urlencode comment='sample message.' http://$LB_IP/api/0.0.1/comments

# check get command
echo "checking GET ...."
curl -fs -X GET http://$LB_IP/api/0.0.1/comments

# check get(show) command
echo "checking GET(show) ...."
curl -fs -X GET http://$LB_IP/api/0.0.1/comments/1
