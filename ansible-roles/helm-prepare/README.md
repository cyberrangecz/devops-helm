# Ansible role - helm-prepare

This role installs Helm.

## Requirements

* This role requires root access, so you either need to specify `become` directive as a global or while invoking the role.

    ```yml
    become: yes
    ```

## Example

The simplest example.

```yml
roles:
    - role: helm-prepare

