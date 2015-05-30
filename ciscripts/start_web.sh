#!/bin/bash

set -eux
set -o pipefail

FILE=$1
NUM=$2

DB=`cat $FILE|grep DB_IP |awk '{print $2}'`
echo "DB_IP : $DB"

export DCMGR_HOST=10.0.2.2
export account_id=a-shpoolxx


# for using retry_until
. ./ciscripts/wakame-vdc/retry.sh

. /etc/.musselrc

SSH=/var/lib/mykeypair

NUM_CPU_CORE=1
MEM_SIZE=512
SSH_KEY=ssh-tegv6qve
VDC_NAME="vdc-instance"`date +%Y%m%d-%H%M`
VIFS=./ciscripts/vifs.json

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

    scp -oStrictHostKeyChecking=no -i ${SSH} ./ciscripts/install_web.sh root@$IP:
    ssh -oStrictHostKeyChecking=no -i ${SSH} root@$IP bash install_web.sh $DB

    scp -oStrictHostKeyChecking=no -i ${SSH} ./ciscripts/test_web.sh root@$IP:
    ssh -oStrictHostKeyChecking=no -i ${SSH} root@$IP bash test_web.sh $DB
done
