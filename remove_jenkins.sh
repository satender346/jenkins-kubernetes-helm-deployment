helm delete jenkins
helm delete -n jenkins jenkins
kubectl delete pvc jenkins-home-jenkins-api-0 -n jenkins
kubectl delete pv task-pv-volume
kubectl delete ns jenkins
rm -rf /mnt/data
