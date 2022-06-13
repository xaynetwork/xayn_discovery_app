# Migrate analytics events from Amplitude platform to Mixpanel platform

# Make sure to add .env file from 1password to migrate_amplitude_to_mixpanel directory

# First, install dependencies by running the following terminal command:
# $ pip install -r requirements.txt

# Then, Run the following on the terminal:
# $ python3 migrate_analytics.py --start="20220401T05" --end="20220409T20" 
# - Don't forget to replace --start and --end values with the desired duration
# - If you are running this for production, add --env="prod"

import argparse
import logging
import requests
import zipfile
from io import BytesIO
from typing import Dict
from time import sleep
import json
import gzip
from typing import Any, Mapping, Dict
from time import sleep
try:
    import json
except ImportError:
    import simplejson as json
from tqdm import tqdm
from datetime import timezone
import datetime
import os
from dotenv import load_dotenv

MIXPANEL_BATCH_SIZE = 1500

def process_event(event: Mapping[str, Any]) -> Dict:
    output = {}
    output["event"] = event["event_type"]
    output["properties"] = event["event_properties"]
    output["properties"]["$insert_id"] = event["$insert_id"]
    output["properties"]["distinct_id"] = event.get("user_id",  event["amplitude_id"])	        
    output["properties"]["$user_id"] = event.get("user_id",  event["amplitude_id"])	        
    output["properties"]["$manufacturer"] = event["device_manufacturer"]
    output["properties"]["$model"] = event["device_model"]
    output["properties"]["$os"] = event["platform"]
    output["properties"]["$carrier"] = event["device_carrier"]
    output["properties"]["$os_version"] = event["os_version"]
    output["properties"]["$app_version_string"] = event["version_name"]
    output["properties"]["$device_id"] = event["device_id"]
    
    try:
        event_time = datetime.datetime.strptime(event["event_time"], '%Y-%m-%d %H:%M:%S.%f')
    except Exception as _:
        event_time = datetime.datetime.strptime(event["event_time"], '%Y-%m-%d %H:%M:%S')
        
    timestamp = event_time.replace(tzinfo=timezone.utc).timestamp()
    output["properties"]["time"] = timestamp

    return output

def process_amplitude_data(zips: zipfile.ZipFile) -> list:
    processed_events = []
    raw = []
    for name in tqdm(zips.namelist()):
        with zips.open(name) as gf:
            with gzip.open(gf) as f:
                jsons = f.read().decode("utf-8").split("\n")
                jsons = [s for s in jsons if s != ""]
                raw.append(jsons)    
                for line in jsons:
                    event = json.loads(line)
                    processed_event = process_event(event)
                    processed_events.append(processed_event)   
    
    with open("raw_events.log", "w") as fp:
            fp.write(" {} ".format(raw))
            fp.close
                    
    with open("processed_events.log", "w") as fp:
            fp.write(" {} ".format(processed_events))
            fp.close
            
    return processed_events

def request_zips_from_amplitude(api_user: str, api_pwd: str, start: str, end: str) -> zipfile.ZipFile:
    url = "https://amplitude.com/api/2/export?start={}&end={}".format(start, end)
    r = requests.get(url, auth=(api_user, api_pwd))    
    zips = zipfile.ZipFile(BytesIO(r.content))
    return zips

def chunks(l, n):
    """Yield successive n-sized chunks from l."""
    for i in range(0, len(l), n):
        yield l[i:i + n]
        
def send_to_mixpanel(project_id: str, token:str, payload : Dict):
    url = "https://api-eu.mixpanel.com/import?strict=1&project_id={}".format(project_id)
    headers = {
        "Accept": "text/plain",
        "Content-Type": "application/json",
        "Authorization": "Basic {}".format(token)

    }
    response = requests.post(url, json=payload, headers=headers)
    logging.info(response.status_code)
    logging.info(response.content)

def send_all_events_to_mixpanel(project_id: str, token:str, payload : list):
    payload_chunks = list(chunks(payload, MIXPANEL_BATCH_SIZE))
    for chunk in payload_chunks:
        send_to_mixpanel(project_id, token, chunk)
    
def main():
    logging.basicConfig(filename="event_migration.log", level=logging.INFO, filemode="w")

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--start",
        type=str,
        help="batch start time in format %Y%m%dT%H, for example \"20220401T05\"",
        
    )

    parser.add_argument(
        "--end",
        type=str,
        help="batch end time in format %Y%m%dT%H, for example \"20220406T20\"",
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
        mixpanel_project_id = os.environ.get('MIXPANEL_PROJECT_ID_DEV')
    elif (args.env == 'prod'):
        amplitude_key = os.environ.get('AMPLITUDE_API_KEY_PROD')
        amplitude_secret = os.environ.get('AMPLITUDE_SECRET_PROD')
        mixpanel_project_id = os.environ.get('MIXPANEL_PROJECT_ID_PROD')
    else:
        raise Exception("--env should either be 'dev' or 'prod'")
    
    mixpanel_token = os.environ.get('MIXPANEL_TOKEN')

    zips = request_zips_from_amplitude(amplitude_key, amplitude_secret, args.start, args.end)
    processed_events = process_amplitude_data(zips)
    send_all_events_to_mixpanel(mixpanel_project_id, mixpanel_token, processed_events)

if __name__ == "__main__":
    main()
