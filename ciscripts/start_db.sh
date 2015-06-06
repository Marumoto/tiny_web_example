#!/bin/bash

#############################################
# usage : ./this.sh path_to_parameter_file
#############################################

set -eux
set -o pipefail

# for using retry_until
. ./ciscripts/wakame-vdc/retry.sh

FILE=$1

SSH=/var/lib/mykeypair

# envs for mussel
. /etc/.musselrc
export DCMGR_HOST=10.0.2.2
export account_id=a-shpoolxx

NUM_CPU_CORE=1
MEM_SIZE=256
SSH_KEY=ssh-tegv6qve
VDC_NAME="vdc-instance"`date +%Y%m%d-%H%M`
VIFS=./ciscripts/vifs.json



ID=`mussel instance create --hypervisor kvm --cpu-cores ${NUM_CPU_CORE} --image-id wmi-centos1d64 --memory-size ${MEM_SIZE} --ssh-key-id ${SSH_KEY} --display-name ${VDC_NAME} --vifs ${VIFS} | grep :id |awk '{print $2}'`

sleep 10 #wait for ip scheduling

IP=`mussel instance show ${ID}|grep :address |awk '{print $2}'`


echo "instance_id : $ID"
echo "IP address  : $IP"

echo "DB ${IP} ${ID}" >$FILE # 新規生成

retry_until [[ '"$(mussel instance show "${ID}" | egrep -w "^:state: running")"' ]]

sleep 25 # wait for ssh daemon startup

# DB サーバにssh して環境構築を行う
scp -oStrictHostKeyChecking=no -i ${SSH} ./ciscripts/install_db.sh root@$IP:
ssh -oStrictHostKeyChecking=no -i ${SSH} root@$IP bash install_db.sh
