#!/bin/bash
#### this script will constantly pick random online node from your shard and send a random amount

#### place where are your harmony files reside. /root by default
settings_HARMONY_ROOT="/root"

###
if [ -z ${HARMONY_ROOT+x} ]; then
        HARMONY_ROOT="${settings_HARMONY_ROOT}"
else
        echo "HARMONY_ROOT was set outside this script=${HARMONY_ROOT}";
fi

#### left part of sending amount. result will be LEFT_string+Right_sring like 0.0125 0.014805 0.0111 etc
#### intentionally left very small by default to prevent spending all tokens
amount_base="0.01"

command -v wget > /dev/null 2>&1 && wget_is_installed="yes" || \
	command -v curl > /dev/null 2>&1 && curl_is_installed="yes" || \
		{ echo >&2 "I require curl OR wget but they are not installed. Aborting."; \
		echo >&2 "try sudo apt-get install curl. or sudo apt-get install wget"; exit 1; }

if [ ! -x ${HARMONY_ROOT}/wallet.sh ]; then echo >&2 "oops ${HARMONY_ROOT}/wallet.sh is not executable! Are you sure you did chmod u+x? are you sure that harmony is installed in ${HARMONY_ROOT}?"; exit 2; fi
if [ ! -x ${HARMONY_ROOT}/wallet ]; then echo >&2 "oops ${HARMONY_ROOT}/wallet is not executable!"; exit 2; fi

function get_pga_network_csv () {
	if [ $wget_is_installed ];
	then
		pga_network_csv=$(wget -qO- https://harmony.one/pga/network.csv)
	else
		pga_network_csv=$(curl -s https://harmony.one/pga/network.csv)
	fi
}
function get_pga_balances_csv () {
	if [ $wget_is_installed ];
	then
		pga_balances_csv=$(wget -qO- https://harmony.one/pga/balances.csv)
	else
		pga_balances_csv=$(curl -s https://harmony.one/pga/balances.csv)
	fi
}

cd ${HARMONY_ROOT}

wallet=$(cd "${HARMONY_ROOT}"; LD_LIBRARY_PATH=. ./wallet -p pangaea list | grep account | cut -c10-51 );
echo my wallet=$wallet

shardid=$(cd $HARMONY_ROOT/; ls -d harmony_db_* | tail -1 | cut -c12-);
echo my shard=$shardid

while true
do
        echo ""
        date

        #get_pga_network_csv
	get_pga_balances_csv
        online_nodes_in_shard=$(echo "${pga_balances_csv}" | grep ",$shardid,,true")
        online_nodes_count=$(echo "${online_nodes_in_shard}" | grep . | wc -l)	### small hack: grep . removes empty lines.
        if [ $online_nodes_count -lt 1 ];
        then
        	echo "0 nodes online in shard $shardid; will sleep 60 sec"
        	sleep 60
        	continue
        fi
        recipient_string_number=$(( $(($RANDOM % $online_nodes_count)) + 1 ))
        recipient=$(echo "${online_nodes_in_shard}" | head -n"$recipient_string_number"| tail -n 1 | cut -c1-42)
        amount=$amount_base$(($RANDOM + 1))

	echo "will send $amount tokens to $recipient with this command:"
        echo "./wallet.sh -t transfer --from $wallet --to $recipient --shardID $shardid --toShardID $shardid --amount $amount --pass pass:"
        ./wallet.sh -t transfer --from $wallet --to $recipient --shardID $shardid --toShardID $shardid --amount $amount --pass pass:
        (cd ${HARMONY_ROOT}; LD_LIBRARY_PATH=. ./wallet -p pangaea balances);
done
