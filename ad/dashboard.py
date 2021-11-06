import schedule
import time
import requests
import json
import random
from datetime import datetime

def job():
    ue_name=['Car-4','Car-3','Car-2']
    du_name=['1001','1002','1003']
    degradation=['RSRP','RSSINR','prb_usage']

    ThingName="GET_JSON_FROM_PYTHON"
    ServiceName="Upload"
    Appkey="df1cc9da-e434-411f-88b6-d801e64392f6" 
    # Appkey is from thingworx, for accessing thingworx key
    
    pre_url = 'https://smartcampus.et.ntust.edu.tw:5021/Thingworx/Things/'
    url = pre_url + ThingName + '/Services/' + ServiceName
    payload={
        "UE" : random.choice(ue_name),
        "DU": random.choice(ue_name),
        "Degradation": random.choice(degradation),
        "UploadTime": datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    }
    headers={
        "appKey": Appkey,
        "Content-Type": "application/json"
    }
    r= requests.put(url, data=json.dumps(payload), headers=headers)
    print(r.content)

def main():
    schedule.every(10).seconds.do(job)

    while True:
        schedule.run_pending()
        time.sleep(1)

if __name__ == '__main__':
    main()