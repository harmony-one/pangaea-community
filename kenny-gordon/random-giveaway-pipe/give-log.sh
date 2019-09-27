#!/bin/bash

# Author: Ken Gordon - https://github.com/kenny-gordon
#
# Contributors:
# Original author of random-giveaway.sh: Agx10k - https://github.com/AGx10k

# Log Transactions with prepended date for cross refrencing https://explorer.pangaea.harmony.one, for example: 
# "20/09/19-12:30:00 | Transaction Id for shard 2: 0xac3fda1f7a71238d3323a0314c457c164c0473cd30f6ca316c2643bf28829d56"

OS=$(uname -s)

# Show Harmony Wallet version
if [ "$OS" = "Linux" ]; then
    LD_LIBRARY_PATH=$(pwd) ./wallet -version 
else
    DYLD_FALLBACK_LIBRARY_PATH=$(pwd) ./wallet -version
fi 

# Run random-giveaway.sh
sudo ./random-giveaway.sh | tee /dev/stderr | grep -P --line-buffered "^.*\bTransaction Id for shard \b.*$" |\
(

  while read LINE
  do
        DATE=$(date +%m/%d/%y-%H:%M:%S)
    echo "$DATE | $LINE"
  done
) >> transactions.log
