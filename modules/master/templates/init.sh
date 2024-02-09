#!/bin/bash

apt-get -yq update
apt-get install -yq \
    ca-certificates \
    curl \
    ntp


# k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=${k3s_channel} K3S_TOKEN=${k3s_token} sh -s - \
    --flannel-backend=host-gw \
    --disable local-storage \
    --disable-cloud-controller \
    --disable traefik \
    --disable servicelb \
    --node-taint node-role.kubernetes.io/master:NoSchedule \
    --kubelet-arg 'cloud-provider=external'

# wait for k3s to have generated manifests directory...
while ! test -d /var/lib/rancher/k3s/server/manifests; do
    echo "Waiting for '/var/lib/rancher/k3s/server/manifests'"
    sleep 1
done

# configure and install latest cloud-controller-manager from hetzner...
kubectl -n kube-system create secret generic hcloud --from-literal=token=${hcloud_token} --from-literal=network=${hcloud_network}
curl -sL https://github.com/hetznercloud/hcloud-cloud-controller-manager/releases/latest/download/ccm.yaml | sudo tee /var/lib/rancher/k3s/server/manifests/hcloud-ccm.yaml

# configure and install latest container-storage-interface from hetzner...
kubectl -n kube-system create secret generic hcloud-csi --from-literal=token=${hcloud_token}
curl -sL https://raw.githubusercontent.com/hetznercloud/csi-driver/main/deploy/kubernetes/hcloud-csi.yml | sudo tee /var/lib/rancher/k3s/server/manifests/hcloud-csi.yaml
