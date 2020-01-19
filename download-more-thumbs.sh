#!/usr/bin/env bash

set -euo pipefail

TIMEOUT=/usr/local/Cellar/coreutils/*/bin/timeout

function expand_url(){
    moredir="$1"
    url="$2"
    count="$3"
    for i in `seq $count 0`
    do
        maybe_url=$(echo "$url" | sed 's/[0-9]*[.]jpg$'/"$i.jpg"/)
        $TIMEOUT 10 wget \
            --directory-prefix="$moredir" \
            --timeout=10 \
            --no-clobber \
            --no-verbose \
            "$maybe_url" \
            || break
    done
}


function fix_dir(){
    dir="$1"
    moredir="better$dir"

    (diff <(ls "$dir") <(ls "$moredir") || true) |
        (grep '^<.*[0-9].jpg$' || true)|
        (sed 's/^< //' || true) |
        shuf |
        (
            IFS=$'\n'
            while read thumb
            do
                echo $dir $thumb
                url="$(grep -F "$thumb" $dir/thumbs.urls)"
                expand_url "${moredir}" "${url}"
            done
        )
}

function expand_dir(){
    dir="$1"
    moredir="better$dir"
    if [ -d "$moredir" ]
    then
        return
    fi
    mkdir -p "$moredir"

    cat $dir/more-info.txt |
        (
            IFS=$'\n'
            while read line;
            do
                url=$(echo $line | cut -d § -f 2)
                count=$(echo $line | cut -d § -f 3)
                expand_url "${moredir}" "${url}" "${count}"
            done
        )
}

function expand_all(){
    ls -d thumbs/*/ |
        shuf |
        (
            IFS=$'\n'
            while read dir;
            do
                expand_dir "${dir}"
                # fix_dir "${dir}"
            done
        )
}

expand_all
