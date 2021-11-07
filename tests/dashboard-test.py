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

    ThingName="jojo_datatable"
    ServiceName="Upload"
    Appkey="bb3dd7bc-79e3-4c63-a223-8ccf8bd84380" 
    # Appkey is from thingworx, for accessing thingworx key
    
    pre_url = 'https://140.118.122.115:5033/Thingworx/Things/'
    # url = pre_url + ThingName + '/Services/' + ServiceName
    url=pre_url+ThingName+'/Services/'+ServiceName
    print(datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    payload={
        "UE" : random.choice(ue_name),
        "DU": random.choice(du_name),
        "Degradation": random.choice(degradation),
        "Timestamp": datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    }
    headers={
        "appKey": Appkey,
        "Content-Type": "application/json"
    }
    r= requests.put(url, data=json.dumps(payload), headers=headers, verify=False)
    print(r.content)

def main():
    schedule.every(5).seconds.do(job)

    while True:
        schedule.run_pending()
        time.sleep(1)

if __name__ == '__main__':
    main()