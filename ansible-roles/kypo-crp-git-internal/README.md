# Ansible role - Internal Git

This role configures KYPO Internal Git.

## Requirements

* This role requires root access, so you either need to specify `become` directive as a global or while invoking the role.

    ```yml
    become: yes
    ```

## Role parameters

Optional parameters.

* `kypo_crp_docker_network_name` - The name of the Docker network where the Internal Git will be connected (default: `kypo-platform-net`).

## Example

The simplest example.

```yml
roles:
    - role: kypo-crp-git-internal
```

