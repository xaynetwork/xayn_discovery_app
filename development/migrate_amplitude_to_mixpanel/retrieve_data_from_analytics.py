# try with distinctId = 65716c30-db0b-4f32-a1cb-37acdc53ecab for (dev) project
# $ python3 retrieve_data_from_analytics.py --distinctId="65716c30-db0b-4f32-a1cb-37acdc53ecab" --env="dev" --start="20220412T00" --end="20220414T00"


# This script gets the last event for a distinctId user from Amplitude (within the range: "20220414T00", "20220416T00")
# then it retrieves the user profile from mixpanel
# then it gets the same event (with the same insertId) from mixpanel
# All the data is outputed in one file: `user_retrieved.log`

import argparse
import gzip
import logging
import requests
import zipfile
from io import BytesIO, TextIOWrapper

try:
    import json
except ImportError:
    import simplejson as json
from tqdm import tqdm
import os
from dotenv import load_dotenv


def format_date(d: str) -> str:
    return '-'.join([d[:4], d[4:6], d[6:8]])


def get_user_profile_from_mixpanel(project_id: str, distinct_id: list, token: str,
                                   log: TextIOWrapper):
    url = "https://eu.mixpanel.com/api/2.0/engage?project_id={}".format(project_id)
    payload = "distinct_id={}".format(distinct_id)
    headers = {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Basic {}".format(token)
    }

    response = requests.post(url, data=payload, headers=headers)

    log.write("USER PROFILE FROM MIXPANEL: {} ".format(response.text))


def get_event_from_mixpanel(project_id: str, insert_id: str, token: str, log: TextIOWrapper,
                            from_date: str, to_date: str):
    url = "https://data-eu.mixpanel.com/api/2.0/export?from_date={}&to_date={}&project_id={}&where=properties%5B%22%24insert_id%22%5D%20%3D%3D%20%22{}%22".format(
        from_date, to_date, project_id, insert_id)
    headers = {
        "Accept": "text/plain",
        "Authorization": "Basic {}".format(token)
    }
    response = requests.get(url, headers=headers)
    log.write("\nEVENT FROM MIXPANEL: {} ".format(response.text))


def request_zips_from_amplitude(api_user: str, api_pwd: str, start: str,
                                end: str) -> zipfile.ZipFile:
    url = "https://amplitude.com/api/2/export?start={}&end={}".format(start, end)
    r = requests.get(url, auth=(api_user, api_pwd))
    zips = zipfile.ZipFile(BytesIO(r.content))
    return zips


def process_amplitude_data(zips: zipfile.ZipFile, distinct_id: str, log: TextIOWrapper) -> str:
    for name in tqdm(zips.namelist()):
        with zips.open(name) as gf:
            with gzip.open(gf) as f:
                jsons = f.read().decode("utf-8").split("\n")
                jsons = [s for s in jsons if s != ""]
                for line in reversed(jsons):
                    event = json.loads(line)
                    event_distinct_id = event.get("user_id", event["amplitude_id"])
                    if (event_distinct_id == distinct_id):
                        log.write("\nLAST EVENT FROM AMPLITUDE: {} ".format(event))
                        return event['$insert_id']


def main():
    logging.basicConfig(filename="retrieve.log", level=logging.INFO, filemode="w")

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--distinctId",
        type=str,
    )

    parser.add_argument(
        "--env",
        type=str,
        help="environment key, could be 'dev' or 'prod'",
        default='dev',
    )

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

    args = parser.parse_args()

    load_dotenv()

    if (args.env == 'dev'):
        amplitude_key = os.environ.get('AMPLITUDE_API_KEY_DEV')
        amplitude_secret = os.environ.get('AMPLITUDE_SECRET_DEV')
        mixpanel_project_id = os.environ.get('MIXPANEL_PROJECT_ID_DEV')
    elif (args.env == 'prod'):
        amplitude_key = os.environ.get('AMPLITUDE_API_KEY_PROD')
        amplitude_secret = os.environ.get('AMPLITUDE_SECRET_PROD')
        mixpanel_project_id = os.environ.get('MIXPANEL_PROJECT_ID_PROD')
    else:
        raise Exception("--env should either be 'dev' or 'prod'")

    mixpanel_service_token = os.environ.get('MIXPANEL_SERVICE_TOKEN')

    distinct_id = args.distinctId

    with open("user_retrieved.log", "w") as log:
        get_user_profile_from_mixpanel(mixpanel_project_id, distinct_id, mixpanel_service_token,
                                       log)
        zips = request_zips_from_amplitude(amplitude_key, amplitude_secret, args.start, args.end)
        event_insert_id = process_amplitude_data(zips, distinct_id, log)
        get_event_from_mixpanel(mixpanel_project_id, event_insert_id, mixpanel_service_token, log,
                                format_date(args.start), format_date(args.end))
        log.close


if __name__ == "__main__":
    main()
