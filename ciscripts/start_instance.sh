#!/bin/bash

set -eu
set -o pipefail

vdc_name="vdc-instance"`date +=%Y%m%d-%H%M`

ID=`mussel instance create --hypervisor kvm --cpu-cores 1 --image-id wmi-centos1d64 --memory-size 256 --ssh-key-id ssh-ruekc3bs --display-name ${vdc_name} --vifs vifs.json | grep :id |awk '{print $2}'`

IP=`mussel instance show $ID|grep :address |awk '{print $2}'`


echo "instance_id : $ID"
echo "IP address  : $IP"

scp install_db.sh $IP:
ssh root@$IP bash install_db.sh


