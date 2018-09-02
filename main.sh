#!/bin/bash

export BOT_API_URL="https://api.telegram.org/bot$BOT_TOKEN"
last_id=0

function escape(){
 tr -s "'" '"' | sed --sandbox 's#\\"#"#g;s#\\\\#\\#g;s/^"//;s/"$//'
}

function reply_send(){
    curl -s "$BOT_API_URL/sendMessage" \
    --data-urlencode "chat_id=$1" \
    --data-urlencode "reply_to_message_id=$2" \
    --data-urlencode "text=$3" >> /dev/null
}

function send(){
    curl -s "$BOT_API_URL/sendMessage" \
    --data-urlencode "chat_id=$1" \
    --data-urlencode "text=$2" >> /dev/null
}

export -f escape
export -f reply_send
export -f send

updates=$(curl -s "$BOT_API_URL/getUpdates" \
        --data-urlencode "timeout=60")

while true; do
    updates=$(curl -s "$BOT_API_URL/getUpdates" \
        --data-urlencode "offset=$(( $last_id + 1 ))" \
        --data-urlencode "timeout=60")
    updates_count=$(echo "$updates" | jq -r ".result | length")


    if [ -z $updates_count ] ; then 
        updates_count=0
    fi

    last_id=$(echo "$updates" | jq -r ".result[$(( "$updates_count" - 1 ))].update_id")
    for ((i=0; i<$updates_count; i++)); {
        export chat_id="$(echo "$updates" | jq ".result[$i].message.chat.id")"
        export reply_id="$(echo "$updates" | jq ".result[$i].message.reply_to_message.message_id")"
        export reply_text="$(echo "$updates" | jq ".result[$i].message.reply_to_message.text" | escape )"
        export message_text="$(echo "$updates" | jq ".result[$i].message.text" | escape )"
        ./commands.sh & # for multithreading
    }

    sleep 0.3
done
