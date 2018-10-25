#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ -z "$1" ] ; then 
	printf "$GREEN Usage 1: `basename $0` feature/KND-1234 [source-db] \nsource_db is knd_uat by default $NC \n" ; 
	printf "$GREEN Usage 2: `basename $0` feature/KND-1234 feature/KND-1111 $NC " ; 
	exit 1 ; 
fi
IFS=/ read TICKET_TYPE TICKET_NUMBER <<< $(echo $1| tr '[:upper:]' '[:lower:]')

DOCKERNAME=$TICKET_TYPE$TICKET_NUMBER"_knd_1"
TARGET_DB="knd_$TICKET_TYPE"$(echo $TICKET_NUMBER | sed "s/-//")
POSTGRES_DOCKERNAME=knd-postgres
SSH_HOST=knd

if [ -z "$2" ] ; then 
	SOURCE_DB=knd_uat;
else 
	if [[ $(echo $2 | grep "\/") ]] ; then
		IFS=/ read SOURCE_TICKET_TYPE SOURCE_TICKET_NUMBER <<< $(echo $2| tr '[:upper:]' '[:lower:]')
		SOURCE_DB="knd_$SOURCE_TICKET_TYPE"$(echo $SOURCE_TICKET_NUMBER | sed "s/-//")
	else
		SOURCE_DB=$(echo $2 | tr '[:upper:]' '[:lower:]');
	fi
fi


printf "$GREEN Stopping container $DOCKERNAME $NC "
ssh $SSH_HOST docker stop $DOCKERNAME && \

printf "$GREEN Copying $SOURCE_DB to $TARGET_DB $NC " && \
./clone-database.sh $TARGET_DB $SOURCE_DB $POSTGRES_DOCKERNAME $SSH_HOST && \

printf "$GREEN Starting container $DOCKERNAME $NC " && \
ssh $SSH_HOST docker start $DOCKERNAME && \
ssh $SSH_HOST docker logs -f $DOCKERNAME || \
printf "$RED Something went wrong $NC"
