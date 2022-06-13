# Migrate analytics events from Amplitude platform to Mixpanel platform

# Make sure to add .env file from 1password to migrate_amplitude_to_mixpanel directory

# First, install dependencies by running the following terminal command:
# $ pip install -r requirements.txt

# Then, Run the following on the terminal:
# $ python3 migrate_analytics_profiles.py --start="20220401T05"
# - Don't forget to replace --start value with the desired duration
# - If --end is not provided, it's set to the current time which should be the case since you want the latest user profiles
# - If you are running this for production, add --env="prod"

import argparse
import gzip
import logging
import requests
import zipfile
from io import BytesIO
from typing import Dict

try:
    import json
except ImportError:
    import simplejson as json
from tqdm import tqdm
import datetime
import os
from dotenv import load_dotenv

MIXPANEL_BATCH_SIZE = 200

def process_event(profiles_dict: Dict, event: Dict) -> Dict:
    user_properties  = event["user_properties"]
    id = event.get("user_id",  event["amplitude_id"])
    
    if id in profiles_dict or not event["user_properties"]:
        return profiles_dict
    
    output = {}    
    output["$set_once"] = user_properties
    output["$distinct_id"] = id
    
    profiles_dict[id] = output
    
    return profiles_dict

def process_amplitude_data(zips: zipfile.ZipFile) -> list:
    raw = []
    distinct_id_profile_map = dict()
    
    most_recent_first_zip_list = tqdm(reversed(zips.namelist()))
    for name in most_recent_first_zip_list:
        with zips.open(name) as gf:
            with gzip.open(gf) as f:
                jsons = f.read().decode("utf-8").split("\n")
                jsons = [s for s in jsons if s != ""]
                raw.append(jsons)    
                for line in jsons:
                    event = json.loads(line)
                    distinct_id_profile_map = process_event(distinct_id_profile_map, event)
                    

    with open("processed_user_profiles.log", "w") as fp:
            fp.write(" {} ".format(distinct_id_profile_map))
            fp.close

    return list(distinct_id_profile_map.values())

def request_zips_from_amplitude(api_user: str, api_pwd: str, start: str, end: str) -> zipfile.ZipFile:
    url = "https://amplitude.com/api/2/export?start={}&end={}".format(start, end)
    r = requests.get(url, auth=(api_user, api_pwd))    
    zips = zipfile.ZipFile(BytesIO(r.content))
    return zips

def chunks(l, n):
    """Yield successive n-sized chunks from l."""
    for i in range(0, len(l), n):
        yield l[i:i + n]
        
def send_to_mixpanel(token:str, payload : list):
    url = "https://api-eu.mixpanel.com/engage?verbose=1#profile-set-once"

    for i in range(len(payload)):
        payload[i]["$token"] = token
        
    headers = {
        "Accept": "text/plain",
        "Content-Type": "application/json"
    }
        
    response = requests.post(url, json=payload, headers=headers)
    logging.info(response.text)
    logging.info(response.status_code)
    logging.info(response.content)
    
def send_all_events_to_mixpanel(token:str, payload : list):
    payload_chunks = list(chunks(payload, MIXPANEL_BATCH_SIZE))
    for chunk in payload_chunks:
        send_to_mixpanel( token, chunk)

def main():
    logging.basicConfig(filename="user_profile_migration.log", level=logging.INFO, filemode="w")

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--start",
        type=str,
        help="batch start time in format %Y%m%dT%H, for example \"20220401T05\"",   
    )
    
    parser.add_argument(
        "--end",
        type=str,
        help="Batch end time in format %Y%m%dT%H. If not provided, it's set to the current time. for example \"20220406T20\"",
        default = datetime.datetime.now().strftime("%Y%m%dT%H"),
    )

    parser.add_argument(
        "--env",
        type=str,
        help="environment key, could be 'dev' or 'prod'",
        default='dev',
    )

    args = parser.parse_args()
    
    load_dotenv()
    
    if(args.env == 'dev'):
        amplitude_key = os.environ.get('AMPLITUDE_API_KEY_DEV')
        amplitude_secret = os.environ.get('AMPLITUDE_SECRET_DEV')
    elif (args.env == 'prod'):
        amplitude_key = os.environ.get('AMPLITUDE_API_KEY_PROD')
        amplitude_secret = os.environ.get('AMPLITUDE_SECRET_PROD')
    else:
        raise Exception("--env should either be 'dev' or 'prod'")
    
    mixpanel_token = os.environ.get('MIXPANEL_TOKEN')
    
    zips = request_zips_from_amplitude(amplitude_key, amplitude_secret, args.start, args.end)
    
    processed_user_data = process_amplitude_data(zips)
    send_all_events_to_mixpanel(mixpanel_token, processed_user_data)

if __name__ == "__main__":
    main()
