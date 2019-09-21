#!/bin/bash

# Author: Sebastian Johnsson - https://github.com/SebastianJ
#
# Contributors:
# Script/binaries last modified date: Sophoah - https://github.com/sophoah
# More eloquent parsing of shard_*: Agx10k - https://github.com/AGx10k

# Harmony Mainnet/Pangaea Node Status
version="0.1.9"
script_name="node_status.sh"
script_url="https://raw.githubusercontent.com/harmony-one/pangaea-community/master/SebastianJ/monitoring/node_status.sh"

# Default to the Pangaea network for now:
network_switch=" -t"
pangaea=true

usage () {
   cat << EOT
Usage: $0 [option] command
Options:
   -n path      the path of the node directory - defaults to the current user's home directory if no path is provided
   -w path      the path of the wallet directory - defaults to the current user's home directory if no path is provided
   -i interval  interval between running the program when running deamonized / using -d (e.g: 30s, 1m, 30m, 1h etc.)
   -c count     the maximum number of blocks your node can be behind your shard's reported block count before errors are reported. Defaults to 1000 blocks
   -s seconds   the maximum number of seconds since your last bingo before errors are reported. Defaults to 3600 = 1 hour
   -d           if the process should be daemonized / run in an endless loop (e.g. if running it using Systemd and not Cron)
   -t           use the Pangaea network
   -m           use the Mainnet network
   -f           disable color and text formatting
   -y           disable version checking
   -z           enable debug mode
   -h           print this help
EOT
}

while getopts "n:w:i:c:s:dtmfyzh" opt; do
  case ${opt} in
    n)
      node_path="${OPTARG%/}"
      ;;
    w)
      wallet_path="${OPTARG%/}"
      ;;
    i)
      interval="${OPTARG}"
      ;;
    c)
      maximum_block_count_difference="${OPTARG}"
      convert_to_integer "$maximum_block_count_difference"
      maximum_block_count_difference=$converted
      ;;
    s)
      maximum_block_time_difference="${OPTARG}"
      convert_to_integer "$maximum_block_time_difference"
      maximum_block_time_difference=$converted
      ;;
    d)
      daemonize=true
      ;;
    t)
      pangaea=true
      network_switch=" -t"
      ;;
    m)
      pangaea=false
      network_switch=""
      ;;
    f)
      perform_formatting=false
      ;;
    y)
      disable_version_checking=true
      ;;
    z)
      debug=true
      ;;
    h|*)
      usage
      exit 1
      ;;
  esac
done

shift $((OPTIND-1))

#
# Variable setup
#

executing_user=`whoami`
current_dir=`pwd`

# Interval between checking node status
# E.g: 30s => 30 seconds, 1m => 1 minute, 1h => 1 hour
if [ -z "$interval" ]; then
  interval=1m
fi

if [ -z "$node_path" ]; then
  node_path=${HOME}
fi

if [ -z "$wallet_path" ]; then
  wallet_path=${HOME}
fi

if [ -z "$maximum_block_count_difference" ]; then
  # Defaults to a 1000 block difference between locally reported block count and remotely/network reported block count
  maximum_block_count_difference=1000
fi

if [ -z "$maximum_block_time_difference" ]; then
  # Defaults to 1 hour since last bingo if nothing else is specified
  maximum_block_time_difference=3600
fi

if [ -z "$perform_formatting" ]; then
  perform_formatting=true
fi

if [ -z "$use_error_log" ]; then
  use_error_log=true
fi

if [ -z "$debug" ]; then
  debug=false
fi

if [ -z "$disable_version_checking" ]; then
  disable_version_checking=false
fi

data_dir="node_status"
cache_dir="${data_dir}/cache"
temp_dir="${data_dir}/temp"
error_log_file="${data_dir}/errors.log"
correct_bootnode="54.86.126.90"

#
# Formatting setup
#
header_index=1

if [ "$perform_formatting" = true ]; then
  bold_text=$(tput bold)
  normal_text=$(tput sgr0)
  black_text=$(tput setaf 0)
  red_text=$(tput setaf 1)
  green_text=$(tput setaf 2)
  yellow_text=$(tput setaf 3)
else
  bold_text=""
  normal_text=""
  black_text=""
  red_text=""
  green_text=""
  yellow_text=""
fi

#
# Check functions
#

check_version() {
  if [ "$disable_version_checking" = false ]; then
    parse_current_script_version
    
    if [ ! -z "$latest_script_version" ]; then
      if [ ! "$version" = "$latest_script_version" ]; then
        # Remove old data dir in preparation for the new script installation (data formats etc. might've changed in the new version)
        rm -rf $data_dir
        
        echo "${yellow_text}${bold_text}"
        echo "You're running an old version of ${script_name}! Latest available version is ${latest_script_version} and you're running version ${version}"
        echo "Please upgrade your script using the following command:"
        echo
        echo "sudo rm -rf ${script_name} && sudo wget -q ${script_url} && sudo chmod u+x ${script_name}"
        echo "${normal_text}"
        exit 1
      fi
    else
      error_message "Can't download the latest script version to perform version checking. Are you sure you are running this script with appropriate permissions?"
      exit 1
    fi
  fi
}

check_for_correct_installation() {
  output_header "${header_index}. Installation - checking that your installation is correct"
  ((header_index++))
  
  echo "${bold_text}BLS file:${normal_text}"
  
  if ls $node_path/*.key 1> /dev/null 2>&1; then
    success_message "BLS file detected in correct location: ${bold_text}YES${normal_text}"
  else
    error_message "BLS file detected in correct location: ${bold_text}NO${normal_text}"
  fi
  
  echo ""
  echo "${bold_text}Node:${normal_text}"
  
  if test -f $node_path/node.sh; then
    node_script_installed=true
    file_modification_date "${node_path}/node.sh"
    success_message "node.sh installed: ${bold_text}YES.${normal_text}${green_text} Last modified: ${bold_text}${file_date}.${normal_text}"
  else
    error_message "node.sh installed: ${bold_text}NO${normal_text}"
    error_message "Are you sure you've entered the correct node path ($node_path) and that you've installed node.sh?"
  fi
  
  if test -f $node_path/harmony; then
    node_binary_installed=true
    file_modification_date "${node_path}/harmony"
    determine_build "$node_path" "harmony"
    
    echo ""
    success_message "node binary installed: ${bold_text}YES.${normal_text}${green_text}"
    success_message "  Build: ${bold_text}${build}${normal_text}${green_text}."
    success_message "  Last modified: ${bold_text}${file_date}.${normal_text}"
  else
    echo
    error_message "node binary installed: ${bold_text}NO${normal_text}"
    error_message "Are you sure you've entered the correct node path ($node_path) and that you've installed the node binary ($node_path/harmony)?"
  fi
  
  echo ""
  echo "${bold_text}Wallet:${normal_text}"
  
  if test -f $wallet_path/wallet.sh; then
    wallet_script_installed=true
    file_modification_date "${wallet_path}/wallet.sh"
    success_message "wallet.sh installed: ${bold_text}YES.${normal_text}${green_text} Last modified: ${bold_text}${file_date}.${normal_text}"
  else
    echo
    error_message "wallet.sh installed: ${bold_text}NO${normal_text}"
    error_message "Are you sure you've entered the correct wallet path ($wallet_path) and that you've installed wallet.sh?"
  fi
  
  if test -f $wallet_path/wallet; then
    wallet_binary_installed=true
    file_modification_date "${wallet_path}/wallet"
    
    determine_build "$wallet_path" "wallet"

    echo ""
    success_message "wallet binary installed: ${bold_text}YES.${normal_text}${green_text}"
    success_message "  Build: ${bold_text}${build}${normal_text}${green_text}."
    success_message "  Last modified: ${bold_text}${file_date}.${normal_text}"
  else
    echo
    error_message "wallet binary installed: ${bold_text}NO${normal_text}"
    error_message "Are you sure you've entered the correct wallet path ($wallet_path) and that you've installed the wallet binary ($wallet_path/wallet)?"
    error_message "Install the wallet binary using cd $wallet_path; ./wallet.sh${network_switch} -d"
  fi
  
  output_footer
}

check_wallet() {
  output_header "${header_index}. Wallet - checking that your wallet is properly configured"
  ((header_index++))
  
  if [ "$wallet_script_installed" = true ] || [ "$wallet_binary_installed" = true ]; then
    if ls $wallet_path/.hmy/keystore/UTC* 1> /dev/null 2>&1; then
      success_message "Found your wallet file in the keystore: ${bold_text}YES${normal_text}"
      identify_address
      identify_base16_address "$address"
      
      success_message "Your address is: ${bold_text}${address}${normal_text}"
      success_message "The base16/Ethereum version of your address is: ${bold_text}${base16_address}${normal_text}"
    else
      error_message "Found your wallet file in the keystore: ${bold_text}NO${normal_text}"
      
      if ls $wallet_path/UTC* 1> /dev/null 2>&1; then
        mkdir -p $wallet_path/.hmy/keystore
        cp $wallet_path/UTC* $wallet_path/.hmy/keystore
        success_message "Found your wallet file in the wallet directory. Copying it to $wallet_path/.hmy/keystore. Please rerun the script again after seeing this message."
      else
        error_message "You need to copy your wallet file to $wallet_path/.hmy/keystore/"
      fi
      
    fi
  else
    error_message "Please make sure your wallet is configured correctly! Check the instructions above!"
  fi
  
  output_footer
}

check_node() {
  output_header "${header_index}. Node - checking that your node is running"
  ((header_index++))
  
  if ps aux | grep '[h]armony -bootnodes' | grep $correct_bootnode > /dev/null; then
    success_message "Node is running and using the correct bootnodes: ${bold_text}YES${normal_text}"
    
    parse_bootnodes
    
    if [ ! -z "$bootnodes" ]; then
      success_message "Your node is running using the bootnodes:"
    
      for bootnode in "${bootnodes[@]}"; do
        success_message "${bold_text}$bootnode${normal_text}"
      done
      
      echo ""
    fi
    
    node_running=true
  else
    error_message "Node is running and using the latest bootnodes: ${bold_text}NO${normal_text}"
    node_running=false
    
    if ps aux | grep '[h]armony -bootnodes' > /dev/null; then
      error_message "You have a running node process but it isn't using the latest bootnodes!"
      error_message "How to fix:"
      error_message "Shut down the old node:"
      error_message "sudo pkill node.sh && sudo pkill harmony"
      error_message "Reinstall the node script:"
      error_message "cd $node_path; rm -rf node.sh; wget https://raw.githubusercontent.com/harmony-one/harmony/master/scripts/node.sh; sudo chmod u+x node.sh"
      error_message "Restart your node:"
      error_message "cd $node_path; sudo ./node.sh${network_switch} -c"
    else
      warning_message "Please start your node as soon as possible: cd ${node_path}; ./node.sh${network_switch} (don't forget to run the command in tmux if you're using tmux)"
    fi
  fi
  
  detect_shard_id
  
  if [ -z "$shard" ]; then
    error_message "Can't determine your shard id - can't parse your shard id from your node directory."
  else
    success_message "Your node is running on shard: ${bold_text}shard ${shard}${normal_text}"
  fi
  
  check_bls_keyfile_status "${address}"
  echo ""
  
  if [ -z "$bls_public_key" ]; then
    error_message "Couldn't find your node's address in the bls public key list on https://bit.ly/pga-keys - are you sure that you are using a correct bls key file?"
    warning_message "Please contact an admin in @harmonypangaea on Telegram or in the Discord #pangaea channel."
  else
    success_message "Your node is running using the bls public key: ${bold_text}${bls_public_key}${normal_text}"
  fi
  
  output_footer
}

check_network_status() {
  output_header "${header_index}. Network status - checking network status for your shard and node"
  ((header_index++))
  
  pangaea_status_url="https://harmony.one/pga"
  network_file="network"
  download_file "$pangaea_status_url" "$network_file"
  
  if [ -f "${temp_dir}/${network_file}" ]; then
    network_last_updated_at=`head -1 ${temp_dir}/${network_file} | sed -E "s/(\[|\])//g"`
    success_message "Successfully fetched the network status from ${full_url} - last network update: ${bold_text}${network_last_updated_at}${normal_text}"
    echo

    echo "${bold_text}Shard status:${normal_text}"
    
    if [ -z "$shard" ]; then
      error_message "Can't determine your shard id. There might be issues with your node or the entire network."
      error_message "Outputting all shard statuses below:"
      echo 
      cat ${temp_dir}/${network_file} | grep -A 5 'SHARD STATUS'
    else
      shard_data=$(cat ${temp_dir}/${network_file} | grep -i -m 1 "Shard $shard")
  
      if [ -z "$shard_data" ]; then
        error_message "Couldn't download the network file from ${full_url}"
      else        
        parse_network_shard_data "$shard_data"
    
        if [ "$shard_status" = "ONLINE" ]; then
          success_message "Shard ${bold_text}${shard}${normal_text}${green_text} is: ${bold_text}${shard_status}${normal_text}"
          success_message "Your shard's latest recorded block is: ${bold_text}${current_network_block}${normal_text}"
        else
          error_message "Shard ${bold_text}${shard}${normal_text}${red_text} is: ${bold_text}${shard_status}${normal_text}"
          warning_message "Please check @harmonypangaea on Telegram or the Discord #pangaea channel for network updates."
        fi
      fi
    fi
  else
    error_message "Couldn't download the network status page https://harmony.one/pga/network. Please check that the URL is accessible and retry again!"
  fi
  
  if [ -z "$address" ]; then
    echo
    error_message "Can't figure out your address - won't proceed to check the network status for your node. Please check for errors in section 1 & 2."
  else
    download_file "$pangaea_status_url" "network.csv"
    reported_as_online=$(cat ${temp_dir}/network.csv | grep "$address" | grep true)
  
    echo
    echo "${bold_text}Node status:${normal_text}"
  
    if [ -z "$reported_as_online" ]; then
      error_message "Your address ${bold_text}${address}${normal_text}${red_text} is reported as: ${bold_text}OFFLINE!${normal_text}"
      
      if [ "$shard_status" = "ONLINE" ]; then
        if [ "$node_running" = true ]; then
          error_message "Your node has been detected as running on your server but the Harmony Pangaea Network status page (https://harmony.one/pga/network) reports you as OFFLINE."
          warning_message "If this issue continues after the next network status update (usually happens within the next 15-30 minutes) there might be a misconfigured or erronous internal node running your address."
          warning_message "Please report your address ${address} to the support representatives in @harmonypangaea on Telegram or in the Discord #pangaea channel."
        else
          error_message "There's no node running on your server and Harmony's Network status page has reported you as OFFLINE."
          error_message "Please start your node as soon as possible: cd ${node_path}; ./node.sh${network_switch} (don't forget to run the command in tmux if you're using tmux)"
        fi
      fi
    else
      success_message "Your address ${bold_text}${address}${normal_text}${green_text} is reported as: ${bold_text}ONLINE!${normal_text}"
      
      if [ "$node_running" = false ]; then
        error_message "Your node is currently not running on your server. If you don't fix this before the next network status refresh at https://harmony.one/pga/network your node will be marked as OFFLINE!"
      fi
    fi
  fi
  
  output_footer
}

check_sync_consensus_status() {
  output_header "${header_index}. Sync/Consensus - checking syncing and consensus status for your node"
  ((header_index++))
  
  parse_current_block
  parse_sync_status
  parse_current_bingo
  
  if [ -z "$current_block" ]; then
    error_message "Couldn't find a block number! Are you sure the node is running?"
  else    
    if [ "$node_synced" = true ]; then
      calculate_difference "$current_network_block" "$current_block"
    
      if (( difference > maximum_block_count_difference )); then
        error_message "Your node logs report your node as being in sync but you're more than ${maximum_block_count_difference} blocks away from your shard's current reported block number."
        
        if [ "$shard_status" = "ONLINE" ]; then
          error_message "Either the node hasn't been online for a while or something's wrong with your node configuration."
        else
          error_message "Your shard is currently down. Please check @harmonypangaea on Telegram or the Discord #pangaea channel for network updates."
        fi
      else
        success_message "Your node is fully synced: ${bold_text}YES${normal_text}"
        success_message "Your node is currently on block: ${bold_text}${current_block}${normal_text}"
      fi
      
    else
      success_message "Your node is currently syncing!"
      success_message "Your node is currently on block: ${bold_text}${current_block}${normal_text}"
    fi
  fi
  
  if [ -z "$current_bingo" ]; then
    error_message "Bingo status: couldn't find any recent bingos!"
    warning_message "There might be network issues - please check @harmonypangaea on Telegram or the Discord #pangaea channel for network updates."
  else
    
    if [ "$bingo_date_parsed" = true ]; then
      parse_timestamp "$current_bingo"
      current_bingo_timestamp=$timestamp
      current_timestamp=`date +"%s"`
      calculate_difference "$current_timestamp" "$current_bingo_timestamp"
    
      if (( difference > maximum_block_time_difference )); then
        convert_seconds_to_time "$difference"
      
        echo
        error_message "Bingo status: latest bingo happened at ${bold_text}${current_bingo} - ${formatted_time} ago!"
      
        if [ "$shard_status" = "ONLINE" ]; then
          error_message "Either the node hasn't been online for a while or something's wrong with your node configuration."
        else
          error_message "Your shard is currently down. Please check @harmonypangaea on Telegram or the Discord #pangaea channel for network updates."
        fi
      
      else
        success_message "Bingo status: latest bingo happened at ${bold_text}${current_bingo} (${difference} second(s) ago)${normal_text}"
      fi
    else
      success_message "Bingo status: latest bingo happened at ${bold_text}${current_bingo}${normal_text}"
    fi
  fi
  
  output_footer
}

check_transactions() {
  output_header "${header_index}. Transactions - checking transaction info for your node"
  ((header_index++))
  
  parse_pending_transactions
  
  if [ -z "$pending_transactions" ]; then
    error_message "Couldn't parse pending transactions from your zerolog!"
  else
    success_message "Your node has a total of ${pending_transactions} pending transactions"
  fi
  
  output_footer
}

check_wallet_balances() {
  output_header "${header_index}. Wallet - checking wallet balances for your node"
  ((header_index++))
  
  if [ "$wallet_script_installed" = true ] || [ "$wallet_binary_installed" = true ]; then
    cd $wallet_path; ./wallet.sh$network_switch balances; cd - 1> /dev/null 2>&1
  else
    error_message "Please make sure your wallet is configured correctly! Check the instructions in the previous sections!"
  fi
  
  output_footer
}

#
# Helper methods
#

parse_build_version() {
  mkdir -p ${cache_dir} 1> /dev/null 2>&1
  local build_file_name=${2}_build_version
  rm -rf ${cache_dir}/${build_file_name}
  LD_LIBRARY_PATH=${1} ${1}/${2} -version 1> ${cache_dir}/${build_file_name} 2>&1
  build=$(cat ${cache_dir}/${build_file_name})
}

parse_build_version_via_file_check() {
  build=`file ${1} | grep -oam 1 -E "BuildID\[sha1\]=[a-zA-Z0-9]+" | grep -oam 1 -E "=[a-zA-Z0-9]+" | sed s/=//`
}

# $1 is the path to look for the binary
# $2 is the binary name
determine_build() {
  read_integer_from_cache "${2}_modified_epoch"
  file_modification_date_in_epoch "${1}/${2}"
  write_to_cache "${2}_modified_epoch" "${file_epoch}"
  
  if (( file_epoch > cache_value )); then
    # Binary has been updated since the last cached value
    parse_build_version "${1}" "${2}"
  else
    read_from_cache "${2}_build_version"
    
    if [ -z "$cache_value" ]; then
      parse_build_version "${1}" "${2}"
    else
      build=$cache_value
    fi
  fi
}

parse_bootnodes() {
  bootnodes=($(ps aux | grep "[h]armony -bootnodes" | grep -oam 1 -E "\/ip4\/[0-9\.]*" | sed "s|/ip4/||g"))
}

parse_current_bingo() {
  parse_from_zerolog "bingo"
  
  if [ -z "$secondary_parsed_zerolog_value" ]; then
    current_bingo=$parsed_zerolog_value
    bingo_date_parsed=false
  else
    current_bingo=$secondary_parsed_zerolog_value
    bingo_date_parsed=true
  fi
}

parse_sync_status() {
  parse_from_zerolog "sync"
  current_sync_status=$parsed_zerolog_value
  
  if [ -z "$current_sync_status" ]; then
    node_synced=false
  else
    node_synced=true
  fi
}

parse_current_block() {
  parse_from_zerolog "block" "$shard"
  
  if [ ! -z "$parsed_zerolog_value" ]; then
    convert_to_integer "$parsed_zerolog_value"
    current_block=$converted
  fi
}

parse_pending_transactions() {
  parse_from_zerolog "pending_transactions"
  
  if [ ! -z "$parsed_zerolog_value" ]; then
    convert_to_integer "$parsed_zerolog_value"
    pending_transactions=$converted
  fi
}

parse_from_zerolog() {
  if ls $node_path/latest/zerolog*.log 1> /dev/null 2>&1; then
    case $1 in
    bingo)
      parsed_zerolog_value=`tac ${node_path}/latest/zerolog*.log | grep -am 1 "BINGO" | grep -oam 1 -E "\"time\":\"[^\"]+" | sed "s/\"time\":\"//"`
      secondary_parsed_zerolog_value=`echo ${parsed_zerolog_value} | sed "s/\..*//" | sed -e 's/T/ /g'`
      ;;
    block)
      if [ -z "$2" ]; then
        parsed_zerolog_value=`tac ${node_path}/latest/zerolog*.log | grep -oam 1 -E "\"(blockNumber|myBlock)\":[0-9\"]*" | grep -oam 1 -E "[0-9]+"`
      else
        parsed_zerolog_value=`tac ${node_path}/latest/zerolog*.log | grep -E "\"(blockShard)\":${2}" | grep -oam 1 -E "\"(blockNumber|myBlock)\":[0-9\"]*" | grep -oam 1 -E "[0-9]+"`
      fi
      ;;
    sync)
      parsed_zerolog_value=`tac ${node_path}/latest/zerolog*.log | grep -E "isBeacon: false" | grep -oaim 1 "Node is now IN SYNC!"`
      ;;
    pending_transactions)
      parsed_zerolog_value=`tac ${node_path}/latest/zero*.log | grep -oam 1 -E "\"totalPending\":[0-9]+" | grep -oam 1 -E "[0-9]+"`
      ;;
    error_messages)
      parsed_zerolog_value=`tac ${node_path}/latest/zero*.log | grep "level\":\"error\""`
      ;;
    *)
      ;;
    esac
  else
    error_message "Can't find ${node_path}/latest/zerolog*.log - are you sure you've entered the correct node path ($node_path)?"
  fi
}

parse_shard_id() {
  shard=`tac $node_path/latest/*.log | grep -oam 1 -E "\"([Ss]hardID)\":[0-3]" | grep -oam 1 -E "([0-3]+)"`
}

detect_shard_id() {
  if ls -d $node_path/harmony_db_* 1> /dev/null 2>&1; then
    shard=`ls -d ${node_path}/harmony_db_* | tail -1 | sed "s|${node_path}/||g" | cut -c12-`
  fi
}

# Remove later if newer detect_shard_id works correctly
deprecated_detect_shard_id() {
  possible_shard_ids=($(sudo ls -d ${node_path}/harmony_db_* | sed "s|${node_path}/harmony_db_||g"))
  
  for possible_shard in "${possible_shard_ids[@]}"; do
    convert_to_integer "$possible_shard"
    
    if [ -z "$shard" ]; then
      shard=$converted
    else
      if (( converted > shard )); then
        shard=$converted
      fi
    fi
  done
}

parse_network_shard_data() {
  shard_status=`echo ${1} | grep -oam 1 -E "Status is: (ONLINE|OFFLINE)" | grep -oam 1 -E "(ONLINE|OFFLINE)"`
  shard_data_updated_at=`echo ${1} | grep -oam 1 -E "\(Last updated:.*" | sed "s/(Last updated: //g"`
  
  current_network_block=`echo ${1} | grep -oam 1 -E "Block ([0-9]+)" | grep -oam 1 -E "[0-9]+"`
  convert_to_integer "$current_network_block"
  current_network_block=$converted
}

parse_timestamp() {
  timestamp=$(date -d "${1}" +"%s")
  timestamp=$((10#$timestamp))
}

parse_current_script_version() {
  mkdir -p $data_dir 1> /dev/null 2>&1
  
  if test -d $data_dir; then
    latest_script_file_name="latest_script.sh"
    latest_script_version=`rm -rf ${latest_script_file_name} && wget -q -O "${data_dir}/${latest_script_file_name}" $script_url && cat ${data_dir}/${latest_script_file_name} | grep -oam 1 -E "version=\"[^\"]+\"" | sed "s/version=\"//" | sed "s/\"//"`
    rm -rf "${data_dir}/${latest_script_file_name}"
  fi
}

convert_to_integer() {
  converted=$((10#$1))
}

convert_seconds_to_time() {
  formatted_time=$(printf '%dd:%dh:%dm:%ds\n' $(($1/86400)) $(($1%86400/3600)) $(($1%3600/60)) $(($1%60)))
}

calculate_difference() {
  difference=$(($1-$2))
}

identify_address() {
  read_from_cache "address"

  if [ -z "$cache_value" ]; then
    address=`cd $wallet_path; ./wallet.sh$network_switch list | grep -oam 1 -E "account: (one[a-z0-9]+)" | grep -oam 1 -E "one[a-z0-9]+"`
    write_to_cache "address" "${address}"
  else
    address=$cache_value
  fi
}

identify_base16_address() {
  read_from_cache "base16_address"

  if [ -z "$cache_value" ]; then
    base16_address=`cd $wallet_path; ./wallet.sh$network_switch format --address ${1} | grep -oam 1 -E "0x[a-zA-Z0-9]+"`
    write_to_cache "base16_address" "${base16_address}"
  else
    base16_address=$cache_value
  fi
}

check_bls_keyfile_status() {
  read_from_cache "bls_public_key"

  if [ -z "$cache_value" ]; then
    download_file "https://bit.ly" "pga-keys"
    bls_public_key=$(cat ${temp_dir}/pga-keys | grep "${1}" | grep -oam 1 -E "BlsPublicKey: \"[a-z0-9]+\"" | grep -oam 1 -E "\"[a-z0-9]+\"" | grep -oam 1 -E "[a-z0-9]+")
  
    if [ -z "$bls_public_key" ]; then
      # Occasionally the script can't download the key file, fallback to using the github url
      download_file "https://raw.githubusercontent.com/harmony-one/harmony/master/internal/genesis" "foundational_pangaea.go"
      bls_public_key=$(cat ${temp_dir}/foundational_pangaea.go | grep "${1}" | grep -oam 1 -E "BlsPublicKey: \"[a-z0-9]+\"" | grep -oam 1 -E "\"[a-z0-9]+\"" | grep -oam 1 -E "[a-z0-9]+")
    fi
    
    write_to_cache "bls_public_key" "${bls_public_key}"
  else
    bls_public_key=$cache_value
  fi
}

run_wallet_command() {
  wallet_output=`cd $wallet_path; ./wallet.sh$network_switch $1; cd - 1> /dev/null 2>&1`
}

file_modification_date() {
  file_date=$(date -r ${1})
}

file_modification_date_in_epoch() {
  file_epoch=$(date -r ${1} +%s)  
  convert_to_integer "$file_epoch"
  file_epoch=$converted
}

# $1 = the cache file to write to
# $2 = the value to write to the cache file
write_to_cache() {
  local file_path="${cache_dir}/${1}"
  mkdir -p ${cache_dir}
  rm -rf ${file_path}
  touch ${file_path}
  echo ${2} > ${file_path}
}

# $1 = the cache file to read from
read_from_cache() {
  local file_path="${cache_dir}/${1}"
  
  if test -f $file_path; then
    cache_value=$(cat ${file_path})
  else
    cache_value=""
  fi
}

read_integer_from_cache() {
  read_from_cache $1
  
  if [ ! -z "$cache_value" ]; then
    convert_to_integer "$cache_value"
    cache_value=$converted
  fi
}

log_error_messages_to_log_file() {
  if [ "$use_error_log" = true ]; then
    if [ "$node_running" = false ] || [ -z "$current_bingo" ] || [ -z "$reported_as_online" ] || [ "$shard_status" = "OFFLINE" ]; then
      parse_from_zerolog "error_messages"
  
      if [ ! -z "$parsed_zerolog_value" ]; then
        echo $parsed_zerolog_value > $error_log_file
      fi
    fi
  fi
}

download_file() {
  mkdir -p "${temp_dir}"
  rm -rf "${temp_dir}/${2}"
  full_url="${1%/}/${2}"
  
  if [ "$debug" = true ]; then
    echo "Downloading ${full_url} to ${temp_dir}/${2}"
  fi
  
  wget -q -O "${temp_dir}/${2}" $full_url
}

setup() {
  rm -rf $error_log_file
  mkdir -p $data_dir $cache_dir $temp_dir
}

cleanup() {
  if [ "$debug" = false ]; then
    rm -rf $temp_dir
  fi
}

# 
# Output methods
#
success_message() {
  echo ${green_text}${1}${normal_text}
}

warning_message() {
  echo ${yellow_text}${1}${normal_text}
}

error_message() {
  echo ${red_text}${1}${normal_text}
}

output_banner() {
  output_header "Running Harmony Mainnet/Pangaea Node Status v${version}"
  echo "You're running ${bold_text}${script_name}${normal_text} as ${bold_text}${executing_user}${normal_text} using the path ${bold_text}${current_dir}${normal_text}"
  
  if [ "$pangaea" = true ]; then
    echo "Checking status for the node using the ${bold_text}Pangaea network${normal_text}!"
  else
    echo "Checking status for the node using the ${bold_text}Mainnet${normal_text}!"
  fi
  
  current_time=`date`
  echo "Current time is: ${current_time}"
}

output_header() {
  echo
  output_separator
  echo "${bold_text}${1}${normal_text}"
  output_separator
  echo
}

output_footer() {
  echo
  output_separator
}

output_separator() {
  echo "------------------------------------------------------------------------"
}


#
# Main function
#
check_status() {
  setup
  output_banner
  
  check_version
  
  check_for_correct_installation
  check_wallet
  check_node
  check_sync_consensus_status
  
  if [ "$pangaea" = true ]; then
    check_network_status
  fi
  
  
  check_transactions
  check_wallet_balances
  
  log_error_messages_to_log_file
  
  cleanup
  header_index=1
}


#
# Program execution
#
if [ "$daemonize" = true ]; then
  # Run in an infinite loop
  while [ 1 ]
  do
    check_status
    sleep $interval
  done
else
  check_status
fi
