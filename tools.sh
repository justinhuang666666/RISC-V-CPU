#!/bin/bash

touch "$HOME/.docker_bash_history"
docker run -it --platform linux/amd64 -v "$(pwd):/code/cpu" -v "$HOME/.docker_bash_history:/root/.bash_history" ghcr.io/iac-reshaping/docker/builder:v1.0.0
