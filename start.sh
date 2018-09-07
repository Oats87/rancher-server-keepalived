#!/bin/bash

function cleanup() {
  echo "Cleaning up and removing VIP"
  [ -n "$1" ] && kill -TERM $1

  local interface=$IFACE
  local vip=$VIP
  echo "Removing VIP ${vip} from interface ${interface}"

  local regex='^.*?/[0-9]+$'

  if [[ ${vip} =~ ${regex} ]] ; then
    ip addr del ${vip} dev ${interface} || :
  else
    ip addr del ${vip}/32 dev ${interface} || :
  fi

  exit 0
}

function setup_failover() {
  modprobe ip_vs

  echo "Checking for ip_vs"
  if lsmod | grep '^ip_vs'; then
    echo "ip_vs is loaded"
  else
    echo "ip_vs is not available"
  fi
}

function render_config() {
    cp /keepalived/base/keepalived.conf /keepalived/keepalived.conf
    prio=$(hostname | sha1sum | sha1sum | grep -Eo "[[:digit:]]{2}" | head -n1 | sed 's/0/1/g')
    sed -i "s|{{ KD_PRIORITY }}|$prio|g" /keepalived/keepalived.conf
    sed -i "s|{{ VIP }}|$VIP|g" /keepalived/keepalived.conf
    sed -i "s|{{ VRRP_PASS }}|$VRRP_PASS|g" /keepalived/keepalived.conf
    sed -i "s|{{ VR_ID }}|$VR_ID|g" /keepalived/keepalived.conf
    sed -i "s|{{ IFACE }}|$IFACE|g" /keepalived/keepalived.conf
    sed -i "s|{{ RANCHER_HOSTNAME }}|$RANCHER_HOSTNAME|g" /keepalived/keepalived.conf
    for peer in $(echo $PEERS | tr ";" " "); do
        sed -i "s|{{ PEERS }}|$peer\n    {{ PEERS }}|g" /keepalived/keepalived.conf
    done;
    sed -i "s|{{ PEERS }}||g" /keepalived/keepalived.conf
}

function render_check() {
    cp /keepalived/base/check-template.sh /keepalived/check-rancher.sh
    sed -i "s|{{ RANCHER_HOSTNAME }}|$RANCHER_HOSTNAME|g" /keepalived/check-rancher.sh
    chmod +x /keepalived/check-rancher.sh
}

function start_failover_services() {
  killall -9 /usr/sbin/keepalived &> /dev/null || :
  /usr/sbin/keepalived $KEEPALIVED_OPTIONS -n --log-console -f /keepalived/keepalived.conf &
  local pid=$!

  trap "cleanup ${pid}" SIGHUP SIGINT SIGTERM
  wait ${pid}
}

render_config

render_check

setup_failover

start_failover_services

echo "`basename $0`: Keepalived Terminated."
