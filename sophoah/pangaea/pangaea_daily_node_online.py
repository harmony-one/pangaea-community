#!/bin/python

import json
import requests
import datetime
import os.path

# function to get unique values in a list and returns it
def unique(list1):       
    # insert the list to the set 
    list_set = set(list1) 
    # convert the set to the list 
    unique_list = (list(list_set)) 
    return unique_list 


#determine file of the day
date_today = datetime.date.today()
filename=date_today.strftime('%Y-%m-%d')+"-OnlineNode.json"


if os.path.exists(filename): #testing if day stats file exist
    with open(filename, 'r') as f:
        day_stat = json.load(f)
else: #if file doesn't exist get the latest one from the network monitoring page 
    try: #loading today network status file
        response = requests.get("https://harmony.one/pga/network.json")
        with open(filename, 'w') as f: #and the save for next iteration
            f.write(response.text)
    except: 
        exit(1)  #something went wrong when loading the file 
    exit(0) #we do not need to continue below as there were no day stats before

#load the latest network update
try:
    response = requests.get("https://harmony.one/pga/network.json")
    now_stat = json.loads(response.text)
except: 
    exit(1)

for shardid in ['0', '1', '2', '3']:
    day_stat['shards'][shardid]['nodes']['online']
    #capturing day online nodes on shard shardid
    dayonlinelist = day_stat['shards'][shardid]['nodes']['online']
    dayonlinelist.sort()
    #capturing now online nodes on shard shardid
    nowonlinelist =  now_stat['shards'][shardid]['nodes']['online']
    nowonlinelist.sort()
    #combining the two online list of nodes and remove the redundant
    newdaylist = unique(dayonlinelist + nowonlinelist)
    #updating the day stats
    day_stat['shards'][shardid]['nodes']['online'] = newdaylist
    #print day_stats

# Writing JSON data
with open(filename, 'w') as f: #and the save for next iteration
    f.write(json.dumps(day_stat, indent=4, sort_keys=True))
