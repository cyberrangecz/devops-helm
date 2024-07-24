# -*- mode: ruby -*-
# vi: set ft=ruby :

# This script to install common Kubernetes packages and is to be used
# in all VMS i.e both master and node VMs
$script = <<-SCRIPT
mkdir -p /var/opt/kypo/kypo-ansible-runner-volumes
apt update
apt install nfs-common -y
mkdir -p /var/lib/rancher/k3s/server/manifests/
cp /vagrant/traefik-config.yaml /var/lib/rancher/k3s/server/manifests/traefik-config.yaml
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.25.3+k3s1 sh -s -
curl -sfL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc
kubectl config set-context --current --namespace=kypo
helm repo add jetstack https://charts.jetstack.io
helm repo add stakater https://stakater.github.io/stakater-charts
helm repo update
helm upgrade --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.7.0 \
  --set installCRDs=true \
  --wait
helm upgrade --install reloader stakater/reloader --namespace reloader --create-namespace --wait
helm upgrade --install kypo-certs /vagrant/helm/kypo-certs -f /vagrant/vagrant-values.yaml -n kypo --wait --create-namespace -n kypo
helm upgrade --install kypo-postgres /vagrant/helm/kypo-postgres -f /vagrant/vagrant-values.yaml --wait -n kypo
helm upgrade --install kypo-gen-users /vagrant/helm/kypo-gen-users -f /vagrant/vagrant-values.yaml --wait -n kypo
kubectl apply -n kypo -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.1/kubernetes/keycloaks.k8s.keycloak.org-v1.yml
kubectl apply -n kypo -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.1/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml
kubectl apply -n kypo -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.1/kubernetes/kubernetes.yml
kubectl apply -n kypo -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/crds/legacy.k8s.keycloak.org_externalkeycloaks_crd.yaml
kubectl apply -n kypo -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/crds/legacy.k8s.keycloak.org_keycloakclients_crd.yaml
kubectl apply -n kypo -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/crds/legacy.k8s.keycloak.org_keycloakrealms_crd.yaml
kubectl apply -n kypo -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/crds/legacy.k8s.keycloak.org_keycloakusers_crd.yaml
kubectl apply -n kypo -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/role.yaml
kubectl apply -n kypo -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/role_binding.yaml
kubectl apply -n kypo -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/service_account.yaml
kubectl apply -n kypo -f https://raw.githubusercontent.com/keycloak/keycloak-realm-operator/main/deploy/operator.yaml
helm upgrade --install kypo-crp-head /vagrant/helm/kypo-crp-head -f /vagrant/vagrant-values.yaml --atomic -n kypo --timeout 15m
SCRIPT

##
#  Vagrant confiuration
Vagrant.configure("2") do |config|
  config.vm.hostname = "k3s"
  config.vm.box = "ubuntu/jammy64"
  config.disksize.size = "40GB"
  config.vm.network "private_network", ip: "172.19.0.22"
  config.vm.provision "shell", inline: $script

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 10240
    vb.cpus = 4
  end
end
