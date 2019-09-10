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

command -v jq >/dev/null 2>&1 || { echo >&2 "I require jq but it's not installed.  Aborting."; echo >&2 "try apt-get install jq."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo >&2 "I require curl but it's not installed.  Aborting."; echo >&2 "try apt-get install curl."; exit 1; }
command -v pgrep >/dev/null 2>&1 || { echo >&2 "I require pgrep but it's not installed.  Aborting."; echo >&2 "try apt-get install procps."; exit 1; }


cd "${HARMONY_ROOT}"
#### overall system health
free -mh; df -h /; uptime;
hostname;
echo ""

if pgrep -fa "./harmony " > /dev/null;
then
	echo ./harmony started:  $(ps -C harmony -o etime --no-headers) ago;

	#### latest block from log
	tac latest/zero*.log | grep -oam 1 -E "\"(blockNumber|myBlock)\":[0-9\"]*";

	#### my shard id
	shardid=$(grep -Eom1 "\"shardID\"\:[0-9]+" latest/validator*.log | awk -F: '{print $2}');
	echo my shard is $shardid

	#### how much MB is harmony db
	du -shc harmony_db*;

	#### print wallet balances
	(cd "${HARMONY_ROOT}"; LD_LIBRARY_PATH=. ./wallet -p pangaea balances);

	#### get wallet/shard status from https://harmony.one/pga/network
	wallet=$(cd "${HARMONY_ROOT}"; LD_LIBRARY_PATH=. ./wallet -p pangaea list | grep account | awk '{print $2}');
	pga_out=$(curl -s https://harmony.one/pga/network.json);
	if jq -e . >/dev/null 2>&1 <<<"$pga_out"; then
		echo -e "\033[33mhttps://harmony.one/pga/network.json is not a valid JSON. will not parse node/shard status\033[0m"
	else
		shardstatus=$(echo "${pga_out}" | jq -r '.shards."'$shardid'".status')
		nodestatus=$(echo "${pga_out}" | jq -r '.shards."'$shardid'".nodes.online | index("'$wallet'")')
		case "x$shardstatus" in
			xonline)
				case $nodestatus in
					null)					#### nodestatus is "null" when searching it in online list - it is offline
						echo -e "${wallet} \033[31mOFFLINE\033[0m; shard $shardid ONLINE"
					;;
					''|*[!0-9]*)			#### nodestatus is empty string or something NOT numbers - error
						echo "possible error parsing pga/network output - nodestatus is not null/numbers"
						echo "shardstatus=\"$shardstatus\", nodestatus=\"$nodestatus\""
					;;
					*)						#### nodestatus is not null, not empty string, not not numbers - it is online
						 echo -e "wallet ${wallet} ONLINE and shard is ONLINE"
					;;
				esac
			;;
			xoffline)
				case $nodestatus in
					null)					#### nodestatus is "null" when searching it in online list - it is offline
						echo -e "${wallet} \033[33mOFFLINE\033[0m; shard $shardid \033[33mOFFLINE\033[0m"
					;;
					''|*[!0-9]*)			#### nodestatus is empty string or something NOT numbers - error
						echo "possible error parsing pga/network output - nodestatus is not null/numbers"
						echo "shardstatus=\"$shardstatus\", nodestatus=\"$nodestatus\""
					;;
					*)						#### nodestatus is not null, not empty string, not not numbers - it is online
						echo -e "wallet ${wallet} ONLINE and shard $shardid \033[33mOFFLINE\033[0m"
					;;
				esac
			;;
			*)
				echo "possible error in parsing pga/network output - shardstatus is not offline/online"
				echo "shardstatus=\"$shardstatus\", nodestatus=\"$nodestatus\""
			;;
		esac
	fi

	#### BINGO
	last_bingo_found=$(cd "${HARMONY_ROOT}"; tac latest/zero*.log | grep -am 1 "BINGO");
	if [ $? -gt 0 ]; then
		echo -e "\033[31mBINGO not found\033[0m\n"
	else
		last_bingo_ago=$(( $(date +"%s") - $(date --date=$(echo "$last_bingo_found" | jq -r '.time') +%s) ))
		if [ $last_bingo_ago -gt 100 ];
		then
			echo -e "last BINGO was found \033[33m$last_bingo_ago\033[0m seconds ago"
		else
			echo -e "last BINGO was found $last_bingo_ago seconds ago"
		fi
	fi
else
	echo -e "\033[31m./harmony is not running!!!\033[0m"
fi
