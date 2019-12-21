#!/usr/bin/env bash

set -euxo pipefail

TMPDIR=$HOME/tmp
SRCDIR=$HOME/Downloads/input/

for f in $(cd $SRCDIR && find . -name '*.mp4' | sed 's:^[.]/::' )
do
    echo $f
    resolution=$(
        ffprobe \
            -v error \
            -select_streams v:0 \
            -show_entries stream=width,height \
            -of csv=s=x:p=0 \
            $SRCDIR/$f
    )

    imgdir=$TMPDIR/$resolution/$f.images
    [[ ! -f $imgdir/done ]] &&
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
    
    hlsdir=$TMPDIR/$resolution/$f.hls
    [[ ! -f $hlsdir/done ]] &&
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
done
