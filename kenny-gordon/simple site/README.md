
# Simple Node Site 

## About 
Just a very quick and dirty site to view logs and check balances and online status.
There are a lot improvements that could be made, extra features added but this was all I needed to check basic information on my phone.
Feel free to improve it develop it maybe add a flat database and log information for when shards or json service is offline.

## Installation
This script should be installed on the server running the node. 

## Dependencies
A server like Apache, Nginx running the most up to date version of PHP.

**The output files from pangaea:**

***General Pages***  
1 hour: [https://harmony.one/pga/1h](https://harmony.one/pga/1h)  
4 hours: [https://harmony.one/pga/4h](https://harmony.one/pga/4h)  
24 hours: [https://harmony.one/pga/24h](https://harmony.one/pga/24h)  
Total balance: [https://harmony.one/pga/balances](https://harmony.one/pga/balances)  

## Configuration:
The default login credentials are below but they can be changed by editing the login.php page.  

***Username:*** pangaea  
***Password:*** pangaea  

Set the Path to your Node by editing output.php, This should be the directory which your harmony files are installed.

    $node_path = '/root';

 ![alt text](https://raw.githubusercontent.com/kenny-gordon/pangaea-community/patch-1/kenny-gordon/simple%20site/Shard_Status.jpg)  
 
 ![alt text](https://raw.githubusercontent.com/kenny-gordon/pangaea-community/patch-1/kenny-gordon/simple%20site/Log_Feed.jpg)  
 
 ![alt text](https://raw.githubusercontent.com/kenny-gordon/pangaea-community/patch-1/kenny-gordon/simple%20site/Balance.jpg)  
