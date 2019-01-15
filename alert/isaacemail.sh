#!/usr/bin/env bash

alert_lev="$1"
alert_msg="$2"

if [[ -z "$alert_lev" || -z "$alert_msg" ]]
then
    echo "Invalid use. Requires 1=alert_lev 2=alert_msg"
    exit 1
fi

if [[ $alert_lev -gt 0 ]]; then
    echo "$alert_msg" | email --username "isaacsclassicsupervisor@gmail.com" --from "Isaac's ETC Supervisor <isaacsclassicsupervisor@gmail.com>" --subject "[ETC-supervisor][$alert_lev-alert]" --cc isaacsclassicsupervisor@gmail.com rotblauer@gmail.com
fi
