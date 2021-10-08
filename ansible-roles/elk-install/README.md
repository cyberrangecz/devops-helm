# Ansible role - elk-install

This role deploys Elasticsearch and Logstash in Kubernetes, used by KYPO.

[[_TOC_]]

## Requirements

* This role requires root access, so you either need to specify `become` directive as a global or while invoking the role.

    ```yml
    become: yes
    ```

* At least 1GB RAM on target machine.

## Example

```yml
roles:
    - role: elk-install
      become: yes
```
