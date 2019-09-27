import boto3
import settings
import json
import os
import arrow
import subprocess
import requests
import logging

logger = logging.getLogger(__name__)


def get_s3_bucket():
    s3 = boto3.resource('s3')
    bucket = s3.Bucket(settings.HARMONY_BUCKET)
    
    return s3, bucket

def get_current_files():
    s3, bucket = get_s3_bucket()
    
    files = []    
    for obj in bucket.objects.all():
        files.append(
            {
                "name": obj.key,
                "size": obj.size,
                "last_modified": arrow.get(obj.last_modified).timestamp
            }
        )   
        
    return files

def get_file_from_bucket(filename, alt_filename_name=None):   
    download_filename = filename
    
    if alt_filename_name:
        download_filename = alt_filename_name
        
    command_args = [
        "curl", "-sSf", 
        "http://{}.s3.amazonaws.com/{}{}".format(settings.HARMONY_BUCKET, settings.RELEASE, filename), 
        "-o", 
        "{}".format(download_filename)
    ]
    
    os.chdir(settings.BASE_DIR)
        
    output = subprocess.check_output(command_args)
        
    logger.debug(output)      

    
def get_md5_checksum():
    get_file_from_bucket("md5sum.txt", 'md5sum.txt.new')    
    

def write_status_file(files):
    with open(os.path.join(settings.BASE_DIR, 'pangaea_version_monitor', 'status.one'), "w") as status_file:
        status_file.write(json.dumps(files))        
        
        
class StatusFileNotFoundException(Exception):
    message = "Status file {} not found".format(os.path.join(settings.BASE_DIR, 'pangaea_version_monitor', 'status.one'))
    
    
def start_node():
    logging.info("Starting node")
    
    call_supervisord("start")


def stop_node():
    logging.info("Stopping node")
    
    call_supervisord("stop")
    
    
def download_new_code():
    logging.info("Downloading new code...")
    
    os.chdir(settings.BASE_DIR)
    
    if os.path.exists(os.path.join(settings.BASE_DIR, 'node.sh')):
        os.remove(os.path.join(settings.BASE_DIR, 'node.sh'))
        
        # r = requests.get("https://raw.githubusercontent.com/harmony-one/harmony/master/scripts/node.sh")
        
    command_args = [
        "wget", 
        "https://raw.githubusercontent.com/harmony-one/harmony/master/scripts/node.sh"
    ]
    
    output = subprocess.check_output(command_args)
            
    logger.debug(output)    
    
    command_args = [
        "chmod", "+x", 
        "node.sh"
    ]
    
    output = subprocess.check_output(command_args)
            
    logger.debug(output)          
        
     
    for filename in settings.NODE_FILES:
        logger.debug("Downloading {}".format(filename))
        
        command_args = [
            'curl',  '-sSf',
            'http://{}.s3.amazonaws.com/{}{}'.format(settings.HARMONY_BUCKET, settings.RELEASE, filename),
            '-o',
            filename
        ]
        
        output = subprocess.check_output(command_args)
        
        logger.debug(output)                
    
    
def call_supervisord(command):
    command_args = [
        "supervisorctl", command, "pangaea_node"
    ]
    
    output = subprocess.check_output(command_args)
    
    logger.debug(output)


