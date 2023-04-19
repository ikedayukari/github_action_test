#!/usr/bin/env bash

curl -s -X POST "https://api.chatwork.com/v2/rooms/${ROOM_ID}/messages" \
    -H "X-ChatWorkToken: ${ABCDEF}" \
    -d @- <<EOS
body=[info][title]${MESSAGE}
${AUTHOR}(${TIMESTAMP})[/title]
FILE_LIST[/info]
EOS