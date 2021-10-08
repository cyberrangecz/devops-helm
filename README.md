# KYPO CRP deployed on Kubernetes

❗ tested on **Linux - Ubuntu 18.04** 

[TOC]


## Prerequisites (Kubernetes)
![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)

Recommended Kubernetes distributions.

Distribution | URL to Download                           
---------- | ---------------                           
Minikube | https://minikube.sigs.k8s.io/docs/start/ 
Rancher    | https://rancher.com/quick-start  

Install required addons if the chosen distribution does not contain them:

Addon |                          
---------- |               
Nginx Ingress Controller
Longhorn |


##  Prerequisites (Ansible) 
![Ansible](https://img.shields.io/badge/ansible-%231A1918.svg?style=for-the-badge&logo=ansible&logoColor=white)

Install the following technology:

Technology       | Installation                                         | Version
----------       | ---------------                                      | -------
Ansible          | `apt install ansible`                                | 2.10.5+
Docker          | `apt install docker docker.io`                        | 20.10.7+
community.docker | `ansible-galaxy collection install community.docker` | 1.5.0+
python3-passlib  | `apt install python3-passlib`                        | 1.7+
bcrypt           | `pip3 install bcrypt`                                | 3.2+
Helm             | `https://helm.sh/docs/intro/install/`                | 3.7.1+
community.kubernetes | `ansible-galaxy collection install community.kubernetes` | 1.2.1+
community.kubernetes | `ansible-galaxy collection install kubernetes.core` | 1.2.1+

## Prerequisites (OIDC)

Before deploying KYPO CRP, you need to have at least one OIDC provider ready.

There is ansible role ready to deploy dummy local OIDC provider for testing purposes in Vagrant.

Before installation:
-  remove these two lines from [Vagranfile](https://gitlab.ics.muni.cz/muni-kypo-crp/devops/kypo-crp-deployment/-/blob/master/Vagrantfile#L39)
- set [vm memory](https://gitlab.ics.muni.cz/muni-kypo-crp/devops/kypo-crp-deployment/-/blob/master/Vagrantfile#L31) based on your resources, atleast 4GB 
- change these ports to 8444 (Minikube, and maybe other distributions uses 8443) 
    - [first change](https://gitlab.ics.muni.cz/muni-kypo-crp/devops/kypo-crp-deployment/-/blob/master/provisioning-oidc/roles/kypo-crp-local-oidc/templates/csirtmu.oidc.issuer.properties#L4) 
    - [second change to 8444:8444](https://gitlab.ics.muni.cz/muni-kypo-crp/devops/kypo-crp-deployment/-/blob/master/provisioning-oidc/roles/kypo-crp-local-oidc/templates/docker-compose-oidc.yml#L54)
    - [third change](https://gitlab.ics.muni.cz/muni-kypo-crp/devops/kypo-crp-deployment/-/blob/master/provisioning-oidc/roles/kypo-crp-local-oidc/templates/nginx.conf#L2)
## Complete guide how to deploy KYPO CRP on minikube distribution 

**❗ 16GB RAM is recommended**
### Install kubectl
1. Download the latest release
    ```console
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    ```
2. Install kubectl
    ```console
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    ```
3. Verify installation
    ```console
    kubectl version --client
    ```
### Configure Docker
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)

It is required to change two things in Docker configuration. Set MTU for Docker container to 1442B, and set memlock of RAM for Docker container to unlimited. 

There is Ansible role ready for that, you can apply it with command:

❗ **It will restart Docker service**

```console
ansible-playbook docker-playbook.yml 
```

### Deploy Minikube

1. Install latest Minikube stable release
    ```console
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    ```
    ```console
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    ```
     To use kubectl or minikube commands as your own user, you may need to      relocate them. For example, to overwrite your own settings, run:
    ```console
    sudo mv /home/ubuntu/.kube /home/ubuntu/.minikube $HOME
    ```
    ```console
    sudo chown -R $USER $HOME/.kube $HOME/.minikube
    ```
2. Install conntrack dependency
    ```console
    sudo apt-get install -y conntrack
    ```

3. Start your cluster.
    
    ```console   
    sudo minikube start --driver=none
    ```

4. Enable required addons
    
    1. Nginx Ingress Controller
    
        ```console   
        minikube addons enable ingress
        ```
    2. Longhorn
        Install open-iscsi package.
        ```console   
        apt-get install -y open-iscsi
        ```
        ```console   
        kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.2.2/deploy/longhorn.yaml
        ```
        Check if Longhorn deployment succeeded, there should be +-19 objects in running state
        ```console   
        kubectl -n longhorn-system get pod
        ```

5. Configure access to the OpenStack cloud.

    ![OpenStack](https://img.shields.io/badge/Openstack-%23f01742.svg?style=for-the-badge&logo=openstack&logoColor=white)


    1. [Obtain Application Credentials](https://docs.openstack.org/keystone/victoria/user/application_credentials.html).

    2. Edit an [extra-vars-template.yml](extra-vars-template.yml) file with the following variables using values obtained from the previous step.

        ```yaml
        # The URL of OpenStack Identity service API.
        kypo_crp_os_auth_url: <OS_AUTH_URL>
        # The ID of application credentials to authenticate at the OpenStack cloud platform.
        kypo_crp_os_application_credential_id: <OS_APPLICATION_CREDENTIAL_ID>
        # The secret string of `kypo_crp_os_application_credential_id`.
        kypo_crp_os_application_credential_secret: <OS_APPLICATION_CREDENTIAL_SECRET>
        ```

6. Configure access to the VM of the OpenStack cloud that has direct access to the virtual network dedicated to sandboxes (i.e. `kypo-proxy-jump`).

    1. Obtain access to the VM, i.e.:

        * hostname
        * username
        * passwordless SSH key

    2. Edit an [extra-vars-template.yml](extra-vars-template.yml) file with the following variables using values obtained from the previous step.

        ```yaml
        # The KYPO Jump host IP address or hostname.
        kypo_crp_proxy_host: <hostname>
        # The name of the user on the KYPO Jump host.
        kypo_crp_proxy_user: <username>
        ```

    3. Edit an [secrets-template.yml](secrets-template.yml) file with the following variable using values obtained from the previous step.

        ```yaml
        # The base64 encoded content of private SSL key used for communication with `kypo_crp_proxy_host`.
        kypo_crp_proxy_key: |-
            <passwordless-ssh-key
            spanning-multiple-lines>
        ```

    4. Insert the content of the public part of the key to `~/.ssh/authorized_keys` file of the user, specified in the previous step on the VM (i.e. `kypo-proxy-jump`).

7. Configure DNS servers accessible from kypo-proxy-jump in [extra-vars-template.yml](extra-vars-template.yml)

    ```yaml
    # The list of IP addresses to custom DNS servers.
    kypo_crp_dns:
    ```
8. Configure git access with PUBLIC git repository [extra-vars-template.yml](extra-vars-template.yml)

    ![Git](https://img.shields.io/badge/git-%23F05033.svg?style=for-the-badge&logo=git&logoColor=white)

    ```yaml
    kypo_crp_git:
    # The type of Git repository. For external, keep the value set to GITLAB.
    type: GITLAB

    # The Git server hostname or IP address.
    server: example.com

    # The URL of Git REST server.
    rest_server_url: https://example.com/

    # The name of user used for communication with Git repository.
    user: git

    # The base64 encoded content of private SSL key that KYPO CRP uses to communicate with Git repository.
    private_key: |-
        <encoded-ssh-key
        spanning-multiple-lines>

    # The base64 encoded content of public part of `kypo_crp_git.private_key` SSL key.
    public_key: |-
        <encoded-ssh-key
        spanning-multiple-lines>

    # The access token for Git REST server.
    access_token: alpha-num-string

    # The URL of Ansible networking Git repository.
    ansible_networking_url: git@example.com:kypo-ansible-stage-one.git

    # The revision of Ansible networking Git repository. Either branch name, tag, or SHA commit hash.
    ansible_networking_rev: master
    ```
9. Configure other needed variables [extra-vars-template.yml](extra-vars-template.yml)
    ```yaml
    # The FQDN of KYPO CRP.
    kypo_crp_domain: kypo.example.com

    # Complete URL of KYPO CRP
    kypo_crp_url: "https://{{ kypo_crp_domain }}"

    # Internal IP address of KYPO HEAD
    kypo_crp_internal_ip:

    # The prefix of the sandbox in the OpenStack cloud.
    kypo_crp_instance_name: 
    ```
10. Configure variables needed for connection to OIDC provider [extra-vars-template.yml](extra-vars-template.yml)

    ```yaml
    kypo_crp_oidc_providers:
        # The label that is displayed as an option for authentication.
        - label: Login with Example issuer

          # The URL of resource server configuration.
          url: 

          # The ID of OIDC client.
          client_id: 

          # The ID of resource client.
          resource_client_id: 

          # The secret for resource client `resource_client_id`.
          resource_client_secret: 
    ```

11. Configure variables needed for Helm and Kubernetes [group_vars/all.yml](group_vars/all.yml)

    ```yaml
    #Version of Helm which will be used | latest if empty
    helm_release:

    #Kubernetes namespace in which will be KYPO CRP deployed
    helm_namespace: kypo

    #version of Elk Helm chart | latest if empty
    elk_chart_version:

    #version of Git Helm chart | latest if empty
    git_chart_version:

    #version of Syslog-ng Helm chart | latest if empty
    syslog_chart_version:

    #version of Kypo-CRP Helm chart | latest if empty
    kypo_chart_version:

    #path to Kubernetes config file
    kubeconfig_path: ~/.kube/config
    ```

12. Run Ansible roles to deploy KYPO CRP.

    Run playbook with added paths to the Ansible extra vars files, e.g. [extra-vars-template.yml](extra-vars-template.yml) and [secrets-template.yml](secrets-template.yml).

    ```console
    ansible-playbook playbook.yml --extra-vars=@extra-vars-template.yml --extra-vars=@secrets-template.yml
    ```
## Use KYPO

1. Access the OIDC issuer page https:<oidc_url> and accept the risks of using a self-signed certificate. If you have deployed local oidc provider with vagrant, use url https://172.19.0.22:8444/csirtmu-dummy-issuer-server/.

2. Access KYPO CRP and authenticate with default user credentials.

    * **Admin users:** [kypo-admin]
    * **Regular users:** [kypo-user, john.doe, jane.doe]
    * **Password for all of them:** password

3. Add demo SB Definitions
    * **Linear**
      * URL: `git@gitlab.ics.muni.cz:muni-kypo-crp/prototypes-and-examples/sandbox-definitions/kypo-crp-demo-training.git`
      * Revision: `v2.0.0`

    * **Adaptive**
      * URL: `git@gitlab.ics.muni.cz:muni-kypo-crp/prototypes-and-examples/sandbox-definitions/kypo-crp-demo-training-adaptive.git`
      * Revision: `v1.0.1`

4. Upload demo Training Definitions
 
   * **Linear**: [Download](https://gitlab.ics.muni.cz/muni-kypo-crp/prototypes-and-examples/sandbox-definitions/kypo-crp-demo-training/-/raw/master/training.json?inline=false).
   * **Adaptive**: [Download](https://gitlab.ics.muni.cz/muni-kypo-crp/prototypes-and-examples/sandbox-definitions/kypo-crp-demo-training-adaptive/-/raw/master/adaptive-training.json?inline=false).