#!/bin/bash

case $message_text in
	's/'*|[[:digit:]]'s#'*|[[:digit:]]'y/'*)
		text=$(echo -e "$reply_text" | timeout 0.1s sed --sandbox "$message_text")
		send $chat_id "$text"
	;;

	'/ping')
		send $chat_id "pong"
	;;
esac