# Run CyberRangeCZ Platform in Kubernetes within Vagrant

* tested on **Linux**

## Prerequisites (Vagrant)

Install the following technology:

Technology | URL to Download                           | Version
---------- | ---------------                           | -------
VirtualBox | https://www.virtualbox.org/wiki/Downloads | 5.2.34+
Vagrant    | https://www.vagrantup.com/downloads.html  | 2.0.2+
Vagrant Disk Plugin | https://github.com/sprotheroe/vagrant-disksize | 0.1.3+

## Run Vagrant VM

* **NOTE: 8GB RAM is required for the VM**

1. In the project root directory:
`cp vagrant-values.yaml-template vagrant-values.yaml`

2. Configure access to the OpenStack cloud.

    1. [Obtain Application Credentials](https://docs.openstack.org/keystone/victoria/user/application_credentials.html).

    2. Edit a **vagrant-values.yaml** file with the following variables using values obtained from the previous step.

        ```yaml
        # The URL of OpenStack Identity service API.
        osAuthUrl: <OS_AUTH_URL>
        # The ID of application credentials to authenticate at the OpenStack cloud platform.
        osApplicationCredentialId: <OS_APPLICATION_CREDENTIAL_ID>
        # The ID of application credentials secret to authenticate at the OpenStack cloud platform.
        osApplicationCredentialSecret: <OS_APPLICATION_CREDENTIAL_SECRET>
        ```

3. Configure access to the VM of the OpenStack cloud that has direct access to the virtual network dedicated to sandboxes (i.e. `Proxy Jump host`).

    1. Obtain access to the VM, i.e.:

        * hostname
        * username
        * passwordless SSH key

    2. Edit an **vagrant-values.yaml** file with the following variables using values obtained from the previous step.

        ```yaml
        # The Proxy Jump host IP address or hostname.
        proxyHost: <hostname>
        # The name of the user on the Proxy Jump host.
        proxyUser: <username>
        # base64 -w0 encoded content of private SSL key used for communication with Proxy Jump host.
        proxyKey: <single-line-base64-passwordless-ssh-key>
        ```

    3. Insert the content of the public part of the key to `~/.ssh/authorized_keys` file of the user, specified in the previous step on the VM (i.e. `Proxy Jump`) and put following line to sudoers, where user has value of proxyUser:
    `user ALL=(ALL:ALL) NOPASSWD:ALL`

4. Configure DNS servers accessible from Proxy Jump in **vagrant-values.yaml**

    ```yaml
    # The list of IP addresses to custom DNS servers.
    dnsNameServers:
    ```

5. Create and connect to the virtual machine.

    ```shell
    $ vagrant box update
    $ vagrant up
    ```

## Use CyberRangeCZ Platform

1. Authenticate with default user credentials and use the services running on https://172.19.0.22/.

    * **Admin users:** [crczp-admin]
    * **Regular users:** [crczp-user, john.doe, jane.doe]
    * **Password for all of them:** password

2. Add SB Definitions
    * **demo-training**
      * URL: `https://github.com/cyberrangecz/library-demo-training.git`
      * Revision: `master`

    * **demo-training-adaptive**
      * URL: `https://github.com/cyberrangecz/library-demo-training-adaptive.git`
      * Revision: `master`

    * **junior-hacker**
      * URL: `https://github.com/cyberrangecz/library-junior-hacker.git`
      * Revision: `master`

    * **junior-hacker-adaptive**
      * URL: `https://github.com/cyberrangecz/library-junior-hacker-adaptive.git`
      * Revision: `master`

    * **locust-3302**
      * URL: `https://github.com/cyberrangecz/library-locust-3302.git`
      * Revision: `master`

    * **secret-laboratory**
      * URL: `https://github.com/cyberrangecz/library-secret-laboratory.git`
      * Revision: `master`

3. Upload demo Training Definitions that can be found in the `training-definitions/` directory.
   * **Linear**: `linear-training.json`.
   * **Adaptive**: `adaptive-training.json`.
