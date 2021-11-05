#!/bin/sh

# -----------------------------------
echo "===>  Delete the Helm Chart of xApps"
export Service_onboarder=$(kubectl get services -n ricplt | grep "\-onboarder-http" | cut -f1 -d ' ')
export Onboarder_IP=$(kubectl get svc ${Service_onboarder} -n ricplt -o yaml | grep clusterIP | awk '{print $2}')
export CHART_REPO_URL=http://${Onboarder_IP}:8080

curl -X DELETE http://${Onboarder_IP}:8080/api/charts/ad/0.0.2

# -----------------------------------
echo ""
echo "======> Listing the xapp helm chart"
curl -X GET http://${Onboarder_IP}:8080/api/charts | jq .

sleep 5

# -----------------------------------
echo "===>  Undeploying xApps"
dms_cli uninstall --xapp_chart_name=ad --namespace=ricxapp
# kubectl delete configmap -n ricxapp configmap-ricxapp-ad-appenv configmap-ricxapp-ad-appconfig
# kubectl delete deploy -n ricxapp ricxapp-ad
# kubectl delete service -n ricxapp service-ricxapp-ad-rmr

# -----------------------------------
echo "===>  Checking the pods of xApps"
kubectl get pod -n ricxapp

# -----------------------------------
echo "===>  Deregistering xApps"

export Service_appmgr=$(kubectl get services -n ricplt | grep "\-appmgr-http" | cut -f1 -d ' ')
export Appmgr_IP=$(kubectl get svc ${Service_appmgr} -n ricplt -o yaml | grep clusterIP | awk '{print $2}')

curl -X POST "http://${Appmgr_IP}:8080/ric/v1/deregister" -H 'accept: application/json' -H 'Content-Type: application/json' -d '{
"appName": "ad",
"appInstanceName": "ad"
}'

# -----------------------------------
echo "===>  Check the AD xApp endpoints in the routing table"
export Service_rtmgr=$(kubectl get services -n ricplt | grep "\-rtmgr-http" | cut -f1 -d ' ')
export Rtmgr_IP=$(kubectl get svc ${Service_rtmgr} -n ricplt -o yaml | grep clusterIP | awk '{print $2}')

curl -X GET "http://${Rtmgr_IP}:3800/ric/v1/getdebuginfo" -H "accept: application/json" | jq .