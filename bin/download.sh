#!/bin/bash -e
filename=${1%}
filename=${filename##*/}
catalog_url=$(echo "$filename" | perl -pe 's/\%(\w\w)/chr hex $1/ge')
path="workspace/dcat/$filename/original"
curl -s -o "$path" -z "$path" "$catalog_url"
