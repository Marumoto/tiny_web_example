#!/bin/bash

set -eu
set -o pipefail

$DB=$1

# for using retry_until
. ./wakame-vdc/retry.sh

. ~/.musselrc

SSH=mykeypair

NUM_CPU_CORE=1
MEM_SIZE=256
SSH_KEY=ssh-tegv6qve
VDC_NAME="vdc-instance"`date +%Y%m%d-%H%M`
VIFS=vifs.json



ID=`mussel instance create --hypervisor kvm --cpu-cores ${NUM_CPU_CORE} --image-id wmi-centos1d64 --memory-size ${MEM_SIZE} --ssh-key-id ${SSH_KEY} --display-name ${VDC_NAME} --vifs ${VIFS} | grep :id |awk '{print $2}'`

sleep 10 #wait for ip scheduling

IP=`mussel instance show $ID|grep :address |awk '{print $2}'`


echo "instance_id : $ID"
echo "IP address  : $IP"

retry_until [[ '"$(mussel instance show "${ID}" | egrep -w "^:state: running")"' ]]

scp -i ${SSH} install_web.sh $IP:
ssh -i ${SSH} root@$IP bash install_web.sh  $DB


