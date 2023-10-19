#!/bin/bash

# Container RunTime - Installation 
# Docker & Containerd - Installation
# Kubeadm, Kubectl & Kubelet - Installation
# Cluster Initialization
# Core DNS Intialization
# Untaint Master Node

set -e

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"

docker_installation() {

    printf "${GREEN} Docker Installation in Progress -- ${ENDCOLOR}\n"
    
    sudo apt-get update
    sudo apt-get install ca-certificates curl gnupg -y


    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    printf \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && printf "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update

    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    sudo docker --version 

    EXITCODE=$?

    if [[ $EXITCODE -eq 0 ]];
    then 
      printf "${GREEN} ############### -- Docker Install Succesfully -- ################## ${ENDCOLOR}\n"
      sudo rm -rf /etc/containerd/*.toml
      file_path="/etc/containerd/config.toml"
      if [[ -f "$file_path" ]]; then
        printf "#### -- File not deleted -- ####"
        exit 1
      else 
        printf "${GREEN} #### -- File deleted Sucessfully -- ##### ${ENDCOLOR}\n"
        sudo systemctl restart containerd
        systemctl status containerd |grep -i "Active"
      fi
    else
      printf "${RED} ################## -- Docker Installation Failed -- ################ ${ENDCOLOR}\n"
    fi
}

kube_installation() {
    printf "${GREEEN} Kubelet, Kubeadm and Kubectl Installation In-Progress.... ${ENDCOLOR}\n"
    sudo apt-get install -y apt-transport-https ca-certificates curl
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    printf 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    
    ## Verify if the installation kubelet kubeadm kubectl is succesful --
    
    sudo kubeadm version
    sudo kubelet --version
    sudo kubectl version |grep -i Client 

    EXITCODE=$?

    if [[ $EXITCODE -eq 0 ]];
    then
      sudo apt-mark hold kubelet kubeadm kubectl
      sudo kubeadm init ## Initialize Kubernetes Cluster --
      mkdir -p $HOME/.kube
      sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
      sudo chown $(id -u):$(id -g) $HOME/.kube/config
    else
      printf "${RED} Kubeadm Installation Failed!! --- ${ENDCOLOR}\n"
    fi
    
    # Verify Kubernetes cluster initialization --

    kubectl get nodes -o wide 
    printf "${GREEN} Master Node Setup -- Completed ${ENDCOLOR} \n"
}

codedns_setup(){
    printf "Core DNS Setup ----"
    kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
    kubectl get pods -n kube-system |grep -i coredns # Verify CoreDNS Setup
    printf "${YELLOW} CoreDNS Setup -- Completed ${ENDCOLOR} \n"
}

docker_installation
kube_installation
codedns_setup

# Untained Master Node
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
printf "${GREEN} -- Master Node Untained -- ${ENDCOLOR} \n"
kubectl get nodes
printf "${GREEN} #### Kubernetes Cluster Setup -- Completed ##### ${ENDCOLOR} \n"
printf "${GREEN} #### The End #### ${ENDCOLOR} \n"

