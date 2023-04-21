#!/usr/bin/env bash

before_id=${BEFORE_ID}
messages=$(echo "${COMMITS}" | jq -r '
    (.[] | [.message, .author.name, .timestamp, .id, .url])
    | @tsv
' | 
{
    while IFS=$'\t' read -r message name timestamp id url; do
        modified_files=$(git diff --diff-filter=M --name-only "${before_id}".."${id}" | sed "s/^/Added：/g")
        echo "${modified_files}"
        printf "[info][title]%s\n%s(%s)[/title]FILE_LIST[hr]%s[/info]\n" "$message" "$name" "$timestamp" "$url"
        before_id=${id}
    done
})
echo "${messages}"