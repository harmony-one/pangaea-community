checkshards.sh:
Script monitor for the pangaea online status of the 4 shards and will then download the new node.sh and anything else you wanted it to do when the 4 shards are online

pangaea_daily_node_online.py: 
python script allowing to capture all the pangaea nodes online during the day

cron to be created and executed every 15 min based on the https://harmony.one/pga/network.json if the file of the day is not existing, create it from the network monitoring page. Stats of the day will be updated with the new nodes that came online without removing a node if it went offline

Accuracy is depending on the https://harmony.one/pga/network.json Currently it doesn't exclude the internal harmony node used to boostrap the network
