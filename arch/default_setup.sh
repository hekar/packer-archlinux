#!/usr/bin/env bash

# This script is executed by packer after the vm has started
# The purpose of this script is to start archinstall and configure
# the machine for ansible

set -xe

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

Help()
{
   echo "Run archinstall and configure machine for packer ansible execution."
   echo
   echo "Syntax: $0 [-i|p|h]"
   echo "options:"
   echo "i     Provide the IP for the Packer http server."
   echo "p     Provide the port for the Packer http server."
   echo "h     Print this Help."
   echo
}

HTTP_IP=""
HTTP_PORT=""
ARCH_PROFILE_NAME='archinstall_packer'
ARCH_PROFILE_FILENAME="${ARCH_PROFILE_NAME}.py"
ARCH_PROFILE_DEST='/usr/lib/python3.10/site-packages/archinstall/profiles'

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
   -h | --help )
      Help
      exit 1
      ;;
   -i | --ip )
      shift; HTTP_IP=$1
      ;;
   -p | --port )
      shift; HTTP_PORT=$1
      ;;
esac; shift; done
if [[ "$1" == '--' ]]; then shift; fi

if [[ -z $HTTP_IP || -z $HTTP_PORT ]]; then
   Help
   exit 1
fi

HTTP_SERVER=http://$HTTP_IP:$HTTP_PORT

cd /

echo "downloading installation script..."
curl -O $HTTP_SERVER/arch/$ARCH_PROFILE_FILENAME
mv $ARCH_PROFILE_FILENAME $ARCH_PROFILE_DEST
echo "downloaded installation script."

echo "downloading installation configuration..."
curl -O $HTTP_SERVER/arch/user_disk_layout.json
curl -O $HTTP_SERVER/arch/user_configuration.json
curl -O $HTTP_SERVER/arch/user_credentials.json
echo "downloaded installation configuration."

echo "performing installation..."
archinstall --script $ARCH_PROFILE_NAME
echo "completed installation."

echo "disabling password for sudoers..."
chroot /mnt/archinstall sed -i 's/ALL$/NOPASSWD:ALL/' /etc/sudoers.d/00_user
echo "disabled password for sudoers."

systemctl reboot
