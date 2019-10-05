#!/bin/bash

# Author: Sebastian Johnsson - https://github.com/SebastianJ

start() {
  if ps aux | grep '[h]armony -bootnodes' > /dev/null; then
    echo "You're already running a harmony/node process. Please stop the current process using sudo pkill harmony && sudo pkill node.sh"
  else
    ./node.sh "${1}"
  fi
}

start "${@}"
