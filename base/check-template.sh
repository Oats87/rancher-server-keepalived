#!/bin/sh
if [[ `curl -k --resolve {{ RANCHER_HOSTNAME }}:443:127.0.0.1 https://{{ RANCHER_HOSTNAME }}/ping` = 'pong' ]]; then
    exit 0
fi

exit 1
