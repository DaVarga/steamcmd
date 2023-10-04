#!/bin/bash

source ./local-vars.sh

# Remove cache from compose-file since some images are private which leads to errors.
# There might be a more elegant solution to this.
TMP_COMPOSE=$(docker run -i --rm mikefarah/yq eval '(del(.services.[].build.cache_from))' < docker-compose.yml)

export DOCKER_BUILDKIT=1 
export BUILDKIT_INLINE_CACHE=1

# Build base images before production images
docker buildx bake -f /dev/stdin base-soldier base-sniper <<< "${TMP_COMPOSE}"
docker buildx bake -f /dev/stdin src2 csgo hlds srcds <<< "${TMP_COMPOSE}"

