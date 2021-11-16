#!/bin/bash

AD="0.0.2"

# -----------------------------------
echo "===>  Built the images of xApps"
cd ~
git clone "https://github.com/jojowei-cooler/ad.git" -b master
cd ad
docker build -t jojowei/test-ad:${AD} .
cd ~

# -----------------------------------
echo "===>  On-boarding xApps"
export Service_onboarder=$(kubectl get services -n ricplt | grep "\-onboarder-http" | cut -f1 -d ' ')
export Onboarder_IP=$(kubectl get svc ${Service_onboarder} -n ricplt -o yaml | grep clusterIP | awk '{print $2}')
export CHART_REPO_URL=http://${Onboarder_IP}:8080

dms_cli onboard --config_file_path=ad/xapp-descriptor/config.json --shcema_file_path=ad/xapp-descriptor/controls.json

# -----------------------------------
echo "======> Listing the xapp helm chart"
curl -X GET http://${Onboarder_IP}:8080/api/charts | jq .


sleep 5

# -----------------------------------
echo "===>  Deploying xApps"
dms_cli install --xapp_chart_name=ad --version=0.0.2 --namespace=ricxapp

sleep 90
# -----------------------------------
echo "===>  Checking the pods of xApps"
kubectl get pod -n ricxapp

# -----------------------------------
echo "===>  Registering xApps"

export Service_appmgr=$(kubectl get services -n ricplt | grep "\-appmgr-http" | cut -f1 -d ' ')
export Appmgr_IP=$(kubectl get svc ${Service_appmgr} -n ricplt -o yaml | grep clusterIP | awk '{print $2}')

export Service_AD=$(kubectl get services -n ricxapp | grep "\-ad\-" | cut -f1 -d ' ')
export AD_IP=$(kubectl get svc ${Service_AD} -n ricxapp -o yaml | grep clusterIP | awk '{print $2}')

curl -X POST "http://${Appmgr_IP}:8080/ric/v1/register" -H 'accept: application/json' -H 'Content-Type: application/json' -d '{
  "appName": "ad",
  "appVersion": "0.0.2",
  "appInstanceName": "ad",
  "httpEndpoint": "",
  "rmrEndpoint": "${AD_IP}:4560",
  "config": " {\n    \"name\": \"ad\",\n    \"version\": \"0.0.2\",\n    \"containers\": [{\"image\":{\"name\":\"docker.io\",\"registry\":\"jojowei/test-ad\",\"tag\":\"0.0.2\"},\"name\":\"ad\"}],\n    \"messaging\": {\n        \"ports\": [{\"container\":\"ad\",\"description\":\"rmr receive data port for ad\",\"name\":\"rmr-data\",\"policies\":[],\"port\":4560,\"txMessages\":[\"TS_ANOMALY_UPDATE\"],\"rxMessages\":[\"TS_ANOMALY_ACK\"]},{\"container\":\"ad\",\"description\":\"rmr route port for ad\",\"name\":\"rmr-route\",\"port\":4561}]\n    },\n    \"rmr\": {\n        \"protPort\": \"tcp:4560\",\n        \"maxSize\": 2072,\n        \"numWorkers\": 1,\n        \"rxMessages\": [\"TS_ANOMALY_ACK\"],\n        \"txMessages\": [\"TS_ANOMALY_UPDATE\"],\n        \"policies\": []\n    },\n    \"controls\": {\n        \"fileStrorage\": false\n    },\n    \"db\": {\n        \"waitForSdl\": false\n    }\n}\n"}  "
}'

# -----------------------------------
echo "===>  Check the AD xApp endpoints in the routing table"
export Service_rtmgr=$(kubectl get services -n ricplt | grep "\-rtmgr-http" | cut -f1 -d ' ')
export Rtmgr_IP=$(kubectl get svc ${Service_rtmgr} -n ricplt -o yaml | grep clusterIP | awk '{print $2}')

curl -X GET "http://${Rtmgr_IP}:3800/ric/v1/getdebuginfo" -H "accept: application/json" | jq .