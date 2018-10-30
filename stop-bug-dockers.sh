#!/bin/bash
for dockername in $( docker ps | grep -Po '\S*$' | grep  -P '\d{3,4}'); do
	docker stop $dockername
done
