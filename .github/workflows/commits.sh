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
        files="$( ( 
                (git diff --diff-filter=A --name-only "$parent_id".."$id" ':!/ignore_directory/*' | sed 's/^/added : /g')
                (git diff --diff-filter=D --name-only "$parent_id".."$id" ':!/ignore_directory/*' | sed 's/^/removed : /g')
                (git diff --diff-filter=M --name-only "$parent_id".."$id" ':!/ignore_directory/*' | sed 's/^/modified : /g')
                (git diff --diff-filter=R --name-only "$parent_id".."$id" ':!/ignore_directory/*' | sed 's/^/renamed : /g')
                (git diff --diff-filter=C --name-only "$parent_id".."$id" ':!/ignore_directory/*' | sed 's/^/copied : /g')
            ) | sed '/^$/d')"
        printf "[info][title]%s\n%s(%s)[/title]%s[hr]%s[/info]\n" "$message" "$name" "$timestamp" "$files" "$url"
    done
})

delimiter="EOF$(openssl rand -hex 8)"
{
  echo "message<<$delimiter"
  echo "$message"
  echo "$delimiter"
} >> "$GITHUB_OUTPUT"
