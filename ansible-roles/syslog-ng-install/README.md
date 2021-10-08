# Ansible role - KYPO CRP syslog-ng

This role setups syslog-ng service for KYPO CRP deployed in Kubernetes.

## Requirements

* This role requires root access, so you either need to specify `become` directive as a global or while invoking the role.

    ```yml
    become: yes
    ```

## Role parameters

Optional.

* `syslog_ng_source_sandbox_protocol` - Transport protocol for sandbox hosts logging source. Values 'tcp', 'tls' and 'udp' are supported.
* `syslog_ng_source_sandbox_ip` - The IP address on which the syslog ng is listening for the logs from sandboxes.
* `syslog_ng_source_sandbox_port` - The port number on which the syslog ng is listening for the logs from sandboxes.
* `syslog_ng_source_sandbox_max_connections` - Specifies the maximum number of simultaneous connections.
* `syslog_ng_source_sandbox_log_initial_windows_size`: The size of the initial window, this value is used during flow-control.
* `syslog_ng_source_events_ip` - The IP address on which the syslog ng is listening for the events from portal.
* `syslog_ng_source_events_port` - The port number on which the syslog ng is listening for the events from portal.
* `syslog_ng_destination` - The IP address of the logastash instance.
* `syslog_ng_events_destination_port` - The port number on which the logstash is listening for the events from portal.
* `syslog_ng_bash_destination_port` - The port number on which the logstash is listening for the logs of bash commands from sandboxes.
* `syslog_ng_msf_destination_port` - The port number on which the logstash is listening for the logs of msf commands from sandboxes.
* `syslog_ng_destination_protocol` - The protocol used to send messages to logastash (udp, tcp).

### Encrypted communication

To use encrypted communication you must set `syslog_ng_source_sandbox_protocol` to 'tls' and override the following parameters:
* `syslog_ng_key` - The base64 encoded content of the unencrypted private key in PEM format.
* `syslog_ng_cert` - The base64 encoded content of the server certificate in PEM format matching the private key set in the `syslog_ng_key_file`.
* `syslog_ng_ca_cert` - The base64 encoded content of the trusted CA certificate. Use if you are using mutual authentication.
* `syslog_ng_verify_clients` - Set to `False` if you don't want to use the mutual authentication. Default value is `True`.

## Example

The simplest example of syslog-ng configuration.

```yml
roles:
    - role: syslog-ng
      become: yes
```

The syslog-ng configuration using TLS/SSL encryption.

```yml
roles:
    - role: syslog-ng
      syslog_ng_source_sandbox_protocol: tls
      syslog_ng_key: '{{ lookup("file", "/path/to/certificate-key.pem") | b64encode }}'
      syslog_ng_cert: '{{ lookup("file", "/path/to/certificate-crt.pem") | b64encode }}'
      syslog_ng_verify_clients: False
      become: yes
```
