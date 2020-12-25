
echo '***'
echo '*** adding docker repository GPG key'
echo '***'
wget -q -O - https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -

echo '***'
echo '*** check that GPG key have been registered'
echo '***'
sudo apt-key fingerprint 0EBFCD88

echo '***'
echo '*** adding docker APT repository'
echo '***'
cat << EOF | sudo tee /etc/apt/sources.list.d/docker.list
deb [arch=arm64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable
# deb-src [arch=arm64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable
EOF

echo '***'
echo '*** updating APT repositories'
echo '***'
sudo apt-get update

echo '***'
echo '*** adding docker repository GPG key'
echo '***'
sudo apt-get --yes --quiet install \
  containerd.io

echo '***'
echo '*** pull hello-world test image'
echo '***'
sudo ctr image pull docker.io/library/hello-world:latest

echo '***'
echo '*** run hello-world test image'
echo '***'
sudo ctr run --rm docker.io/library/hello-world:latest helloworld

echo '***'
echo '*** clean up hello-world test container'
echo '***'
curl https://raw.githubusercontent.com/containerd/containerd/master/contrib/autocomplete/ctr \
| sudo tee /etc/bash_completion.d/ctr

echo '***'
echo '*** add modules required for containerd'
echo '***'
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

echo '***'
echo '*** Setup required sysctl params, these persist across reboots.'
echo '***'
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

echo '***'
echo '*** Apply sysctl params without reboot'
echo '***'
sudo sysctl --system

echo '***'
echo '*** Configure containerd'
echo '***'
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

echo '***'
echo '*** Restart containerd'
echo '***'
sudo systemctl restart containerd
