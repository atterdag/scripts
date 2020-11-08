#!/bin/sh

echo '***'
echo '*** add bash completion scripts for kubeadm, and kubectl'
echo '***'
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl
kubeadm completion bash | sudo tee /etc/bash_completion.d/kubeadm
. /etc/bash_completion

echo '***'
echo '*** download kubernetes docker images (THIS IS GOING TO TAKE A WHILE)'
echo '***'
sudo -i kubeadm config images pull
