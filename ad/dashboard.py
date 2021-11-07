import requests
import json

def upload_to_dashboard(ue_name, du_name, degradation, timestamp):
    ThingName="jojo_datatable"
    ServiceName="Upload"
    Appkey="bb3dd7bc-79e3-4c63-a223-8ccf8bd84380" 
    # Appkey is from thingworx, for accessing thingworx key
    
    pre_url = 'https://140.118.122.115:5033/Thingworx/Things/'
    # url = pre_url + ThingName + '/Services/' + ServiceName
    url=pre_url+ThingName+'/Services/'+ServiceName
    payload={
        "UE" : ue_name,
        "DU": du_name,
        "Degradation": degradation,
        "Timestamp": timestamp
    }
    headers={
        "appKey": Appkey,
        "Content-Type": "application/json"
    }
    r= requests.put(url, data=json.dumps(payload), headers=headers, verify=False)
    print('\n')
    print(r.content)
    print('\n')