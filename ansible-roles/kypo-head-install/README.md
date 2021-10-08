# Ansible role - KYPO CRP Configuration

This role deploys KYPO Cyber Range Platform in Kubernetes cluster.

## Requirements

* This role requires root access, so you either need to specify `become` directive as a global or while invoking the role.

    ```yml
    become: yes
    ```

## Role parameters

Mandatory parameters

* `kypo_crp_domain` - The FQDN of KYPO CRP.
* `kypo_crp_internal_ip`: IP address of head server
* `kypo_crp_os_auth_url` - The URL of OpenStack Identity service API.
* `kypo_crp_os_application_credential_id` - The ID of application credentials to authenticate at the OpenStack cloud platform.
* `kypo_crp_os_application_credential_secret` - The secret string of `kypo_crp_os_application_credential_id`.
* `kypo_crp_proxy_host` - The KYPO Jump host IP address or hostname.
* `kypo_crp_proxy_user` - The name of the user on the KYPO Jump host.
* `kypo_crp_proxy_key` - The base64 encoded content of private SSL key used for communication with `kypo_crp_proxy_host`.
* `kypo_crp_cert` - The base64 encoded content of SSL certificate that is used by KYPO CRP for HTTPS communication.
* `kypo_crp_cert_key` - The base64 encoded content of private SSL key of `kypo_crp_cert`.
* `kypo_crp_git` - The Git repository specification.
    * `type` - The type of Git repository. For external, keep the value set to GITLAB.
    * `server` - The Git server hostname or IP address.
    * `rest_server_url` - The URL of Git REST server.
    * `user` - The name of user used for communication with Git repository.
    * `private_key` - The base64 encoded content of passwordless private SSL key that KYPO CRP uses to communicate with Git repository.
    * `public_key` - The base64 encoded content of public part of `kypo_crp_git.private_key` SSL key.
    * `access_token` - The access token for Git REST server.
    * `ansible_networking_url` - The URL of Ansible networking Git repository.
    * `ansible_networking_rev` - The revision of Ansible networking Git repository. Either branch name, tag, or SHA commit hash.
* `kypo_crp_oidc_providers` - The list of OIDC providers and their specification.
    * `label` - The label that is displayed as an option for authentication.
    * `url` - The URL of resource server configuration.
    * `client_id` - The ID of OIDC client.
    * `resource_client_id` - The ID of resource client.
    * `resource_client_secret` - The secret for resource client `resource_client_id`.
* `kypo_crp_users` - The list of KYPO CRP users that will be added to the local OIDC provider and KYPO CRP users and groups service.
    * `sub` - The unique identifier of the user within the OIDC provider.
    * `iss` - The URL of the OIDC provider.
    * `password` - A password of the user.
    * `email` - An email address of the user.
    * `fullName` - The user full name.
    * `givenName` - The user given name.
    * `familyName` - The user family name.
    * `admin` - The boolean value that represents whether the user is admin or not.

Optional parameters.

* `kypo_crp_dns` - The list of IP addresses to custom DNS servers.
* `kypo_crp_docker_network_name` - The name of the Docker network where the Internal Git will be connected (default: `kypo-platform-net`).
* `kypo_crp_instance_name` - The prefix of the sandbox in the OpenStack cloud (maximum 8 characters).

## Example

The simplest example.

```yml
roles:
    - role: kypo-crp
      kypo_crp_host: 172.19.0.22
      kypo_crp_os_auth_url: 'http://example.com/os-auth'
      kypo_crp_os_application_credential_id: 'short-alfa-num-with-dash'
      kypo_crp_os_application_credential_secret: 'long-alfa-num-with-dash'
      kypo_crp_proxy_host: kypo-proxy.example.com
      kypo_crp_proxy_user: kypo
      kypo_crp_proxy_key: '{{ lookup("file", "~/.ssh/id_rsa") | b64encode }}'
      kypo_crp_cert: '{{ lookup("file", "/path/to/certificate.pem") | b64encode }}'
      kypo_crp_cert_key: '{{ lookup("file", "/path/to/certificate.key") | b64encode }}'
      kypo_crp_git:
        type: GITLAB
        server: example.com
        rest_server_url: http://example.com:5000/
        user: git
        private_key: '{{ lookup("file", "/path/to/passwordless-private-key") | b64encode }}'
        public_key: '{{ lookup("file", "/path/to/passwordless-public-key.pub") | b64encode }}'
        access_token: alpha-num-string
        ansible_networking_url: git@example.com:kypo-ansible-stage-one.git
        ansible_networking_rev: master
      kypo_crp_oidc_providers:
        - label: Login with local issuer
          url: https://example.com:443/issuer
          client_id: alpha-num-string
          resource_client_id: alpha-num-string
          resource_client_secret: alpha-num-string
      kypo_crp_users:
        - sub: admin@example.com
          iss: https://example.com:443/issuer
          password: password
          email: admin@example.com
          fullName: Demo Admin
          givenName: Demo
          familyName: Admin
          admin: True
```
