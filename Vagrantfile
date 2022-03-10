# -*- mode: ruby -*-
# vi: set ft=ruby :

# This script to install common Kubernetes packages and is to be used
# in all VMS i.e both master and node VMs
$script = <<-SCRIPT
mkdir -p /var/opt/kypo/kypo-ansible-runner-volumes
apt update
apt install nfs-common docker.io -y
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--no-deploy traefik --docker" sh -s -
curl -sfL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc
kubectl config set-context --current --namespace=kypo
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
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
helm upgrade --install kypo-certs /vagrant/helm/kypo-certs -n kypo --wait --create-namespace -n kypo
helm upgrade --install ingress-nginx ingress-nginx\
 --repo https://kubernetes.github.io/ingress-nginx\
 --namespace ingress-nginx --create-namespace\
 --set controller.extraArgs.default-ssl-certificate=kypo/kypo-certs
helm upgrade --install kypo-postgres /vagrant/helm/kypo-postgres -f /vagrant/vagrant-values.yaml --wait -n kypo
echo "global:
  kypoCrpOidcs:
    - url: https://172.19.0.22:443/csirtmu-dummy-issuer-server/
      logoutUrl: https://172.19.0.22:443/csirtmu-dummy-issuer-server/endsession
      clientId: `head -n 300 /dev/urandom | tr -dc 'A-Za-z' | fold -w 36 | head -n 1`
      label: Login with local issuer" > /vagrant/vagrant-oidc.yaml
helm upgrade --install kypo-gen-users /vagrant/helm/kypo-gen-users -f /vagrant/vagrant-values.yaml --wait -n kypo
helm upgrade --install kypo-crp-head /vagrant/helm/kypo-crp-head -f /vagrant/vagrant-values.yaml -f /vagrant/vagrant-oidc.yaml --wait -n kypo --timeout 15m
SCRIPT

##
#  Vagrant confiuration
Vagrant.configure("2") do |config|
  config.vm.hostname = "k3s"
  config.vm.box = "ubuntu/focal64"
  config.disksize.size = "40GB"
  config.vm.network "private_network", ip: "172.19.0.22"
  config.vm.provision "shell", inline: $script

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 7168
    vb.cpus = 4
  end
end
