#!/usr/bin/env bash

set -euxo pipefail

function expand() {
    f="${1}"
    echo $f
    resolution=$(
        ffprobe \
            -v error \
            -select_streams v:0 \
            -show_entries stream=width,height \
            -of csv=s=x:p=0 \
            $SRCDIR/$f |
            tr ' ' '\n' |
            head -n 1
    )

    echo "RESOLUTION" $resolution

    imgdir=$TMPDIR/$resolution/$f.images
    if [[ ! -f $imgdir/done ]]
    then
        mkdir -p $imgdir &&
        ffmpeg \
            -nostdin \
            -skip_frame nokey \
            -i "$SRCDIR/$f" \
            -vsync 0 \
            -r 30 \
            -f image2 \
            $imgdir/keyframe-%05d.jpeg &&
        ffprobe -v quiet -select_streams v -skip_frame nokey -show_frames -show_entries frame=pkt_pts_time $SRCDIR/$f > $imgdir/keyframes.list &&
        touch $imgdir/done
    fi

    hlsdir=$TMPDIR/$resolution/$f.hls
    if [[ ! -f $hlsdir/done ]]
    then
        mkdir -p $hlsdir &&
        ffmpeg \
            -nostdin \
            -i "$SRCDIR/$f" \
            -c copy \
            -flags +cgop \
            -g 30 \
            -hls_time 0 \
            -hls_list_size 0 \
            -hls_segment_filename $hlsdir/segment-%05d.ts \
            $hlsdir/out.m3u8 &&
        touch $hlsdir/done
    fi
}

if [ $# -eq 0 ]
then
    SRCDIR=$HOME/Downloads/input/
    TMPDIR=$HOME/tmp
    for f in $(cd $SRCDIR && find . -name '*.mp4' | sed 's:^[.]/::' )
    do
        expand "${f}"
    done
elif [ $# -eq 3 ]
then
    SRCDIR="${1}"
    TMPDIR="${2}"
    f="${3}"
    expand "${f}"
else
    echo "please provide either 0 arguments or SRCDIR TARGETDIR filename"
fi
