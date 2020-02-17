set -e

# working pipelines
export GST_DEBUG_DUMP_DOT_DIR=$HOME/tmp/gst-debug-files/
echo
echo
echo
echo
echo
echo
(
    head -n $((3 * 10)) \
        $HOME/tmp/montage-interleaved-1920x1080-Cosplay.m3u8 &&
    tail -n 1 \
        $HOME/tmp/montage-interleaved-1920x1080-Cosplay.m3u8
) |
    tee $HOME/tmp/head.m3u8

echo
echo
gst-launch-1.0 \
    filesrc location=$HOME/tmp/montage-interleaved-1920x1080-Cosplay.m3u8 \
        ! hlsdemux ! tsdemux name=dem \
        ! multiqueue name=queue \
        ! h264parse \
        ! mpegtsmux name=mux ! filesink location=$HOME/tmp/montage-interleaved-1920x1080-Cosplay.ts \
    dem. ! queue. \
    queue. ! aacparse ! mux. \

# ^^^ OMG I DID IT.
echo "DONE"

true gst-launch-1.0 \
    souphttpsrc location=http://localhost:5000/1920x1080/all-videos/ph5c4402553423d.mp4.hls/filtered.m3u8 \
        ! hlsdemux name=demux ! tsdemux name=dem \
        ! multiqueue name=queue \
        ! h264parse ! vtdec ! autovideosink \
    dem. ! queue. \
    queue. ! aacparse ! avdec_aac ! audioconvert ! autoaudiosink



true gst-launch-1.0 \
    souphttpsrc location=http://localhost:5000/1920x1080/all-videos/ph5c0efef67c779.mp4.hls/filtered.m3u8 \
        ! hlsdemux name=demux ! decodebin name=dec \
        ! multiqueue name=queue \
        ! autovideosink \
    dec. ! queue. \
    queue. ! audioconvert ! autoaudiosink

true gst-launch-1.0 \
    uridecodebin \
        uri=http://localhost:5000/1920x1080/all-videos/ph5c0efef67c779.mp4.hls/filtered.m3u8 \
        name=dec \
        ! multiqueue name=queue \
        ! autovideosink \
    dec. ! queue. \
    queue. ! audioconvert ! autoaudiosink


false gst-launch-1.0 \
    uridecodebin \
        uri=http://localhost:5000/1920x1080/all-videos/ph5c0efef67c779.mp4.hls/filtered.m3u8 \
        name=dec \
        ! multiqueue \
            max-size-buffers=0 \
            max-size-bytes=0 \
            max-size-time=0 \
            name=queue \
        ! matroskamux name=mux ! filesink location=out.mkv \
    dec. ! queue. \
    queue. ! audioconvert ! mux.
