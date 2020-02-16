# working pipelines
export GST_DEBUG_DUMP_DOT_DIR=$HOME/tmp/gst-debug-files/

gst-launch-1.0 \
    souphttpsrc location=http://localhost:5000/1920x1080/all-videos/ph5c0efef67c779.mp4.hls/filtered.m3u8 \
        ! hlsdemux ! tsdemux name=dem \
        ! multiqueue name=queue \
        ! h264parse \
        ! matroskamux name=mux ! filesink location=out.mkv \
    dem. ! queue. \
    queue. ! aacparse ! avdec_aac ! audioconvert ! mux.

# ^^^ OMG I DID IT.


true gst-launch-1.0 \
    souphttpsrc location=http://localhost:5000/1920x1080/all-videos/ph5c0efef67c779.mp4.hls/filtered.m3u8 \
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
