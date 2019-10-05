

# random_tx_loop.sh

Script to execute random transfers from your own address to other addresses running a node. Should be run in the directory where to wallet is located. Requires addresses.txt file in the same directory.

Edit the script file before use and change:

#### myaddress=your address

#### baseamount=your amount to send

#### numtx=number of transfers to do before loop stops

# mqtt_faucet_server.sh

This script will continously listen to a mqttt topic and send an amount from your address to the
received request addres. It requires to install mqtt client first:
  
```
sudo apt-add-repository ppa:mosquitto-dev/mosquitto-ppa
sudo apt-get update
sudo apt-get install mosquitto
sudo apt-get install mosquitto-clients`
```
Then edit the script and set faucet amount and your wallet address.
After running this script, everyone can ask a faucet from you remotely using e.g. http://www.hivemq.com/demos/websocket-client/ by 1. connecting to the mqtt host 2.filling in the topic pga/transfer and 3. put his receiving address as message

Note this only works with a good working Pangaea network where transfers not get lost...



  
