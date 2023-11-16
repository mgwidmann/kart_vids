#!/bin/bash

# To use run ./snapshot_prod.sh first to download restore file
#   ./restore_local.sh kart-vids-prod-2023-10-24_20:56:06.sql

file=$1

if [[ -z "$file" ]]; then
    echo "Must provide file argument to restore!" 1>&2
    exit 1
fi

mix ecto.drop
mix ecto.setup

echo Restoring $file...
psql -U postgres -W -h localhost -p 5432 -d kart_vids_dev -f $file

echo "Run the following commands to update the local user's password since the salts are different:"
echo "    import Ecto.Query"
echo "    password = Bcrypt.hash_pwd_salt(\"password\")"
echo "    from(u in User, where: u.id == 1) |> Repo.update_all(set: [email: "admin@kart-vids.com", hashed_password: password])"