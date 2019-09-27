I will just place my scripts in this folder


wallet fetch script
will fetch all online node from https://harmony.one/pga/network
you could change the curl to https://harmony.one/pga/balances and filter on earning and not earning
it generates a file called wallets.txt wich is needed in the crossshard.sh

Cross shard script

it generate a random shard nummer for send and receive
after that it reads out the wallets.txt file.
and after that it wil do the tx and writes output with a date to a file called crossshard.txt

output will be something like

my from shard=1
my to shard=0
Sun Sep 15 19:22:38 UTC 2019
Using pangaea profile for wallet
Unlock account succeeded! 'pass:'
Transaction Id for shard 1: 0xe8f82308b198cd0f7d8d43ba34c94a731a4e9259f74a719f2304d919424a9104
