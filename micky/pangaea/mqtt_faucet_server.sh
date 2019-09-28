#!/bin/bash

# This script will listen to a mqttt topic
# and send <amount> from <myaddress> to the
# received request address

myaddress=one16p8vky8s0467sk7a63wwww7kgzgefe3hrl4gju
amount=0.001
shardid=0

echo "mqtt process will listen to pga/transfer topic"
echo "using public broker broker.mqttdashboard.com"
i=0
mosquitto_sub -R -h broker.mqttdashboard.com -t pga/transfer  | while read line
do
  echo "received input, analyse messages per line: what we do with this line"
  echo $line
  if  ([[ $line == one1 ]] || [[ $line == one1* ]]) && [ ${#line} -eq 42 ];
    then
     echo "format seems correct, starts with one1 and has correct size"
     echo $i
     if [[ " ${toaddress[*]} " == *"$line"* ]];
		then
			echo "Array already contains this address, ignore spam to get more from us"
		else
			echo "Array does not contain this address yet, transfer allowed"
			./wallet.sh -t transfer --from $myaddress --to $line --amount $amount --shardID $shardid --toShardID $shardid --pass pass:
			toaddress[i]=$line
            ((i++))
	 fi

  fi
done
