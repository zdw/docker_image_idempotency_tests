#!/usr/bin/env bash

docker rmi --force `docker images -q`
