#!/bin/bash

export DOCKER_BUILDKIT=1
export DOCKER_PROJECT_NAME=steamcmd
export DOCKER_ORG_NAME=thetredev
export DOCKER_REGISTRY_NAME=ghcr.io

export DOCKER_REPO_NAMESPACE=${DOCKER_ORG_NAME}/${DOCKER_PROJECT_NAME}
export DOCKER_IMG=${DOCKER_REGISTRY_NAME}/${DOCKER_REPO_NAMESPACE}
