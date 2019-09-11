Shell script to send Transactions in Harmony's Pangaea phase II <br><br>
It sends TX's to random online nodes in a loop every 10 seg<br>
you need to adjust the following:<br>
- base ammount to send (0.001 as default)
- working directory (~ home as default)
- desired time frame (10 seg as default)<br>
Steps to use<br>
- Create new tmux session: tmux new -s pangaea_phaseII
- exec: chmod +x send_tx.sh
- exec: ./send_tx.sh
- Press: CTRL + B release and Press D
