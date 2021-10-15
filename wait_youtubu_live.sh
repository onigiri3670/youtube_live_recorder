until /usr/local/bin/youtube-dl --hls-use-mpegts -o 'movie/%(title)s-%(id)s.%(ext)s' $1;
do
sleep 5;
continue;
done
cd movie
ls | grep -v part$ | xargs -I {}  /usr/local/bin/gdrive upload {} -p 1UMwCf6k3HYhZFQ36dTeRy8yhVKKVYEgP
