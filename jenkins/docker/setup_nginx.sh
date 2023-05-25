#!/bin/bash
for cnt in 'dev-docker-runner' 'stg-docker-runner' 'prd-docker-runner'; do 
	echo "setup: $cnt"
	docker exec  $cnt mkdir /root/nginx/
	docker cp nginx/dev.nginx.conf $cnt:/root/nginx/nginx.conf && docker cp nginx/conf.d $cnt:/root/nginx/ && docker cp nginx/docker-compose.yml $cnt:/root/nginx/
        docker exec $cnt docker compose -f  /root/nginx/docker-compose.yml  up -d 
        docker exec $cnt docker exec nginx nginx -s reload


done 
