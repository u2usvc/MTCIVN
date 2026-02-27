## About

Lab environment built using MikroTik RouterOS CHR images.

Each l-XXX.tf file represents a link.
`mode="none"` is supplied so that networks will not be able to communicate with the host LAN.

each domain definition should create an attached VNI. For example this one is attached to mtcivnbr112 bridge:

```
195: vnet8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master mtcivnbr112 state UNKNOWN group default qlen 1000
    link/ether fe:54:00:ea:98:1c brd ff:ff:ff:ff:ff:ff
    inet6 fe80::fc54:ff:feea:981c/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
```

Each network should create a bridge VNI, for example:

```
192: mtcivnbr112: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc htb state UP group default qlen 1000
   link/ether 52:54:00:99:be:ac brd ff:ff:ff:ff:ff:ff
```

## Prerequisites

Ensure terraform and xsltproc is installed.

```bash
cd terraform
terraform init -upgrade
```

```bash
cd ansible
python -m venv ./
. ./bin/activate

# libssh-devel is required
pip install ansible ansible-pylibssh
```

## Note

In order to add hosts:

- edit `./terraform/main.tf -> domain_map` to add hosts and connections between them (`ip` and `cidr` are needed for dnsmasq DHCP server on the first network defined in `net` array)
- add config file to `./ansible/dev/`
- add subnet to `./ansible/inventory.ini` (do not `ansible_host` already defined machines)
- add config file to `./ansible/imports.yaml`

dnsmasq started by libvirt assigns an IP to ether1 for each VM in order for ansible to work, however I still set ether1 address in ansible playbooks for the sake of verbosity.

## Usage

```
./setup.sh
```

Devices are accessible using `admin:packer` credentials over ssh. Addresses exposed to host are listed under `./ansible/inventory.ini`.
