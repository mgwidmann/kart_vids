#!/bin/bash

file=$1

if [[ -z "$file" ]]; then
    echo "Must provide file argument to restore!" 1>&2
    exit 1
fi

mix ecto.drop
mix ecto.setup

echo Restoring $file...
psql -U postgres -W -h localhost -p 5432 -d kart_vids_dev -f $file