## About
Intentionally vulnerable environment built using MikroTik RouterOS images.

Each XXX-CHR.tf file represents a link. The network topology is attached.
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
```bash
cd ansible
python -m venv ./
. ./bin/activate
pip install ansible ansible-pylibssh
```

## Note
- in order to add hosts - edit `./terraform/main.tf -> domain_map`

## Usage
```
./setup.sh
```
