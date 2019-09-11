#!/bin/bash

# Harmony Mainnet/Pangaea Node Status
version="0.1.2"

# Author: Sebastian Johnsson - https://github.com/SebastianJ
#
# Contributors:
# Script/binaries last modified date: Sophoah - https://github.com/sophoah
#

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
   -z           enable debug mode
   -h           print this help
EOT
}

while getopts "n:w:i:c:s:dtmfzh" opt; do
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

# Interval between checking node status
# E.g: 30s => 30 seconds, 1m => 1 minute, 1h => 1 hour
if [ -z "$interval" ]; then
  interval=1m
fi

executing_user=`whoami`

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

if [ -z "$debug" ]; then
  debug=false
fi

temp_dir="node_status"

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
check_for_correct_installation() {
  output_header "${header_index}. Installation - checking that your installation is correct"
  ((header_index++))
  
  if ls $node_path/*.key 1> /dev/null 2>&1; then
    success_message "BLS file detected in correct location: ${bold_text}YES${normal_text}"
  else
    error_message "BLS file detected in correct location: ${bold_text}NO${normal_text}"
  fi
  
  if test -f $node_path/node.sh; then
    node_script_installed=true
    file_modification_date "${node_path}/node.sh"
    success_message "node.sh installed: ${bold_text}YES (Last modified: ${file_date})${normal_text}"
  else
    error_message "node.sh installed: ${bold_text}NO${normal_text}"
    error_message "Are you sure you've entered the correct node path ($node_path) and that you've installed node.sh?"
  fi
  
  if test -f $node_path/harmony; then
    node_binary_installed=true
    file_modification_date "${node_path}/harmony"
    success_message "node binary installed: ${bold_text}YES (Last modified: ${file_date})${normal_text}"
  else
    echo
    error_message "node binary installed: ${bold_text}NO${normal_text}"
    error_message "Are you sure you've entered the correct node path ($node_path) and that you've installed the node binary ($node_path/harmony)?"
  fi
  
  if test -f $wallet_path/wallet.sh; then
    wallet_script_installed=true
    file_modification_date "${wallet_path}/wallet.sh"
    success_message "wallet.sh installed: ${bold_text}YES (Last modified: ${file_date})${normal_text}"
  else
    echo
    error_message "wallet.sh installed: ${bold_text}NO${normal_text}"
    error_message "Are you sure you've entered the correct wallet path ($wallet_path) and that you've installed wallet.sh?"
  fi
  
  if test -f $wallet_path/wallet; then
    wallet_binary_installed=true
    file_modification_date "${wallet_path}/wallet"
    success_message "wallet binary installed: ${bold_text}YES (Last modified: ${file_date})${normal_text}"
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
    
  check_bls_keyfile_status "${address}"
  
  if [ -z "$bls_public_key" ]; then
    error_message "Couldn't find your node's address in the bls public key list on https://bit.ly/pga-keys - are you sure that you are using a correct bls key file?"
    error_message "Please contact an admin on https://t.me/harmonypangaea or in the Discord #pangaea channel."
  else
    success_message "Your node is running using the bls public key: ${bold_text}${bls_public_key}${normal_text}"
  fi
  
  if ps aux | grep '[h]armony -bootnodes' | grep 54.86.126.90 > /dev/null; then
    success_message "Node is running and using the latest bootnodes: ${bold_text}YES${normal_text}"
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
      error_message "Please start your node as soon as possible: cd ${node_path}; ./node.sh${network_switch} (don't forget to run the command in tmux if you're using tmux)"
    fi
  fi
  
  if ls $node_path/latest/zerolog*.log 1> /dev/null 2>&1; then
    parse_shard_id
    
    if [ -z "$shard" ]; then
      error_message "Can't determine your shard id - can't parse your shard id from latest/zerolog*.log."
      error_message "There might be network issues - please check https://t.me/harmonypangaea or the Discord #pangaea channel for network updates."
    else
      success_message "Detected shard: ${bold_text}${shard}${normal_text}"
    fi
  else
    error_message "Can't determine your shard id - can't find $node_path/latest/zerolog*.log"
  fi
  
  output_footer
}

check_network_status() {
  output_header "${header_index}. Network status - checking network status for your shard and node"
  ((header_index++))
  
  pangaea_status_url="https://harmony.one/pga"
  download_file "$pangaea_status_url" "network"
  
  if [ -f "${temp_dir}/network" ]; then
    success_message "Successfully fetched the network status from ${full_url} - last network update: ${bold_text}${network_time}${normal_text}"
    echo

    echo "${bold_text}Shard status:${normal_text}"
    
    if [ -z "$shard" ]; then
      error_message "Can't determine your shard id. There might be issues with your node or the entire network."
      error_message "Outputting all shard statuses below:"
      echo 
      cat ${temp_dir}/network | grep -A 5 'SHARD STATUS'
    else
      shard_data=$(cat ${temp_dir}/network | grep -i -m 1 "Shard $shard")
  
      if [ -z "$shard_data" ]; then
        error_message "Couldn't download the network file from ${full_url}"
      else
        shard_status=`echo $shard_data | grep -oam 1 -E "Status is: (ONLINE|OFFLINE)" | grep -oam 1 -E "(ONLINE|OFFLINE)"`
        network_time=`echo $shard_data | grep -oam 1 -E "\(Last updated:.*" | sed "s/(Last updated: //g"`
        network_time="${network_time%)}"
    
        if [ "$shard_status" = "ONLINE" ]; then
          current_network_block=`echo $shard_data | grep -oam 1 -E "Block ([0-9]+)" | grep -oam 1 -E "[0-9]+"`
          convert_to_integer "$current_network_block"
          current_network_block=$converted
          success_message "Shard ${bold_text}${shard}${normal_text}${green_text} is: ${bold_text}${shard_status}${normal_text}"
          success_message "Your shard's latest recorded block is: ${bold_text}${current_network_block}${normal_text}"
        else
          error_message "Shard ${bold_text}${shard}${normal_text}${red_text} is: ${bold_text}${shard_status}${normal_text}"
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
          error_message "If this issue continues after the next network status update (usually happens within the next 15-30 minutes) there might be a misconfigured or erronous internal node running your address."
          error_message "Please report your address ${address} to the support representatives on https://t.me/harmonypangaea or in the Discord #pangaea channel."
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
          error_message "Your shard is currently down. Please check https://t.me/harmonypangaea or the Discord #pangaea channel for network updates."
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
    error_message "There might be network issues - please check https://t.me/harmonypangaea or the Discord #pangaea channel for network updates."
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
          error_message "Your shard is currently down. Please check https://t.me/harmonypangaea or the Discord #pangaea channel for network updates."
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
  parse_from_zerolog "block"
  current_block=$parsed_zerolog_value
  convert_to_integer "$current_block"
  current_block=$converted
}

parse_from_zerolog() {
  if ls $node_path/latest/zerolog*.log 1> /dev/null 2>&1; then
    case $1 in
    bingo)
      parsed_zerolog_value=`tac ${node_path}/latest/zerolog*.log | grep -am 1 "BINGO" | grep -oam 1 -E "\"time\":\"[^\"]+" | sed "s/\"time\":\"//"`
      secondary_parsed_zerolog_value=`echo ${parsed_zerolog_value} | sed "s/\..*//" | sed -e 's/T/ /g'`
      ;;
    block)
      parsed_zerolog_value=`tac ${node_path}/latest/zerolog*.log | grep -oam 1 -E "\"(blockNumber|myBlock)\":[0-9\"]*" | grep -oam 1 -E "[0-9]+"`
      ;;
    sync)
      parsed_zerolog_value=`tac ${node_path}/latest/zerolog*.log | grep -oam 1 -E "\"(blockNumber|myBlock)\":[0-9\"]*" | grep -oam 1 -E "\"myBlock\":[0-9\"]*"`
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

parse_timestamp() {
  timestamp=$(date -d "${1}" +"%s")
  timestamp=$((10#$timestamp))
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
  address=`cd $wallet_path; ./wallet.sh$network_switch list | grep -oam 1 -E "account: (one[a-z0-9]+)" | grep -oam 1 -E "one[a-z0-9]+"`
  cd - 1> /dev/null 2>&1
}

identify_base16_address() {
  base16_address=`cd $wallet_path; ./wallet.sh$network_switch format --address ${1} | grep -oam 1 -E "0x[a-zA-Z0-9]+"`
  cd - 1> /dev/null 2>&1
}

check_bls_keyfile_status() {
  download_file "https://bit.ly" "pga-keys"
  bls_public_key=$(cat ${temp_dir}/pga-keys | grep "${1}" | grep -oam 1 -E "BlsPublicKey: \"[a-z0-9]+\"" | grep -oam 1 -E "\"[a-z0-9]+\"" | grep -oam 1 -E "[a-z0-9]+")
  
  if [ -z "$bls_public_key" ]; then
    # Occasionally the script can't download the key file, fallback to using the github url
    download_file "https://raw.githubusercontent.com/harmony-one/harmony/master/internal/genesis" "foundational_pangaea.go"
    bls_public_key=$(cat ${temp_dir}/foundational_pangaea.go | grep "${1}" | grep -oam 1 -E "BlsPublicKey: \"[a-z0-9]+\"" | grep -oam 1 -E "\"[a-z0-9]+\"" | grep -oam 1 -E "[a-z0-9]+")
  fi
}

run_wallet_command() {
  wallet_output=`cd $wallet_path; ./wallet.sh$network_switch $1; cd - 1> /dev/null 2>&1`
}

file_modification_date() {
  file_date=$(date -r ${1})
}

download_file() {
  mkdir -p $temp_dir
  rm -rf "${temp_dir}/${2}"
  full_url="${1%/}/${2}"
  
  if [ "$debug" = true ]; then
    echo "Downloading ${full_url} to ${temp_dir}/${2}"
  fi
  
  wget -q -O "${temp_dir}/${2}" $full_url
}

setup() {
  mkdir -p $temp_dir
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

error_message() {
  echo ${red_text}${1}${normal_text}
}

output_banner() {
  output_header "Running Harmony Mainnet/Pangaea Node Status v${version}"
  echo "You're running as: ${bold_text}${executing_user}${normal_text}"
  
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
  echo "--------------------------------------------------------------"
}


#
# Main function
#
check_status() {
  setup
  output_banner
  
  check_for_correct_installation
  check_wallet
  check_node
  
  if [ "$pangaea" = true ]; then
    check_network_status
  fi
  
  check_sync_consensus_status
  check_wallet_balances
  
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
