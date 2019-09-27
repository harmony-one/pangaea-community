#!/bin/bash

#input parameters

myaddress=one16p8vky8s0467sk7a63wwww7kgzgefe3hrl4gju
baseamount=0.002
numtx=1000

# read text file (in same directory) with address per line
readarray toaddress < addresses.txt
arlenght=${#toaddress[@]}
echo numaddressinfile: $arlenght

# lets do a loop of 1000 tx
i=0
while [ $i -le $numtx ]
do
   echo txcounter: $i
   randid=$(( ( RANDOM % ${#toaddress[@]} )  + 1 ))
   shardid=$(( ( RANDOM % 4 ) ))
   toshardid=$(( ( RANDOM % 4 ) ))
   amount=$baseamount$(($RANDOM + 1))
 
   echo to: ${toaddress[$randid]} $toshardid
   
   ./wallet.sh -t transfer --from $myaddress --to ${toaddress[$randid]} --amount $amount --shardID $shardid --toShardID $toshardid --gasPrice 10 --pass pass:
   

  ((i++))
done
