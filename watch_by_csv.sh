#!/bin/bash
#set -x


#kill -9 `ps -adef | grep qemuaarch | grep $PORT | awk '{printf $2" "}'`
#sop://broker.sopcast.com:3912/258825

# Some basic sanity check for the URL
game=$1
game_sop_num=1

line=`grep ^$game /srv/http/sopcast/sopcast_file.csv | tr "," " "`
eval "arr=($line)"
game_titel=${arr[1]}

if [ -f /srv/http/sopcast/sopcast_playing.csv ]; then 
  game_sop_num=$(cat /srv/http/sopcast/sopcast_playing.csv | wc -l)
  let "game_sop_num++"
  else
  \rm -rf /srv/http/sopcast/*.m3u
fi

FILE=/srv/http/sopcast/sopcast_playing.csv    
if [ -f $FILE ]; then
 line2=`grep $game_titel $FILE | tr "," " "`
 cat $FILE > /srv/http/sopcast/sopcast_playing.csv.tmp
 eval "is_playing_arr=($line2)"
 if [[ ${#is_playing_arr[@]} > 0 ]]; then
  PORT=${is_playing_arr[3]}
  sop_num=${is_playing_arr[2]}
  let "sop_num++"
  game_sop_num=${is_playing_arr[0]}
  grep -vw $game_titel $FILE > /srv/http/sopcast/sopcast_playing.csv.tmp
  fi
fi

if  [[ "$PORT" == '' ]]; then 
 PORT=$((game_sop_num+1000))  
fi

if  [[ "$sop_num" == '' ]]; then 
 sop_num=1
fi


URL=${arr[$sop_num+1]}
if  [[ "$URL" == '' ]]; then 
sop_num=1
URL=${arr[$sop_num+1]}
fi


 echo "$game_sop_num,$game_titel,$sop_num,$PORT" > $FILE
 
 if [ -f /srv/http/sopcast/sopcast_playing.csv.tmp ]; then 
  cat /srv/http/sopcast/sopcast_playing.csv.tmp >> $FILE
 fi



# Make sure local port is not in use
# netstat -vant | grep $PORT | grep -q LISTEN && { let "PORT++" ; }
# add locale libstdc++.so.5
cd $(dirname $0)
export LD_LIBRARY_PATH=$(pwd)
M3UFILE='/srv/http/sopcast/'$game_titel'.m3u'
LOGO='"http://icons.iconarchive.com/icons/yingfengling-fl/i-love-sports/256/soccer-icon.png"'
MYIP="http://yourip"
echo '#EXTINF:-1 tvg-id="" tvg-name="" tvg-logo='$LOGO' group-title="ספורט",'$game_titel > $M3UFILE
echo '#EXTVLCOPT:network-caching=2000' >> $M3UFILE
echo  $MYIP':'$PORT'/tv.ts' >> $M3UFILE

echo "#EXTM3U" > /srv/http/sopcast/live.m3u
echo "" >> /srv/http/sopcast/live.m3u
cat /srv/http/sopcast/*_*.m3u >> /srv/http/sopcast/live.m3u

upnpc -e 'live games' -r $PORT TCP

kill -9 `ps -adef | grep qemuaarch | grep $PORT | awk '{printf $2" "}'`
/opt/sopcast/qemuaarch-i386 lib/ld-linux.so.2 --library-path /opt/sopcast/lib /opt/sopcast/sp-sc-auth -u ezradnd@walla.com:topgan12 $URL 3908 $PORT >/dev/null &
_PID=$!

\rm -rf /srv/http/sopcast/sopcast_playing.csv.tmp
