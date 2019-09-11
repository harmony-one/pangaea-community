Shell script to send Transactions in Harmony's Pangaea phase II, it sends TX's to random online nodes in a loop every 10 seg.
<p>
you need to adjust the following:
- base ammount to send (0.001 as default)
- working directory (~ home as default)
- desired time frame (10 seg as default)
<p>
Steps to use this script:
- Create new tmux session: tmux new -s pangaea_phaseII
- exec: chmod +x send_tx.sh
- exec: ./send_tx.sh
- Press: CTRL + B release and Press D
