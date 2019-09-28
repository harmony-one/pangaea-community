# Installation

1) Check out the code to the same folder your wallet.sh is located in.
    ```
    git clone https://github.com/harmony-one/pangaea-community.git

    ```
    
2) Go into tmux and turn off node.sh if its currently running using CTRL+C


3) From the folder where your node.sh file is located run setup.sh:
    ```
    sudo ./pangaea-community/MikeHibbert/version_monitor/setup.sh
    ```
    
4) while the version monitor is in beta you can turn it off using:
   ```
   sudo supervisorctl stop pangaea_version_monitor
   
   or to start use:

   sudo supervisorctl start pangaea_version_monitor
   ```


## NOTES:
To stop your node you will need to run:

   ```
   sudo supervisorctl stop pangaea_node
   ```

To start the node after manually stopping:
   ```
   sudo supervisorctl start pangaea_node
   ```

Whilst the version monitor is currently in beta you can still use the node uptime process in supervisor to maintain your node and evertime you restart your server or it gets rebooted for any reason it will automatically start your node for you.


    
