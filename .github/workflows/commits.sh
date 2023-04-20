#!/usr/bin/env bash

messages=$(jq -r '
    (.[] | [.message, .author.name, .timestamp, .url])
    | @tsv
' "${COMMITS}" | 
{
    while IFS=$'\t' read -r message name timestamp url; do
          printf "[info][title]%s\n%s(%s)[/title]FILE_LIST[hr]%s[/info]\n" "$message" "$name" "$timestamp" "$url"
    done
})
echo "${messages}"