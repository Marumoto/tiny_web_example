#!/bin/bash

set -eu
set -o pipefail

FILE=$1
NUM=$2

DB=`cat $FILE|grep DB_IP |awk '{print $2}'`
echo "DB_IP : $DB"


# for using retry_until
. ./wakame-vdc/retry.sh

. ~/.musselrc

SSH=mykeypair

NUM_CPU_CORE=1
MEM_SIZE=512
SSH_KEY=ssh-tegv6qve
VDC_NAME="vdc-instance"`date +%Y%m%d-%H%M`
VIFS=vifs.json

for i in $(seq 1 $NUM)
do
    ID=`mussel instance create --hypervisor kvm --cpu-cores ${NUM_CPU_CORE} --image-id wmi-centos1d64 --memory-size ${MEM_SIZE} --ssh-key-id ${SSH_KEY} --display-name ${VDC_NAME} --vifs ${VIFS} | grep :id |awk '{print $2}'`

    sleep 10 #wait for ip scheduling

    IP=`mussel instance show $ID|grep :address |awk '{print $2}'`


    echo "instance_id : $ID"
    echo "IP address  : $IP"

    echo "WEB $ID $IP" >>$FILE

    retry_until [[ '"$(mussel instance show "${ID}" | egrep -w "^:state: running")"' ]]


    sleep 25

    scp -oStrictHostKeyChecking=no -i ${SSH} install_web.sh $IP:
    ssh -oStrictHostKeyChecking=no -i ${SSH} root@$IP bash install_web.sh $DB
done
