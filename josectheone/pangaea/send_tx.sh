#!/bin/bash
# Author: Jose Carlos
# Contact Telegram: @josectheone
# Credits to "AG" for sharing the base script
# Version 1.3.1

# User specific values here
pangaea_path=~; # Home folder by default
amount_base=0.001; # The amount you wish to send in every transaction

# Do not change values from here onwards. !if you know what your doing

# Check for dependencies
command -v jq > /dev/null 2>&1 && jq_is_installed="yes" || \
command -v curl > /dev/null 2>&1 && curl_is_installed="yes" || \
{ echo >&2 "I require curl and jq but they are not installed. Aborting."; \
echo >&2 "try sudo apt-get install curl jq or sudo yum install curl jq"; exit 1; }

# Set static variables
wallet=$(cd ${pangaea_path}; LD_LIBRARY_PATH=. ./wallet.sh -t list | grep account | awk '{print $2}'); # Set home folder as default install path (cd ~)
shardid=$(grep -Eom1 "\"shardID\"\:[0-9]+" latest/zerolog*.log | awk -F: '{print $2}'); # Defines the shard to use
amount=$amount_base$(($RANDOM + 1)); # Defines the base ammount to send in every TX

# Main loop starts here
while true; do

# Set dinamic variables 
pga_out=$(curl -s https://harmony.one/pga/network.json);
nodes_online_count=$(echo "${pga_out}" |  jq '.shards."'$shardid'".node_count.online');
rand=$(( $(($RANDOM % $nodes_online_count)) - 1 ));
recipient=$(echo "${pga_out}" | jq -r '.shards."'$shardid'".nodes.online | map(select(. != "'$wallet'")) | .['$rand']');

# Run wallet transfers
./wallet.sh -t transfer --from $wallet --to $recipient --amount $amount --shardID $shardid --toShardID 0 --pass pass: & wait & sleep 10

done
