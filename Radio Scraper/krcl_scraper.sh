#!/bin/bash

# file systems don't like using colons as characters. UTC guarantees all data
# corresponds to the same time.
CURRENT_TIME=$(date +"%Y-%m-%d_%H_%M")

mkdir "${CURRENT_TIME}"
cd "${CURRENT_TIME}"

# Get the data stream. Currently outputs to output.mp3 and lasts for five seconds. 
curl -s --output "${CURRENT_TIME}".mp3 --max-time 5 https://stream.xmission.com/krcl-high

# Get the playlist. It holds data such as artist, album, and album cover.
# Could be more efficient.
wget https://krcl.org/playlist/ -qO playlist.html

# The link for the album artwork
# Should we save this image itself, or keep the link and then download what we need?
ALBUM_ART=$(grep -m 1 -oP '<img class="album-cover" src="\K[^"]*' playlist.html)
if [ "$ALBUM_ART" == '/static/images/blank-album.png' ]; then 
  ALBUM_ART="https://krcl.org/static/images/blank-album.png"
fi

# Get the album artwork.
EXT="${ALBUM_ART##*.}"
wget $ALBUM_ART -qO album_art
mv album_art "${CURRENT_TIME}.${EXT}"


# Get the artist, the song, and the album.
grep -m 1 -A 2 -P '<div class="playlistitem-name">' playlist.html | tail -n 2 > temp.txt

ARTIST=$(grep -oP '<h3><b>\K.*?(?=<)' temp.txt | recode html..ascii)
SONG=$(grep -oP '</b>.*?(?=<)' temp.txt | cut -c 8- | recode html..ascii)
ALBUM=$(grep -oP '<h3>.*?(?=<)' temp.txt | sed -n '2 p' | cut -c 5- | recode html..ascii)

echo ${ARTIST}    >  "${CURRENT_TIME}".txt
echo ${ALBUM}     >> "${CURRENT_TIME}".txt
echo ${SONG}      >> "${CURRENT_TIME}".txt
echo ${ALBUM_ART} >> "${CURRENT_TIME}".txt

rm temp.txt
rm playlist.html

