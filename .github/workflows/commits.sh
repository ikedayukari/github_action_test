#!/usr/bin/env bash

message=$(echo "$COMMITS" | jq -r '
    (.[] | [.message, .author.name, .timestamp, .id, .url])
    | @tsv
' | 
{
    while IFS=$'\t' read -r message name timestamp id url; do
        parent_id=$(git cat-file -p "$id" | grep '^parent' | sed 's/^parent //g')
        parent_count=$(echo "$parent_id" | grep -c '')
        if [ 1 -lt "$parent_count" ]; then
            continue
        fi
        added_files=$(git diff --diff-filter=A --name-only "$parent_id".."$id" ':!/ignore_directory/*' | sed 's/^/added:/g')
        removed_files=$(git diff --diff-filter=D --name-only "$parent_id".."$id" ':!/ignore_directory/*' | sed 's/^/removed:/g')
        modified_files=$(git diff --diff-filter=M --name-only "$parent_id".."$id" ':!/ignore_directory/*' | sed 's/^/modified:/g')
        printf "[info][title]%s\n%s(%s)[/title]%s%s%s[hr]%s[/info]\n" "$message" "$name" "$timestamp" "$added_files" "$removed_files" "$modified_files" "$url"
    done
})

delimiter="EOF$(openssl rand -hex 8)"
{
  echo "message<<$delimiter"
  echo "$message"
  echo "$delimiter"
} >> "$GITHUB_OUTPUT"
