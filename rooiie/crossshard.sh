#!/bin/sh
while :
    do
fromshard=$(shuf -i 0-3 -n 1)
echo my from shard=$fromshard >> crossshard.txt
toshard=$(shuf -i 0-3 -n 1)
echo my to shard=$toshard >> crossshard.txt

filename='wallets.txt'
n=1
while read line; do
# reading each line
n=$((n+1))
done < $filename

date >> crossshard.txt && ./wallet.sh -t transfer --from one1lpezs3xgqr4smtdxfslpv3l48twyrez06cvx2k --to $filename --amount  0.001 --shardID=$fromshard --toShardID=$toshard --pass pass: | tee -a crossshard.txt

sleep 5

done
