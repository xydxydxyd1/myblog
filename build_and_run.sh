#!/bin/bash
# build_and_run.sh 
#
while getopts "" opt; do
    case $opt in
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    ;;
    esac
done
if [[ "$#" -ne 0 ]]; then
    echo "Illegal number of parameters" >&2
    exit 1
fi

IMG_NAME='myblog'
CONTAINER_NAME="${IMG_NAME}_running"
HOST_PORT='4000'

docker remove "$CONTAINER_NAME"
docker build -t "$IMG_NAME" .
#docker run --name "$CONTAINTER_NAME" "$IMG_NAME"
docker run -it -t \
    -p 127.0.0.1:$HOST_PORT:4000 \
    --name "$CONTAINTER_NAME" "$IMG_NAME"
