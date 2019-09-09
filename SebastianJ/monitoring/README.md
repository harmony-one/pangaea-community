# Harmony Mainnet/Pangaea monitoring scripts

Harmony Mainnet/Pangaea monitoring scripts by [SebastianJ](https://github.com/SebastianJ)

## node_status.sh

Checks and also fixes some issues with node installations.

The script will try to inform you how to fix certain issue if they are detected.

This node status script has the following features:

1. Supports specifying custom node and wallet directories for people running custom installations.
2. Checks if the *.key and UTC* files are in the correct folders.
3. Checks that all script files and binaries can be found.
4. Automatically parses the wallet address from the wallet binary.
5. Checks that your node is running using the latest bootnodes. It will also check if other node processes are running (i.e. if you're running a node using the old bootnodes)
6. Detects which shard you are running on.
7. Will check your shard's status on https://harmony.one/pga/network
8. Will check your node's online status using https://harmony.one/pga/network.csv
9. Will check your sync status, block count and bingo status using latest/zero*.log. The script will also alert if you're more than 1000 blocks behind the latest reported block number for your shard and it will also report when you haven't received any bingos for more than a day.
10. and a bunch of other features

### Requirements
The only requirement is that wget is installed (which it typically is). The rest of the script is normal bash.

### Installation & Setup

`sudo rm -rf node_status.sh && wget -q https://raw.githubusercontent.com/harmony-one/pangaea-community/master/SebastianJ/monitoring/node_status.sh && sudo chmod u+x node_status.sh`

### Running the script

`./node_status.sh -h` will display all options for running the monitoring script.

If you download the script to your node installation directory you simply just run the script without any parameters:

`./node_status.sh`

If you've installed your node and/or wallet in custom directories you run the script like this:

`./node_status.sh -n /opt/harmony/pangaea/node/ -w /opt/harmony/pangaea/wallet/`

The script is currently defaulting to Pangaea, but it's also compatible with the Mainnet, just pass the -m option to switch from Pangaea to Mainnet:

`./node_status.sh -m`

The script can also be executed in an infinite loop with a specified interval:

`./node_status.sh -d -i 1m`

The above will check your node status every minute.
