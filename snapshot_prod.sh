#!/bin/bash

export pg_user=postgres
export pg_database=kart_vids
export pg_host=localhost
export pg_port=5433

export dt=$(date +"%Y-%m-%d_%H:%M:%S")

echo Dumping from prod database...

pg_dump -U $pg_user -d $pg_database -h $pg_host -p $pg_port --format=plain --no-owner --no-privileges --no-acl --data-only --column-inserts > kart-vids-prod-$dt.sql