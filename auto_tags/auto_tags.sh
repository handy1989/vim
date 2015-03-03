#!/bin/bash

work_root=`dirname $(readlink -f $0)`

function log
{
    echo [`date +"%Y-%m-%d %H:%M:%S"`] $* >> $work_root/$log_file
}

conf_last_update_time=0

while [ 1 -gt 0 ]
do
    generate_tags=0
    # 如果配置文件有更新，则重新载入
    conf_cur_update_time=`date +%s -r ./auto_tags.conf`
    if [ $conf_cur_update_time -gt $conf_last_update_time ];then
        log "conf updated!"
        source ./auto_tags.conf
        generate_tags=1
    fi
    conf_last_update_time=$conf_cur_update_time

    cd $source_root || break

    if [ ! -f ./tags ];then
        generate_tags=1
    else
        latest_update_file_info=`find $source_dirs -name "*.cpp" -o -name "*.h" |
            xargs -I{} stat {} | grep -E "File|Modify" |
            awk '{if(NR%2==1){printf("%s ",$2)} else printf("%s-%s\n", $2, $3)}' |
            sort -k2r | head -1`

        if [ -z "$latest_update_file_info" ];then
            log "Something is wrong. maybe directories are empty!"
            break;
        fi
        latest_update_time=`echo "$latest_update_file_info" | awk '{print $2}'`
        tags_time=`stat ./tags | grep "Modify" | awk '{printf("%s-%s\n", $2, $3)}'`
        log "latest_update_file_info: $latest_update_file_info"
        log "tags_time: $tags_time"
        if [[ "$latest_update_time" > "$tags_time" ]];then
            generate_tags=1
        else
            log "tags is newer than source files!"
        fi
    fi 
    if [ $generate_tags -eq 1 ];then
        log "execute: /usr/bin/ctags -o tags.new -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ $source_dirs"
        $CTAGS -o tags.new -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ $source_dirs
        if [ $? -ne 0 ];then
            log "generate tags.new failed!"
            break
        else
            log "mv tags.new to tags!"
            mv tags.new tags
        fi
    fi
    sleep 10
    log_size=`wc -c $work_root/$log_file | awk '{print $1}'`
    if [ $log_size -gt $(($max_log_size*1024*1024)) ];then
        mv $work_root/$log_file $work_root/$log_file.bak
    fi

    cd -  || break
done
