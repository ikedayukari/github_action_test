#!/usr/bin/env bash

if [ -z "${MESSAGE}" ]; then
   exit 0
fi

curl -s -X POST "https://api.chatwork.com/v2/rooms/${ROOM_ID}/messages" \
    -H "X-ChatWorkToken: ${ABCDEF}" \
    -d "body=${MESSAGE}"
