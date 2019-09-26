#!/bin/bash
#checkshards.sh
#check network file for shard status

#checking shards status and will print online if all 4 are online, else offline
check_shard_status() {
  # Get status for Pangaea Shards and put in file "network"
  rm network
  curl -LO https://harmony.one/pga/network

  while read line
  do
    if [[ $line == *"ONLINE"* ]]; then
      continue
    else
      areonline="no"
      echo offline
      return 1 #exit the function at first no match of ONLINE
    fi
  done <<< "$(cat network | grep Status)"
  #it would return online only when the 4 shards are ONLINE
  echo online
}

while true
do
  status=$(check_shard_status)
  #echo "status is : $status"
  if [ $status == "offline" ]; then
    echo "$(date) : Nah .. still offline"
    sleep 60
  else
    echo "$(date) : Yeah ! online finally, node is ready to start !!"
    #put below here what you want to do when the shards are online
    
    #maybe redownload the node:
    rm node.sh*
    curl -LO https://raw.githubusercontent.com/harmony-one/harmony/master/scripts/node.sh
    chmod u+x node.sh
    
    #and launch it passphrase is the file with your passphrase. For pangeaa that would be an empty file
    ./node.sh -t -p passphrase &
    
    #maybe send a message your Telegram Bot :
    #curl -s -X POST https://api.telegram.org/bot<YOURBOTID>/sendMessage -d chat_id=<YOURCHATID> -d text="Shards are online !"
    break
  fi
done
