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

#### place where are your harmony files reside. /root by default
settings_HARMONY_ROOT="/root"

###
if [ -z ${HARMONY_ROOT+x} ]; then
		HARMONY_ROOT="${settings_HARMONY_ROOT}"
else
		echo "HARMONY_ROOT was set outside this script=${HARMONY_ROOT}";
fi

command -v jq >/dev/null 2>&1 || { echo >&2 "I require jq but it's not installed.  Aborting."; echo >&2 "try apt-get install jq."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo >&2 "I require curl but it's not installed.  Aborting."; echo >&2 "try apt-get install curl."; exit 1; }
command -v pgrep >/dev/null 2>&1 || { echo >&2 "I require pgrep but it's not installed.  Aborting."; echo >&2 "try apt-get install procps."; exit 1; }
if command -v tput >/dev/ull 2>&1; then
	bold_text=$(tput bold)
	normal_text=$(tput sgr0)
	black_text=$(tput setaf 0)
	red_text=$(tput setaf 1)
	green_text=$(tput setaf 2)
	yellow_text=$(tput setaf 3)

	### fix colors for bash -x debugging
	echo -e "${normal_text}"
else
	bold_text=""
	normal_text=""
	black_text=""
	red_text=""
	green_text=""
	yellow_text=""
fi




cd "${HARMONY_ROOT}"
#### overall system health
free -mh; df -h /; uptime;
hostname;
echo ""

if pgrep -fa "./harmony " > /dev/null;
then
	echo ./harmony started:  $(ps -C harmony -o etime --no-headers) ago;

	#### my shard id
	shardid=""
	if ! ls -d $HARMONY_ROOT/harmony_db_* 1> /dev/null 2>&1; then
		echo -e "${red_text}there are no \"$HARMONY_ROOT/harmony_db_*\" directories found. Can not determine my shard!${normal_text}"
	else
		_shardid=$(cd $HARMONY_ROOT/; ls -d harmony_db_* | tail -1 | cut -c12-)
		case $_shardid in
			''|*[!0-9]*)
				echo -e "${yellow_text}Can not determine my shard with \"ls -d harmony_db_*\"${normal_text}"
				cd $HARMONY_ROOT/; ls -d harmony_db_*
			;;
			*)
				shardid=$_shardid
				echo shard = $shardid
				#### latest block from log
				block=$(tac latest/zerolog*.log | grep -E "\"(blockShard)\":$shardid" | grep -oam 1 -E "\"(blockNumber|myBlock)\":[0-9\"]*" | grep -oam 1 -E "[0-9]+" )
				echo block = $block

			;;
		esac
	fi

	#### WALLET
	#### get wallet/shard status from https://harmony.one/pga/network
	balances_out=$(cd "${HARMONY_ROOT}"; LD_LIBRARY_PATH=. ./wallet -p pangaea balances 2>&1 || exit 5 ) || { echo -e "${red_text}error getting balances${normal_text}"; echo "${balances_out}" exit 5; }
	wallets_Addresses=$(grep Address <<< "$balances_out" || exit 5) || { echo -e "${red_text}Addresses not found in \"wallet balances\" output${normal_text}; ${balances}"; exit 5; }
	number_of_wallets=$(grep Address <<< "$balances_out" | wc -l)
	wallet=$(grep Address <<< "$balances_out" | head -n1 | cut -c14-)
	if [ $number_of_wallets -gt 1 ]; then
		echo -e "${yellow_text}found $number_of_wallets wallets${normal_text};will use first=$wallet"
	fi

	pga_out=$(curl -s https://harmony.one/pga/network.json);
	if [[ $(tr -d " \t\n\r"  <<< "$pga_out" | wc -c) -lt 2 ]] || ! jq -e . >/dev/null 2>&1 <<<"$pga_out" ; then
		echo -e "${yellow_text}https://harmony.one/pga/network.json is not a valid JSON. will not parse node/shard status${normal_text}"
	elif [ -z "$shardid" ] ; then
		echo -e "${red_text}shardid is not defined - will not check wallet/shard status${normal_text}"
	else
		shardstatus=$(jq -r '.shards."'$shardid'".status' <<< "${pga_out}")
		shardstatus_time=$(jq -r '.shards."'$shardid'".last_updated' <<< "${pga_out}")
		shardstatus_ago=$(( $(date +"%s") - $(date --date="$shardstatus_time" +%s) ))
		if [ $shardstatus_ago -gt 1800 ] ; then
			echo -e "${yellow_text}status page was updated more than 30m ago = ${shardstatus_ago}s${normal_text}"
			shardstatus_text="(${yellow_text}updated $shardstatus_ago seconds ago${normal_text})"
		else
			shardstatus_text="(updated $shardstatus_ago seconds ago)"
		fi
		nodestatus=$(jq -r '.shards."'$shardid'".nodes.online | index("'$wallet'")' <<< "${pga_out}")
		case "x$shardstatus" in
			xonline)
				case $nodestatus in
					null)					#### nodestatus is "null" when searching it in online list - it is offline
						echo -e "wallet ${wallet} is ${red_text}OFFLINE${normal_text}; shard $shardid is ${green_text}ONLINE${normal_text} ${shardstatus_text}"
					;;
					''|*[!0-9]*)			#### nodestatus is empty string or something NOT numbers - error
						echo "possible error parsing pga/network output - nodestatus is not null/numbers"
						echo "shardstatus=\"$shardstatus\", nodestatus=\"$nodestatus\""
					;;
					*)						#### nodestatus is not null, not empty string, not not numbers - it is online
						 echo -e "wallet ${wallet} is ${green_text}ONLINE${normal_text}; shard $shardid is ${green_text}ONLINE${normal_text} ${shardstatus_text}"
					;;
				esac
			;;
			xoffline)
				case $nodestatus in
					null)					#### nodestatus is "null" when searching it in online list - it is offline
						echo -e "${wallet} ${yellow_text}OFFLINE${normal_text}; shard $shardid is ${yellow_text}OFFLINE${normal_text} ${shardstatus_text}"
					;;
					''|*[!0-9]*)			#### nodestatus is empty string or something NOT numbers - error
						echo "possible error parsing pga/network output - nodestatus is not null/numbers"
						echo "shardstatus=\"$shardstatus\", nodestatus=\"$nodestatus\""
					;;
					*)						#### nodestatus is not null, not empty string, not not numbers - it is online
						echo -e "wallet ${wallet} is ${green_text}ONLINE${normal_text}; shard $shardid is ${yellow_text}OFFLINE${normal_text} ${shardstatus_text}"
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
		echo -e "${red_text}BINGO not found${normal_text}\n"
	else
		last_bingo_ago=$(( $(date +"%s") - $(date --date=$(jq -r '.time' <<< "$last_bingo_found") +%s) ))
		if [ $last_bingo_ago -gt 300 ];
		then
			echo -e "last BINGO ${red_text}was found $last_bingo_ago seconds ago${normal_text} - more than 5 minutes!"
		elif [ $last_bingo_ago -gt 60 ]; then
			echo -e "last BINGO ${yellow_text}was found $last_bingo_ago seconds ago${normal_text} - more than 1 minute!"
		else
			echo -e "last BINGO ${green_text}was found $last_bingo_ago${normal_text} seconds ago"
		fi
	fi

	#### SYNC STATUS
	zerolog_SYNC_strings=$(cd "${HARMONY_ROOT}"; cat latest/zerolog*.log | grep -E "isBeacon: false" | grep SYNC)
	if [ $? -gt 0 ]; then
		echo -e "${red_text}can not find \"isBeacon: false\"${normal_text}";
	else
		sync_status=$(tail -n 1 <<< "$zerolog_SYNC_strings" | jq -r '.message')
		sync_status_ago=$(( $(date +"%s") - $(date --date=$(tail -n 1 <<< "$zerolog_SYNC_strings" | jq -r '.time') +%s) ))
		if [ $sync_status_ago -gt 300 ]; then
			echo -e "${yellow_text} SYNC status is found $sync_status_ago seconds ago = older than 5 minutes${normal_text}"
		fi
		if grep -q "Node is now IN SYNC!" <<< "$sync_status"; then
			echo -e "Node is in ${green_text}SYNC${normal_text}"
		elif grep -q "Node is Not in Sync" <<< "$sync_status"; then
			echo -e "Node is ${red_text}not in sync;${normal_text} latest SYNC status=\"${sync_status}\"";
		else
			echo -e "${yellow_text}Node SYNC has unknown status=${normal_text}\"${sync_status}\""
		fi
	fi

	#### print wallet balances
	echo "${balances_out}"

	#### how much MB is harmony db
	du -shc harmony_db*;
	
else
	echo -e "${red_text}./harmony is not running!!!${normal_text}"
fi
