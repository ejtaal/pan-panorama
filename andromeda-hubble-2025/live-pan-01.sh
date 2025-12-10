#!/bin/bash

# TODO incorporate astrometry annotations overlays at each target

export LD_LIBRARY_PATH=/usr/local/lib 

DEBUG=n

MAGICK="firejail 
    --noprofile 
    --whitelist=~/repos/github/ejtaal/pan-panorama/andromeda-hubble-2025
    --whitelist=~/Downloads
    --appimage $HOME/Downloads/magick.appimage"
# Oh how much I hate imagemagick for giving random results when disk is full !!!!1111
rm -f /tmp/magick-*


# Largest Hubble M31 panorama mosaic:
# https://science.nasa.gov/mission/hubble/science/explore-the-night-sky/hubble-messier-catalog/messier-31/
FULL=~/Downloads/"Hubble_M31Mosaic_2025_42208x9870_STScI-01JGY8MZB6RAYKZ1V4CHGN37Q6.jpg"

COORDS=$'11400 2450 M32
5300 7235 NGC 206
1400 6860 Star cluster?
1600 6130 2MASS J00400547+4030383 -- Near-IR Source (λ < 3 µm) 
1700 5340 Bol 325 -- Globular Cluster 
2040 5900 Bol 323 -- Globular Cluster 
2160 4900 Star cluster
2940 5500 Another star cluster?
3266 5966 Another star cluster?
3500 6460 2MASS J00402472+4037498 Galaxy 
4100 4508 Bol 338 -- Globular Cluster 
4650 3000 Star cluster
6000 3000 Star cluster
7290 7780 Very cool region 1
8000 4100 Star cluster & Globular Cluster
8175 6175 Very cool region 2
8855 5650 BA 1-289
11530 5030 Star cluster
14870 3430 Very cool region 3
16300 3200 Very cool region 4
17680 3000 Star cluster
19000 2700 Backside of Andromeda Galaxy
21860 2620 BA 1-56 -- HII Region 
23800 2760 BA 1-100 -- HII Region 
25500 3030 [JSD2015] AP 5116 -- Cluster of Stars 
27400 3300 M31SCC J004514+413724 -- Cluster of Stars 
30420 3100 Bol 373 -- Globular Cluster 
30450 3950 [MBL93] 142 -- Association of Stars 
32100 4390 AP J00454469+4151594 -- Globular Cluster 
32670 4670 2MASS J00454400+4154272 -- Galaxy 
33000 5100 BA 1-212 -- HII Region 
35480 3540 BA 1-228 -- SuperNova Remnant 
38550 5600 BA 1-671 -- HII Region 
37400 6950 [JSD2012] PC 798 -- Cluster of Stars 
36720 7330 [JSD2015] AP 430 -- Galaxy 
35230 7750 2MASX J00452790+4207033 -- Galaxy 
31280 6990 Very cool region 5
30000 7660 Very cool region 6
25720 6700 Very cool region 7
0 0 Andromeda Galaxy (M31)'

COORDS=$'11400 2450 M32
5300 7235 NGC 206
0 0 Andromeda Galaxy (M31)'

# TODO:  create annotated images based on astrometry from the above coords

IMG_W=$(identify -ping "$FULL" | perl -pe 's/.* JPEG (\d+)x(\d+).*/\1/')
IMG_H=$(identify -ping "$FULL" | perl -pe 's/.* JPEG (\d+)x(\d+).*/\2/')
LEGEND_W=$((1920/4))
LEGEND_BOX_L=$((1920-LEGEND_W))
LEGEND_H=$((1080/4))

# 0 0 A'
# :||'

# Others TODO:
# https://noirlab.edu/public/images/noao-m31lgs_ubvIha/


:||"
36000 7300 2x clusters and galaxies
"

STUFF=()
#STUFF+=(a b c)
#STUFF+=(d e f)
#STUFF+=(\( mpr:XY -crop '3000x2001+0+491' -resize '1920x1024!>' +write bmp:-   \))
#STUFF+=(\( mpr:XY -crop '3100x2001+0+491' -resize '1920x1024!>' +write bmp:-   \))
#STUFF+=(\( mpr:XY -crop '3200x2001+0+491' -resize '1920x1024!>' +write bmp:-   \))
#STUFF+=(\( mpr:XY -crop '3300x2001+0+491' -resize '1920x1024!>' +write bmp:-   \))
		
#for x in {5000..5100}; do
#for x in {5000..5010}; do


step_size=2
exponent=1
max_steps=10000

# SIN_NOS=$(echo "
# define int(x) { 
# 	auto z; z = scale; scale = 0; x /= 1; scale = z; return x; }
# hpi = 2*a(1); 
# /* 
# debug:
# for (i=100; i<=250; i+=$step_size) { 
# */
# for (i=0*$max_steps/3; i<=$max_steps; i+=$step_size) { 
# 	int($max_steps*s(i*hpi/$max_steps)^$exponent) 
# }" | bc -l)

SECONDS_PAUSE=1

step_size=0.1
# step_size=0.02
# step_size=0.01
step_size=0.003
# Youtube 13 min: 0.005
# step_size=0.007
SECONDS_PAUSE=5

SIN_NOS=$(echo "
define int(x) { auto z; z = scale; scale = 0; x /= 1; scale = z; return x; } 
pi = 4*a(1); for (i=-pi/2; i<=pi/2; i+=$step_size) { 
    int($max_steps*(1+(s( i)))/2)
}" | bc -l)


IMG_ASPECT_H=$((IMG_W*1000/1778))
IMG_ASPECT_H_ADJ=$((IMG_ASPECT_H/2-IMG_H/2))
LEGEND_H=$((1920*IMG_H/IMG_W/4))

LAST_TARGET_X=0
LAST_TARGET_Y=0
LAST_BOX_W=$IMG_W
LAST_BOX_H=$IMG_ASPECT_H
LAST_X_OFFSET=0
LAST_H_OFFSET=0

LAST_DESC="Andromeda Galaxy (M31)"

COORDS_NUM=$(echo "$COORDS" | wc -l)
COORDS_CUR=0

SCRIPT_FILE="/dev/null"
SCRIPT_FILE="output.mgk"

> "$SCRIPT_FILE"

WRITE_STATEMENT="
        -depth 8
        +write rgb:- 
        "
        # -quality 1
        # +write png:- 
        # +write bmp:- 

# echo "$COORDS" \
#     | grep . \
while read TARGET_X TARGET_Y DESC; do
    echo ">>> TARGET_X TARGET_Y DESC = [$TARGET_X] [$TARGET_Y] [$DESC]"

    COORDS_CUR=$((COORDS_CUR+1))
    TARGET_BOX_W=1920
    TARGET_BOX_H=1080
    if [ $TARGET_X = 0 -a $TARGET_Y = 0 ]; then
        # shortcut to full view
        TARGET_BOX_W=$IMG_W
        TARGET_BOX_H=$IMG_ASPECT_H
        TARGET_L=0
        TARGET_H=0
    else
        TARGET_L=$((TARGET_X-1920/2))
        TARGET_H=$((TARGET_Y-1080/2+IMG_ASPECT_H_ADJ))
    fi

    # ZOOM_DIFF_W=$((LAST_BOX_W-1920))
    # ZOOM_DIFF_H=$((LAST_BOX_H-1080))
    ZOOM_DIFF_W=$((LAST_BOX_W-TARGET_BOX_W))
    ZOOM_DIFF_H=$((LAST_BOX_H-TARGET_BOX_H))


    last_step=-1
    # for cur_step in $SIN_NOS; do
    #debug:
    #for cur_step in {297..302}; do
    # for cur_step in $SIN_NOS {1000..1100}; do
    EXTRAFRAMES=$((SECONDS_PAUSE*30))



    for cur_step in $SIN_NOS $(seq $max_steps $((max_steps+EXTRAFRAMES))); do

        if [ "$DEBUG" = y -a "$cur_step" = "$last_step" ]; then
            continue
        fi

        # Maybe only when cur_step > max_steps to stop jerkiness?
        # if [ $cur_step -gt $max_steps -o "$cur_step" = "$last_step" ]; then
        if [ $cur_step -gt $max_steps ]; then
            cur_step=$max_steps
            # STUFF+=(
            #     \(
            #         mpr:last_img
            #         +write bmp:- 
            #         +delete 
            #     \)
            # )
            echo "
            \(
                mpr:last_img
                $WRITE_STATEMENT
                +delete 
            \)" | cat >> "$SCRIPT_FILE"
            continue
        fi

        if [ $cur_step -lt $((max_steps/2)) ]; then
            cur_desc="# $COORDS_CUR/$COORDS_NUM: $LAST_DESC @ ${LAST_TARGET_X}x${LAST_TARGET_Y}"
        else
            cur_desc="# $COORDS_CUR/$COORDS_NUM: $DESC @ ${TARGET_X}x${TARGET_Y}"
        fi


        x_offset=$((TARGET_L*cur_step/max_steps+LAST_X_OFFSET*(max_steps-cur_step)/max_steps))
        y_offset=$((TARGET_H*cur_step/max_steps+LAST_H_OFFSET*(max_steps-cur_step)/max_steps))
        # echo "$((TARGET_H*cur_step/max_steps))+$((LAST_H_OFFSET*(max_steps-cur_step)/max_steps))"
        box_w=$((TARGET_BOX_W+(max_steps-cur_step)*ZOOM_DIFF_W/max_steps))
        box_h=$((TARGET_BOX_H+(max_steps-cur_step)*ZOOM_DIFF_H/max_steps))
        x_offset_orig=$x_offset
        y_offset_orig=$y_offset
        box_w_orig=$box_w
        box_h_orig=$box_h
        PLUS=''
        if [ ${y_offset} -ge 0 ]; then
            PLUS='+'
        fi

        legend_l=$((1920-1920/4 + 1920/4 * x_offset/IMG_W))
        legend_t=$((0+LEGEND_H*(y_offset-IMG_ASPECT_H_ADJ)/IMG_H))
        legend_r=$((1920-1920/4 + 1920/4 * (x_offset+box_w)/IMG_W))
        legend_b=$((0+LEGEND_H*(y_offset+box_h-IMG_ASPECT_H_ADJ)/IMG_H))
        if [ $legend_t -lt 0 ]; then
            legend_t=1
        fi
        if [ $legend_b -gt $LEGEND_H ]; then
            legend_b=$((LEGEND_H-1))
        fi

        crop_box_orig="${box_w}x${box_h}^+${x_offset}${PLUS}${y_offset}"

        source='XY_canvas'
        crop_box="${box_w}x${box_h}^+${x_offset}${PLUS}${y_offset}"
        
        
        label="$cur_desc - $cur_step/$max_steps - $source - $crop_box"

        # Crop from quart image if size is too big. Limit seems to be > 30200x16900
        orig_msg=""
        if [ $box_w -gt $((IMG_W/4)) ]; then
            x_offset=$((x_offset/4))
            y_offset=$((y_offset/4))
            box_w=$((box_w/4))
            box_h=$((box_h/4))
            source='XY_quart'
            orig_msg=" (orig: $crop_box_orig)"
        fi

        crop_box="${box_w}x${box_h}^+${x_offset}${PLUS}${y_offset}"
        if [ "$DEBUG" = y ]; then
            label="$cur_desc - $cur_step/$max_steps - $source - $crop_box${orig_msg}"
        else
            label="$cur_desc"
        fi
        echo "proposed box source: $label - $cur_step/$max_steps - $source - $crop_box${orig_msg}"

        
        #STUFF+=(\( mpr:XY -crop "${x}x${x}+1920+1024" -resize '1920x1024!>' +write bmp:-   \))
        #echo "\( mpr:XY +repage -crop "1920x1024+${x}+${x}" -resize '1920x1024!>' +write bmp:-   \))"
        #STUFF+=(\( mpr:XY +repage -crop "1920x1024+${x}+${x}" -resize '1920x1024!>' +repage +write bmp:-   \))
        #STUFF+=(\( mpr:XY +repage -crop "1920x1024+${x}+${x}!" -resize '1920x1024!' +repage -gravity Center -pointsize 40 -fill "#f008" -draw "text 0,0 $x+$x" +write bmp:-   \))

        rect="rectangle $legend_l,$legend_t $legend_r,$legend_b"
        # rect="rectangle 50,50 100,100"
        # echo rect="$rect"
        # STUFF+=(
        # \( mpr:$source -crop "$crop_box" +repage -resize '1920x1080!' +repage
        # \( 
        #     mpr:XY_small \) 
        #     -compose over -layers merge
        #     +repage	
        #     -stroke white -fill white -undercolor "#0008" -annotate +10+10 "$label"
        #     +repage	
        #     -stroke red -strokewidth 1 -fill none -draw "$rect"
        #     +write mpr:last_img
        #     +delete 
        # \)
        # \(
        #     mpr:last_img
        #     +write bmp:- 
        #     +delete 
        # \)
        #debug:
        # +write "debug/pan_${cur_step}.jpg" +delete \)
        # )

        frame_file="$(printf "frames/frame-%03d-%06d-of-%06d.png" ${COORDS_CUR} ${cur_step} ${max_steps})"
        echo "
        \( mpr:$source -crop \"$crop_box\" +repage -resize '1920x1080!' +repage
        \( 
            mpr:XY_small \) 
            -compose over -layers merge
            +repage	
            -family 'Liberation Mono'
            -stroke white -fill white -undercolor '#0008' -annotate +10+10 \"$label\"
            +repage
            -stroke red -strokewidth 1 -fill none -draw \"$rect\"
            +write mpr:last_img
            +delete 
        \)
        \(
            mpr:last_img
            -write $frame_file
            $WRITE_STATEMENT
            +delete 
        \)" | cat >> "$SCRIPT_FILE"
            # +write bmp:- 
            # -write $frame_file


        last_step="$cur_step"
    done
    LAST_TARGET_X=$TARGET_X
    LAST_TARGET_Y=$TARGET_Y
    # Careful not to use the quarter scaled down version
    LAST_X_OFFSET=$x_offset_orig
    LAST_H_OFFSET=$y_offset_orig
    LAST_BOX_W=$box_w_orig
    LAST_BOX_H=$box_h_orig
    LAST_DESC="$DESC"

done <<< "$COORDS"



# echo STUFF= $STUFF
# echo STUFF= "${STUFF[*]}"
# echo STUFF= "${STUFF[@]}"
# exit
# echo "$SCRIPT_FILE"

for f in "${STUFF[*]}"; do
	#echo "double quote *: $f"
:
done

for f in "${STUFF[@]}"; do
	#echo "double quote @: $f"
:
done


:||"
	-stroke red -strokewidth 1 -fill none -draw "rectangle 1920 193,140"
	\( mpr:XY_small -repage +$((1920-1920/4))+0 -alpha set -channel A -evaluate set 60% \) -background None -composite
	-fill white -undercolor '#0008' -gravity South 
	-annotate +0+5 "x:$x y:$x crop:1920x1024+${x}+$((x-500))"  
		\( mpr:XY -crop '3000x2001+0+491' -resize '1920x1024!>' +write bmp:-   \) \
    \( mpr:XY -crop '3100x2001+0+491' -resize '1920x1024!>' +write bmp:-   \) \
    \( mpr:XY -crop '3200x2001+0+491' -resize '1920x1024!>' +write bmp:-   \) \
    \( mpr:XY -crop '3300x2001+0+491' -resize '1920x1024!>' +write bmp:-   \) \
exit 8
    half.jpg \
		${STUFF[*]} \



            # -write mpr:XY +delete \
        # "$FULL" \
        -limit area 1024MP \
        -debug cache \
"
# exit
# echo 'null:' >> "$SCRIPT_FILE"
{
        # -limit memory 12GB \
        # -limit map 12GB \
        # -limit area 1024MP \
        # -limit disk 12GB \
            # -gravity northwest +repage \
        # -verbose \
	# echo "${STUFF[@]}" | 

    FFMPEG_BANNER="-hide_banner"
    if [ "$DEBUG" = y ]; then
        FFMPEG_BANNER="hide_banner"
    fi
    
    $MAGICK \
            \( "$FULL" -gravity west -background black -extent "${IMG_W}x${IMG_ASPECT_H}" \
            -write mpr:XY_canvas +delete \) \
            -gravity northwest \
            \( mpr:XY_canvas -resize $((IMG_W/4)) \
            -write mpr:XY_quart +delete \) \
            \( "$FULL" -resize $((1920/4)) \
                -alpha set -channel A -evaluate set 80% -repage +$((1920-1920/4))+0 \
                -write mpr:XY_small +delete \) \
            -script "$SCRIPT_FILE" \
            null:
            # -script "-" \
                # <<
            # null:

            # +repage \
        

#	for i in {0..50}; do 
#		convert -size 100x60  xc:red BMP:-
#	done; 
#	for i in {0..30}; do 
#		convert -size 100x60 xc:blue BMP:-
#	done; 
#}

	# | tee output.raw \

} \
    | ffmpeg $FFMPEG_BANNER \
    -framerate 60 \
    -f rawvideo -pix_fmt rgb24 -s 1920x1080 -i - \
    -vf yadif,format=yuv420p -force_key_frames "expr:gte(t,n_forced/2)" -c:v libx264 \
    -crf 18 -bf 2 -c:a aac -q:a 1 -ac 2 -ar 48000 -use_editlist 0 -movflags +faststart \
    debug-output-01.mp4 \
    && /usr/bin/vlc ./debug-output-01.mp4

# next thing to try
# RGB:-
# | ffmpeg -s "$videoRes" -f rawvideo -pix\_fmt rgb24 -framerate "$frameRate" -i - "$outVideo"

# Youtube 
# ffmpeg -i in.mp4 -vf yadif,format=yuv420p -force_key_frames "expr:gte(t,n_forced/2)" -c:v libx264 -crf 18 -bf 2 -c:a aac -q:a 1 -ac 2 -ar 48000 -use_editlist 0 -movflags +faststart out.mp4

# -vf specifies video filters
# yadif will deinterlace videos if they're interlaced.
# format=yuv420p will produce pixel format with 4:2:0 chroma subsampling.
# -force_key_frames "expr:gte(t,n_forced/2)" will place keyframes every half-second, so that will be the GOP size.
# -c:v libx264 will use the x264 encoder to produce a H264 video stream.
# -crf 18 will produce a visually lossless file. Better than setting a bitrate manually.
# -bf 2 will limit consecutive B-frames to 2
# -c:a aac will use the native encoder to produce an AAC audio stream.
# -q:a 1 sets the highest quality for the audio. Better than setting a bitrate manually.
# -ac 2 rematrixes audio to stereo.
# -ar 48000 resamples audio to 48000 Hz.
# -use_editlist 0 avoids writing edit lists.
# -movflags +faststart places moov atom/box at front of the output file.


    # -profile:v high -preset slow -c:v libx264  -crf 18 -coder 1 -pix_fmt yuv420p -movflags +faststart -g 30 -bf 2 -c:a aac -b:a 384k -profile:a aac_low \

    #  \
    # && mv -vf ./debug-output-01.mp4 ./debug-output-01.mp4.bak

    # -filter_complex 'tmix=frames=1' \
    # | ffmpeg $FFMPEG_BANNER \
	# -i -  \
	# -f mjpeg \
	# - \


	# | /usr/bin/vlc --play-and-exit -

    # | ffmpeg $FFMPEG_BANNER \
	# -i -  \
    # -c:v libx264 -preset slow -profile:v high -crf 18 -coder 1 -pix_fmt yuv420p -movflags +faststart -g 30 -bf 2 -c:a aac -b:a 384k -profile:a aac_low \
    # -filter_complex 'tmix=frames=1' \
    # -r 24 -i -  \
	# -f mjpeg \
    # output.mp4
	# - \
	
    # output.mp4

    # -filter_complex 'tmix=frames=2' \
    # -filter_complex 'tmix=frames=2:weights="3 1"' \

    # -r 24 -i -  \
	# -f mjpeg \
	# - \
	# | /mnt/c/Program\ Files\ \(x86\)/VideoLAN/VLC/vlc.exe --play-and-exit -



:||"
} \
	| ffmpeg -hide_banner \
	-i -  \
    -c:v libx264 -preset slow -profile:v high -crf 18 -coder 1 -pix_fmt yuv420p -movflags +faststart -g 30 -bf 2 -c:a aac -b:a 384k -profile:a aac_low \
    output

	-f mjpeg -preset ultrafast -tune zerolatency \
	- \
	| cat > ~/Downloads/out.mkv 
	#| pv \
	#| /mnt/c/Program\ Files\ \(x86\)/VideoLAN/VLC/vlc.exe --play-and-exit -
"

exit 0

:||\
"""
# Youtube recommended
-c:v libx264 -preset slow -profile:v high -crf 18 -coder 1 -pix_fmt yuv420p -movflags +faststart -g 30 -bf 2 -c:a aac -b:a 384k -profile:a aac_low output



	-vf 'format=yuv420p' \
	-f matroska -preset ultrafast -tune zerolatency \
	-vf 'format=yuv420p' \
	| pv > ~/Downloads/out.mkv 
	-f matroska -preset ultrafast -tune zerolatency \
   -repage "${IMG_W}x${IMG_ASPECT_H}+0+$IMG_ASPECT_H_ADJ" -write mpr:XY +delete \
	| /mnt/c/Program\ Files\ \(x86\)/VideoLAN/VLC/vlc.exe --play-and-exit -
	-vf 'format=yuv420p' \
    - \
	-f matroska -preset ultrafast -tune zerolatency \
	-vf 'format=yuv420p' - \
| less
exit 8
     ( mpr:XY -crop '3200x2001+0+491' -resize '1920x1024!>' +write png:-   )
     ( mpr:XY -crop '3300x2001+0+491' -resize '1920x1024!>' +write png:-   )
	| ffmpeg -i - -f matroska - \
	| time ffmpeg -i - -vcodec h264 -f mpegts udp://127.0.0.1:23000
	| time ffmpeg -i - -vcodec h264 -f matroska - \
		-map '[2]' - \
	-vf \"
	scale=40000x10000,
		-f matroska - \
	
	;
	[out]
	scale=iw*4:ih*4
	,zoompan=z=zoom-0.05
	:x=(iw+iw*0.8)/2-(iw/zoom/2):y=(ih+ih*+0.2)/2-(ih/zoom/2)
	:s=1920x500:fps=30:d=300
	,drawtext=text='%{metadata\:lavf.cropdetect.x\:NA} %{metadata\:lavf.image2dec.source_basename\:NA} %{metadata\:zoom\:NA}'
	:[out2]
"""

