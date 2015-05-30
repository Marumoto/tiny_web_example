#!/bin/bash

set -eu
set -o pipefail

. ~/.musselrc

FILE=$1
NUM=$2

LB_ID=

# TODO :まず、LBに登録されている既存のVIFを掃除しなければならない


while read LINE;
do
    echo $LINE
    if [ `echo $LINE | grep 'WEB'` ] ; then
        ID=`echo $LINE|awk '{print $1}'`
        IP=`echo $LINE|awk '{print $2}'`
        VIF=`mussel instance show ${ID}|grep :vif_id|awk '{print $3}`

        mussel load_balancer register ${LB_ID} --vifs ${VIF}
        mussel load_balancer show ${LB_ID}
    fi
done<$FILE




