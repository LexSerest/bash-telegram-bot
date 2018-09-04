function escape(){
    tr "'" '"' | sed --sandbox 's#\\"#"#g;s#\\\\#\\#g;s/^"//;s/"$//'
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

function forwardMessage(){
    curl -s "$BOT_API_URL/forwardMessage" \
        --data-urlencode "chat_id=$1" \
        --data-urlencode "from_chat_id=$2" \
        --data-urlencode "message_id=$3" >> /dev/null
}