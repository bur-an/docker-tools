#!/bin/bash
# from https://gist.github.com/mostafar/116a0cb79005955476b24c0960b72d5a/
IFS=$'\n\t'
set -euox pipefail


CNAME="$1"
FILE_PATH="$2"

FILE_NAME="$(basename "$FILE_PATH")"
TMPFILE="$(mktemp --suffix=_$FILE_NAME)"
docker exec "$CNAME" cat "$FILE_PATH" > "$TMPFILE"
hashsum=$(md5sum $TMPFILE | cut -d ' ' -f 1)
$EDITOR "$TMPFILE"
if [ $hashsum != $(md5sum $TMPFILE | cut -d ' ' -f 1) ]; then
	# upload only if modified
	cat "$TMPFILE" | docker exec -i "$CNAME" sh -c 'cat > '"$FILE_PATH"
fi
# rm "$TMPFILE"
