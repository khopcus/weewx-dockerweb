#!/bin/bash

set -ex
# SET THE FOLLOWING VARIABLES
# docker hub username
USERNAME=khopcuskmf
# image name
IMAGE=weewx-dockerweb

docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t $USERNAME/$IMAGE:latest .