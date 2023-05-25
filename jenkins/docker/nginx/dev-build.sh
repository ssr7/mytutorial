#!/bin/bash

docker cp nginx/dev.nginx.conf dev-docker-runner:/root/nginx/nginx.conf
docker cp nginx/acm.proxy.conf dev-docker-runner:/root/nginx/
docker cp nginx/docker-compose.yml dev-docker-runner:/root/nginx/


docker cp nginx/stg.nginx.conf stg-docker-runner:/root/nginx/nginx.conf
docker cp nginx/acm.proxy.conf stg-docker-runner:/root/nginx/
docker cp nginx/docker-compose.yml stg-docker-runner:/root/nginx/


docker cp nginx/prd.nginx.conf prd-docker-runner:/root/nginx/nginx.conf
docker cp nginx/acm.proxy.conf prd-docker-runner:/root/nginx/
docker cp nginx/docker-compose.yml prd-docker-runner:/root/nginx/

docker exec dev-docker-runner docker-compose up -f /root/nginx/docker-compose.yml -d 
