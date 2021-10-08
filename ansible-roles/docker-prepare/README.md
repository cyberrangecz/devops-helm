# Ansible role - docker-prepare

This role sets up Docker for using containers through OpenStack.

## Requirements

* This role requires root access, so you either need to specify `become` directive as a global or while invoking the role.

    ```yml
    become: yes
    ```

## Example

The simplest example.

```yml
roles:
    - role: docker-prepare

