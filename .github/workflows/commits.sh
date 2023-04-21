#!/usr/bin/env bash

before_id=${BEFORE_ID}
messages=$(echo "${COMMITS}" | jq -r '
    (.[] | [.message, .author.name, .timestamp, .id, .url])
    | @tsv
' | 
{
    while IFS=$'\t' read -r message name timestamp id url; do
        parent_count=git cat-file -p "${id}" | grep -c '^parent'
        if [ 1 -lt "$(parent_count)" ]; then
            continue
        fi
        added_files=$(git diff --diff-filter=A --name-only "${before_id}".."${id}" ':!/ignore_directory/*' | sed "s/^/added：/g")
        removed_files=$(git diff --diff-filter=R --name-only "${before_id}".."${id}" ':!/ignore_directory/*' | sed "s/^/removed：/g")
        modified_files=$(git diff --diff-filter=M --name-only "${before_id}".."${id}" ':!/ignore_directory/*' | sed "s/^/modified：/g")
        printf "[info][title]%s\n%s(%s)[/title]%s\n%s\n%s[hr]%s[/info]\n" "$message" "$name" "$timestamp" "$added_files" "$removed_files" "$modified_files" "$url"
        before_id=${id}
    done
})
echo "${messages}"