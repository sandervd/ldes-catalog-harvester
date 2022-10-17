#!/bin/bash -e
encoded=$(echo "$2" | perl -MURI::Escape -wlne 'print uri_escape $_')
echo -e "$1" > catalogs/$encoded
