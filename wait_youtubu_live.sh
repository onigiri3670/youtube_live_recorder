until /usr/local/bin/youtube-dl --hls-use-mpegts -o 'movie/%(title)s-%(id)s.%(ext)s' $1;
do
sleep 5;
continue;
done
cd movie
ls | grep -v part$ | xargs -I {} /bin/bash -c '/usr/local/bin/gdrive upload "{}" && rm "{}"'
