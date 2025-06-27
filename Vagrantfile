# -*- mode: ruby -*-
# vi: set ft=ruby :

# This script to install common Kubernetes packages and is to be used
# in all VMS i.e both master and node VMs
$script = <<-SCRIPT
set -e

apt update
apt install nfs-common -y

mkdir -p /var/lib/rancher/k3s/server/manifests/
cp /vagrant/traefik-config.yaml /var/lib/rancher/k3s/server/manifests/traefik-config.yaml

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.33.1+k3s1 sh -s -
curl -sfL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc
kubectl config set-context --current --namespace=crczp

helm repo add jetstack https://charts.jetstack.io
helm repo add stakater https://stakater.github.io/stakater-charts
helm repo add cloudnative-pg https://cloudnative-pg.github.io/charts
helm repo update

helm upgrade --install cnpg cloudnative-pg/cloudnative-pg \
  --namespace cnpg-system \
  --create-namespace \
  --version 0.24.0 \
  --set config.clusterWide=true \
  --wait

helm upgrade --install crczp-postgres /vagrant/helm/crczp-postgres \
  --namespace cnpg-system \
  --create-namespace \
  -f /vagrant/vagrant-values.yaml \
  --wait

helm upgrade --install reloader stakater/reloader \
  --namespace reloader \
  --create-namespace \
  --wait

helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.7.0 \
  --set installCRDs=true \
  --wait

helm upgrade --install crczp-certs /vagrant/helm/crczp-certs \
  --namespace crczp \
  --create-namespace \
  -f /vagrant/vagrant-values.yaml \
  --wait

helm upgrade --install crczp-gen-users /vagrant/helm/crczp-gen-users \
  --namespace crczp \
  --create-namespace \
  -f /vagrant/vagrant-values.yaml \
  --wait

kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.1/kubernetes/keycloaks.k8s.keycloak.org-v1.yml
kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.1/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml
kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.1/kubernetes/kubernetes.yml

kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/crds/legacy.k8s.keycloak.org_externalkeycloaks_crd.yaml
kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/crds/legacy.k8s.keycloak.org_keycloakclients_crd.yaml
kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/crds/legacy.k8s.keycloak.org_keycloakrealms_crd.yaml
kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/crds/legacy.k8s.keycloak.org_keycloakusers_crd.yaml
kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/role.yaml
kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/role_binding.yaml
kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/service_account.yaml
kubectl apply -n crczp -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/operator.yaml

helm upgrade --install crczp-head /vagrant/helm/crczp-head \
  --namespace crczp \
  --create-namespace \
  -f /vagrant/vagrant-values.yaml \
  --timeout 15m \
  --atomic
SCRIPT

##
#  Vagrant confiuration
Vagrant.configure("2") do |config|
  config.vm.hostname = "k3s"
  config.vm.network "private_network", ip: "172.19.0.22"
  config.vm.provision "shell", inline: $script

  config.vm.provider "virtualbox" do |vb, override|
    override.vm.box = "ubuntu/jammy64"
    vb.memory = 10240
    vb.cpus = 4
  end

  config.vm.provider "libvirt" do |libvirt, override|
    override.vm.box = "generic/ubuntu2204"
    override.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_udp: false, nfs_version: 4
    libvirt.memory = 10240
    libvirt.cpus = 4
    libvirt.driver = "kvm"
    libvirt.disk_bus = 'virtio'
    libvirt.nic_model_type = 'virtio'
  end
end
