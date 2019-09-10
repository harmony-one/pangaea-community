#!/bin/bash
#####
##### monitor status of your pangaea node:
##### disk space used for db, memory usage, cpu usage, how long is ./harmony running, wallet balance, status(+shard status), bingo
#####
##### installation: install jq, pgrep, curl, download monitor.sh, chmod u+x, create alias, edit HARMONY_ROOT variable
##### for example put this string in ~/.bashrc:
##### alias mon="watch -d -n 60 --color /root/harmony-node/monitor.sh"
##### then after relogin you can just run:
##### mon
#####

#### where your harmony node is located. by default = /root
HARMONY_ROOT="/root"


command -v jq >/dev/null 2>&1 || { echo >&2 "I require jq but it's not installed. Aborting."; echo >&2 "try apt-get install jq."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo >&2 "I require curl but it's not installed. Aborting."; echo >&2 "try apt-get install curl."; exit 1; }
command -v pgrep >/dev/null 2>&1 || { echo >&2 "I require pgrep but it's not installed. Aborting."; echo >&2 "try apt-get install procps."; exit 1; }


cd "${HARMONY_ROOT}"
free -mh; df -h /; uptime;
hostname;
echo ""
if pgrep -fa "./harmony " > /dev/null;
then
	echo ./harmony started:  $(ps -C harmony -o etime --no-headers) ago;
	tac latest/zero*.log | grep -oam 1 -E "\"(blockNumber|myBlock)\":[0-9\"]*";
	shardid=$(grep -Eom1 "\"shardID\"\:[0-9]+" latest/validator*.log | awk -F: '{print $2}');
	echo my shard is $shardid
	du -shc harmony_db*;
	(cd "${HARMONY_ROOT}"; LD_LIBRARY_PATH=. ./wallet -p pangaea balances);
	wallet=$(cd "${HARMONY_ROOT}"; LD_LIBRARY_PATH=. ./wallet -p pangaea list | grep account | awk '{print $2}');
	pga_out=$(curl -s https://harmony.one/pga/network.json);
	shardstatus=$(echo "${pga_out}" | jq -r '.shards."'$shardid'".status')
	nodestatus=$(echo "${pga_out}" | jq -r '.shards."'$shardid'".nodes.online | index("'$wallet'")')
	if [ "$shardstatus" =  "online" ]; 
	then
		if [ "$nodestatus" = "null" ];
		then
			echo -e "${wallet} \033[31mOFFLINE\033[0m; shard $shardid ONLINE"
		else
			echo -e "wallet ${wallet} ONLINE and shard is ONLINE"
		fi
	else
		if [ "$nodestatus" = "null" ];
		then
			echo -e "${wallet} \033[33mOFFLINE\033[0m; shard $shardid \033[33mOFFLINE\033[0m"
		else
			echo -e "wallet ${wallet} ONLINE and shard $shardid \033[33mOFFLINE\033[0m"
		fi
	fi
	last_bingo_ago=$(( $(date +"%s") - $(date --date=$((cd "${HARMONY_ROOT}"; tac latest/zero*.log | grep -am 1 "BINGO" ) | jq -r '.time') +%s) ))
	if [ $last_bingo_ago -gt 100 ];
	then
		echo -e "last BINGO was found \033[33m$last_bingo_ago\033[0m seconds ago"
	else
		echo -e "last BINGO was found $last_bingo_ago seconds ago"
	fi
else
	echo -e "\033[31m./harmony not running!!!\033[0m"
fi
