#!/bin/bash

export BOT_API_URL="https://api.telegram.org/bot$BOT_TOKEN"

[[ ! -f bot_db ]] && sqlite3 bot_db <<< 'create table alias(name varchar(10), user_id smallint, chat_id smallint, reply_id smallint);'
export bot_db

source "func.sh"

last_id=0
updates=$(curl -s "$BOT_API_URL/getUpdates" --data-urlencode "timeout=60")
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
        export bot_user_id="$(echo "$updates" | jq ".result[$i].message.from.id")"
        export bot_chat_id="$(echo "$updates" | jq ".result[$i].message.chat.id")"
        export bot_reply_id="$(echo "$updates" | jq ".result[$i].message.reply_to_message.message_id")"
        export bot_reply_text="$(echo "$updates" | jq ".result[$i].message.reply_to_message.text" | escape )"
        export bot_message_text="$(echo "$updates" | jq ".result[$i].message.text" | escape )"
        ./commands.sh & # for multithreading
    }

    sleep 0.3
done
