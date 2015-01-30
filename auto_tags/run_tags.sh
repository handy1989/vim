#!/bin/bash
work_root=`dirname $(readlink -f $0)`
auto_tags_script=$work_root/auto_tags.sh
if [ $# -ne 1 ];then
    echo "usage:$0 [start/stop]"
    exit 1
fi
if [ $1 = "start" ];then
    nohup sh $auto_tags_script &
elif [ $1 = "stop" ];then
    ps axu | grep $auto_tags_script | grep -v grep | awk '{print $2}' | xargs -I{} -t kill "{}"
fi
