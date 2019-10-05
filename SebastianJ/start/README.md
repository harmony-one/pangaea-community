# start.sh - wrapper script to make sure only one Harmony process is running

## Installation

`sudo rm -rf start.sh && sudo wget -q https://raw.githubusercontent.com/harmony-one/pangaea-community/master/SebastianJ/start/start.sh && sudo chmod u+x start.sh`

## Usage

Use the exact parameters you normally use for node.sh, e.g:

```
./start.sh -t
```

start.sh will make sure that only one Harmony process is running and instead of launching additional processes it'll simply output:

*You're already running a harmony/node process. Please stop the current process using sudo pkill harmony && sudo pkill node.sh*