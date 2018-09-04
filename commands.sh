#!/bin/bash

source "func.sh"

case $bot_message_text in
    's/'*|'s#'*|'y/'*)
        [[ "$bot_reply_id" != 'null' ]] && {
            text=$(echo -e "$bot_reply_text" | timeout 0.1s sed --sandbox "$bot_message_text")
            send $bot_chat_id "$text"
        }
    ;;

    '/ping')
        send $bot_chat_id "pong"
    ;;

    'alias '*)
        bot_message_text="${bot_message_text//;}"
        case $bot_message_text in
            'alias -a '*)
                [[ "$bot_reply_id" != 'null' ]] && {
                    bot_message_text="${bot_message_text:9}"
                    [[ $bot_message_text =~ ^[[:alnum:]]+$ ]] && [[ ! "$(sqlite3 bot_db <<< "select chat_id from alias where name = '"$bot_message_text"';")" ]] && {
                        sqlite3 bot_db <<< "insert into alias values('"$bot_message_text"', $bot_user_id, $bot_chat_id, $bot_reply_id);"
                        bot_message_text='Alias created'
                    } || bot_message_text='Alias already exists or name contains non-alphanumeric characters.'
                } || bot_message_text='No reply message.'
                reply_send $bot_chat_id $bot_reply_id "$bot_message_text"
            ;;
            'alias -l'*)
                send $bot_chat_id $(sqlite3 bot_db <<< "select name from alias;" | tr '\n' ' ')
            ;;
            'alias -r '*)
                bot_message_text="${bot_message_text:9}"
                bot_user_id="$(echo "$updates" | jq ".result[$i].message.from.id")"
                [[ "$(sqlite3 bot_db <<< "select user_id from alias where name = '"$bot_message_text"';")" == "$bot_user_id" ]] && {
                    sqlite3 bot_db <<< "delete from alias where name = '"$bot_message_text"';"
                    response='Alias deleted.'
                } || response="Alias doesn't exist or you do not own it."
                send $bot_chat_id "$response"
            ;;
            *)
                bot_message_text="${bot_message_text:6}"
                [[ "$(sqlite3 bot_db <<< "select name from alias where name = '"$bot_message_text"';")" ]] && {
                    from_chat_id=$(sqlite3 bot_db <<< "select chat_id from alias where name = '"$bot_message_text"';")
                    message_id=$(sqlite3 bot_db <<< "select reply_id from alias where name = '"$bot_message_text"';")
                    forwardMessage $bot_chat_id $from_chat_id $message_id
                }
            ;;
        esac
    ;;
esac