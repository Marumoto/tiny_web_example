#!/bin/bash

set -exu
set -o pipefail

export DCMGR_HOST=10.0.2.2
export account_id=a-shpoolxx

. /etc/.musselrc
FILE=$1
NUM=$2

LB_ID=lb-mkuhkuv3

# TODO :まず、LBに登録されている既存のVIFを掃除しなければならない

while read LINE;
do
    echo $LINE
    if [ -n "`echo $LINE | grep 'WEB'`" ] ; then
        ID=`echo $LINE|awk '{print $2}'`
        IP=`echo $LINE|awk '{print $3}'`
        VIF=`mussel instance show ${ID}|grep :vif_id|awk '{print $3}'`

        mussel load_balancer register ${LB_ID} --vifs ${VIF}
        mussel load_balancer show ${LB_ID}
    fi
done<$FILE




