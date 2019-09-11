#!/bin/bash
# Author: Jose Carlos
# Contact Telegram: @josectheone
# Credits to "AG" for sharing the base script
# Version 1.3

# User specific values here
pangaea_path=~; # Home folder by default
amount_base=0.001; # The amount you wish to send in every transaction

# Do not change values from here onwards. !if you know what your doing

# Check for dependencies
apt list jq | grep installed &>/dev/null
if [[ $? != 0 ]]; then
	echo "Please install jq before running this script use the command:"
	echo "sudo apt install jq"
        exit 0
else
	apt list curl | grep installed &>/dev/null
	if [[ $? != 0 ]]; then
        	echo "Please install curl before running this script use the command:"
		echo "sudo apt install curl"
		exit 0
	fi
fi

# Set static variables
wallet=$(cd ${pangaea_path}; LD_LIBRARY_PATH=. ./wallet.sh -t list | grep account | awk '{print $2}'); # Set home folder as default install path (cd ~)
shardid=$(grep -Eom1 "\"shardID\"\:[0-9]+" latest/validator*.log | awk -F: '{print $2}'); # Defines the shard to use
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
