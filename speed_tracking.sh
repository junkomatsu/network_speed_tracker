#!/bin/bash

INTERNET_SPEED_TARGET_URL="http://54.178.131.196/dummy_10M.img"
INTERNET_PING_TARGET_HOST="54.178.131.196"
LAN_SPEED_TARGET_URL="http://10.1.0.10/dummy_10M.img"
LAN_PING_TARGET_HOST="10.1.0.10"
TRACKER_URL="https://network-speed-tracker.herokuapp.com/tracks"
INTERVAL=600

username=`whoami`
hostname=$HOSTNAME
airport_cmd='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'

read -p "Please input your name ($username): " username_read
read -p "Please input your host name ($hostname): "  hostname_read
read -p "Please input your network or location information: " location_read

username="${username_read:-$username}"
hostname="${hostname_read:-$hostname}"
location="${location_read:-$location}"

echo "Start network speed tracking with interval : $INTERVAL"
while :
do
inet_speed=`curl -s -o /dev/null $INTERNET_SPEED_TARGET_URL  -w '%{speed_download}\n' | awk '{print ($1/1024/1024*8)}'`
inet_ping=`ping -c 10 $INTERNET_PING_TARGET_HOST | tail -1 |  awk '{print $4}'| cut -d '/' -f 2`
lan_speed=`curl -s -o /dev/null $LAN_SPEED_TARGET_URL  -w '%{speed_download}\n' | awk '{print ($1/1024/1024*8)}'`
lan_ping=`ping -c 10 $LAN_PING_TARGET_HOST | tail -1 |  awk '{print $4}'| cut -d '/' -f 2`

timestamp=`date "+%Y/%m/%d %T"`
ssid=`$airport_cmd -I | grep ' SSID' | awk -F ': ' '{print $2}'`
rssi=`$airport_cmd -I | grep 'agrCtlRSSI' | awk -F ': ' '{print $2}'`
noise=`$airport_cmd -I | grep 'agrCtlNoise' | awk -F ': ' '{print $2}'`
rate=`$airport_cmd -I | grep 'lastTxRate' | awk -F ': ' '{print $2}'`
max_rate=`$airport_cmd -I | grep 'maxRate' | awk -F ': ' '{print $2}'`

curl -s -o /dev/null --data-urlencode "track[timestamp]=$timestamp" \
                     --data-urlencode "track[username]=$username" \
                     --data-urlencode "track[hostname]=$hostname" \
                     --data-urlencode "track[location]=$location" \
                     --data-urlencode "track[ssid]=$ssid" \
                     --data-urlencode "track[rssi]=$rssi" \
                     --data-urlencode "track[noise]=$noise" \
                     --data-urlencode "track[max_rate]=$max_rate" \
                     --data-urlencode "track[rate]=$rate" \
                     --data-urlencode "track[inet_speed]=$inet_speed" \
                     --data-urlencode "track[inet_ping]=$inet_ping" \
                     --data-urlencode "track[lan_speed]=$lan_speed" \
                     --data-urlencode "track[lan_ping]=$lan_ping" \
                     $TRACKER_URL
echo "$timestamp $username@$hostname on $location ($ssid / rssi:$rssi / noise:$noise / rate:${rate}Mbps) inet : ${inet_speed}Mbps / ${inet_ping}ms, lan : ${lan_speed}Mbps / ${lan_ping}ms"
sleep $INTERVAL
done
