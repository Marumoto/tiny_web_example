#!/bin/bash

#############################################
# usage : ./this.sh parameter_file num_of_web_server
#############################################

# $1 で渡されるファイルに記載のinstance をすべて停止する
# 期待するファイルのフォーマット：
#    ・"WEB {instance id} {ip address}" が1行以上存在すること
#    ・"DB {instance id} {ip address}" が1行のみ存在すること
#
# load balancer の登録内容のクリアはregist_lb.sh の冒頭処理に委ねる

set -exu
set -o pipefail

FILE=$1
NUM=$2 # 使用しない。

# envs for mussel
export DCMGR_HOST=10.0.2.2
export account_id=a-shpoolxx
. /etc/.musselrc


# $FILE に記載のinstance をすべてdestroy する
function destroy_instances(){
    while read LINE;
    do
        ID=`echo $LINE|awk '{print $2}'`
        echo "[CISCRIPT] Destroy instance : ${ID}"
        mussel instance destroy  ${ID}
    done <$FILE
}

destroy_instances
