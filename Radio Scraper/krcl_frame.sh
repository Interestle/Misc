#!/bin/bash

#convert -size 512x512 xc:white blank.png

for dir in */; do
    TIME=${dir:0:16}
    YEAR=${dir:0:4}
    MONTH=${dir:5:2}
    DAY=${dir:8:2}
    HOUR=${dir:11:2}
    MINUTE=${dir:14:2}
   
    cd "$dir"   

    ARTIST=$(sed '1!d' "${TIME}.txt")
    ALBUM=$(sed '2!d' "${TIME}.txt")
    SONG=$(sed '3!d' "${TIME}.txt")
    ALBUM_ART=$(sed '4!d' "${TIME}.txt")

    ART_EXT="${ALBUM_ART##*.}"
   
    # Just make sure everything will work out. 
    convert "${TIME}.${ART_EXT}" -resize 170x170 tesr.png

    # Find the dominant color in the image for a background
    COLOR=$(convert "${TIME}.${ART_EXT}" -resize 1x1\! -format "%[fx:int(255*r+.5)],%[fx:int(255*g+.5)],%[fx:int(255*b+.5)]" info:-)
   
    convert -size 512x512 xc:rgb\("${COLOR}"\) background.png 

    # Add everything to one image.
    convert background.png tesr.png -geometry +50+50 -composite \
        -background none -pointsize 24 -size 250x75 caption:"Artist: ${ARTIST}" -geometry +250+50 -compose over -composite \
        -background none -pointsize 24 -size 250x75 caption:"Song: ${SONG}" -geometry +250+125 -compose over -composite \
        -background none -pointsize 24 -size 250x75 caption:"Album: ${ALBUM}" -geometry +250+200 -compose over -composite  \
        -background none -pointsize 24 -size 500x75 caption:"Collected on: ${MONTH}/${DAY}/${YEAR} at ${HOUR}:${MINUTE}" -geometry +50+400 -compose over -composite output.png
       
  
    
    # Where I've been currently storing all of my frames.
    mv output.png ../../krcl_frames/"${TIME}.png"

    rm tesr.png
    rm background.png

    cd ..
  
done
