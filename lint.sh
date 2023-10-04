#!/bin/bash

FILES=$(git diff --name-only --cached | grep '\.sh$' | sed -e 's/^/.\//' | tr '\n' ' ')

eval "docker run --rm -v '${PWD}:/mnt' koalaman/shellcheck:stable --shell=bash -a -x ${FILES}"