#!/usr/bin/env bash

CFKEY=
CFUSER=example@example.com
CFRECORD_TYPE=AAAA
CFTTL=1
CFRECORD_NAME=(example1 example2 example3)
CFZONE_NAME=example.com
CFZONE_ID=

CURRENT_IP=`curl -s https://ipv6.icanhazip.com`

if [ $CURRENT_IP == `cat $HOME/CURRENT_RESOLVE.txt` ]; then
    echo 'No change detected since last run, exiting...'
    exit 0
else
    for RECORD in ${CFRECORD_NAME[*]}
        do
        RECORD=$RECORD.$CFZONE_NAME
        CFRECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CFZONE_ID/dns_records?name=$RECORD" -H "X-Auth-Email: $CFUSER" -H "X-Auth-Key: $CFKEY" -H "Content-Type: application/json"  | grep -Po '(?<="id": ")[^"]*' )

        RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$CFZONE_ID/dns_records/$CFRECORD_ID" \
        -H "X-Auth-Email: $CFUSER" \
        -H "X-Auth-Key: $CFKEY" \
        -H "Content-Type: application/json" \
        --data "{\"id\":\"$CFZONE_ID\",\"type\":\"$CFRECORD_TYPE\",\"name\":\"$RECORD\",\"content\":\"$CURRENT_IP\", \"ttl\":$CFTTL}"

        echo $RECORD Synced Successfully.
        done

        echo $CURRENT_IP > $HOME/CURRENT_RESOLVE.txt
fi
