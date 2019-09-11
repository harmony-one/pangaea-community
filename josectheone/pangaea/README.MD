## About The Project

**Contribution to the community to easy the network testing process**

### Built With

* SHELL

## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

* curl
* jq
```sh
sudo apt install curl jq
```

### Installation

1. Download the script
```sh
wget https://raw.githubusercontent.com/josectheone/pangaea-community/master/josectheone/pangaea/send_tx.sh
```
2. Set execution flag
```sh
chmod +x send_tx.sh
```

## Usage

1. Create new tmux session: tmux new -s pangaea_phaseII
2. Run ./send_tx.sh
3. Press: CTRL + B release and Press D

# you can adjust the following:
* base ammount to send (0.001 as default)
* working directory (~ home as default)
* desired time frame (10 seg as default)
