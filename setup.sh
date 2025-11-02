#!/bin/bash
RED='\e[0;31m'
YELLOW='\e[0;33m'
GREEN='\e[0;32m'
NC='\e[0m' # No Color
# interupt script on fail
set -e

cd ./terraform/

cd ./images/
if ls chr* &>/dev/null; then
  echo -e "${YELLOW}###########################################${NC}"
  echo -e "${YELLOW}[>] CHR image exists. Skipping the download${NC}"
  echo -e "${YELLOW}###########################################${NC}"
else
  echo -e "${YELLOW}[X] Downloading CHR img${NC}" && sleep 1
  wget 'https://download.mikrotik.com/routeros/7.18.2/chr-7.18.2.vmdk.zip'
  echo -e "${YELLOW}[X] Unpacking MT-CHR VMDK${NC}"
  unzip chr-7.18.2.vmdk.zip
  rm chr-7.18.2.vmdk.zip
  echo -e "${YELLOW}[X] Converting to qcow2${NC}"
  qemu-img convert -f vmdk -O qcow2 chr-7.18.2.vmdk chr-7.18.2.qcow2
  rm chr-7.18.2.vmdk
fi
sleep 1

cd ..
echo -e "${YELLOW}###########################################${NC}"
echo -e "${YELLOW}[X] Destroying existing plan if any${NC}"
echo -e "${YELLOW}###########################################${NC}"
sleep 3
terraform destroy -auto-approve
echo -e "${YELLOW}###########################################${NC}"
echo -e "${YELLOW}[X] Providing the cluster${NC}"
echo -e "${YELLOW}###########################################${NC}"
sleep 4
terraform apply -auto-approve && echo -e "${GREEN}[+] Cluster is deployed${NC}"

echo -e "${YELLOW}###########################################${NC}"
echo -e "${YELLOW}[X] About to provision the cluster${NC}"
echo -e "${YELLOW}[X] Passing execution flow to Ansible${NC}"
echo -e "${YELLOW}###########################################${NC}"
sleep 4
cd ../ansible/
. ./bin/activate

sed -i '/192.168.122.101\|192.168.122.102\|192.168.122.103\|192.168.122.104/d' ~/.ssh/known_hosts
python3 -m ansible playbook -i ./inventory.ini ./imports.yaml

cd ../
