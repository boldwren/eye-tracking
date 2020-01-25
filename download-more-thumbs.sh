#!/usr/bin/env bash

set -euo pipefail

TIMEOUT=/usr/local/Cellar/coreutils/*/bin/timeout

mkdir -p all-thumbs
mkdir -p thumbs-mostviewed

function expand_url(){
    moredir="$1"
    url="$2"
    count="$3"
    for i in `seq $count 0`
    do
        maybe_url=$(echo "$url" | sed 's/[0-9]*[.]jpg$'/"$i.jpg"/)
        maybe_file=$(echo "$maybe_url" | sed s:^.*/::)
        $TIMEOUT 10 wget \
            --directory-prefix=all-thumbs \
            --timeout=10 \
            --no-clobber \
            --no-verbose \
            "$maybe_url" \
            || break
        cp -v all-thumbs/$maybe_file $moredir
    done
}


function fix_dir(){
    dir="$1"
    moredir="thumbs-$dir"

    (diff <(ls "$dir") <(ls "$moredir") || true) |
        (grep '^<.*[0-9].jpg$' || true) |
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
    limit="$2"
    moredir="thumbs-$dir"

    count=$(find "$moredir" | grep '[0-9][.]jpg$' | wc -l || true)
    if [ $count -gt $limit ]
    then
        echo "$dir already done $count"
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
    for limit in `seq 500 500`
    do
        ls -d mostviewed/*/ |
            shuf |
            (
                IFS=$'\n'
                while read dir;
                do
                    expand_dir "${dir}" "${limit}"
                    # fix_dir "${dir}"
                done
            )
    done
}

expand_all

# expand_dir thumbs/Bondage
