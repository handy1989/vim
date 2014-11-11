#!/bin/bash
source_dirs="common include message nodes tests metadata/node_metadata/src"
max_log_size=10 # Unit: MB
log_file="auto_tags.log"
#test

CTAGS=/usr/bin/ctags

function log
{
    echo [`date +"%Y-%m-%d %H:%M:%S"`] $* >> $log_file
}

while [ 1 -gt 0 ]
do
    if [ ! -f ./tags ];then
        log "execute: /usr/bin/ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ $source_dirs"
        $CTAGS -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ $source_dirs
        if [ $? -eq 0 ];then
            log "generate tags success!"
        else
            log "generate tags failed!"
            break
        fi
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
            log "execute: /usr/bin/ctags -o tags.new -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ $source_dirs"
            $CTAGS -o tags.new -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ $source_dirs
            if [ $? -eq 0 ];then
                mv tags.new tags
                log "move tags.new to tags!"
            else
                log "generate tags.new failed!"
                break
            fi
        else
            log "tags is newer than source files!"
        fi
    fi 
    sleep 10
    log_size=`wc -c $log_file | awk '{print $1}'`
    if [ $log_size -gt $(($max_log_size*1024*1024)) ];then
        mv auto_tags.log auto_tags.log.bak
    fi
done
