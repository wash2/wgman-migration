#!/bin/bash

while read -r line; do export  "$line"; done < "../env.list"
echo $WGMAN_DB_PW
docker stop "$WGMAN_DB_CONTAINER_NAME" ;
docker rm "$WGMAN_DB_CONTAINER_NAME" ;
docker run -d --name "$WGMAN_DB_CONTAINER_NAME" -e POSTGRES_USER="$WGMAN_DB_USER" -e POSTGRES_PASSWORD="$WGMAN_DB_PW" -e POSTGRES_DB="$WGMAN_DB_NAME" -p $WGMAN_DB_PORT postgres
db_ip="$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $WGMAN_DB_CONTAINER_NAME)"
WGMAN_DB_HOST="$db_ip"
echo "$db_ip"
cargo run
