#!/usr/bin/env bash

# Ensure this happens after /sbin/init
( sleep 5 ; /etc/init.d/sshd restart ) &
# Needs to start as PID 1 for openrc on alpine

exec -c /sbin/init 
#exec /usr/sbin/sshd -D -e "${@}"

node /code/server.js