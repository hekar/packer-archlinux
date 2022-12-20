#!/usr/bin/env bash

# install the image through virt-install

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

set -e

Help()
{
   echo "virt-install (optionally build) and start the packer image"
   echo
   echo "Syntax: $0 [-i|p|h]"
   echo "options:"
   echo "b     Build the packer image."
   echo "h     Print this Help."
   echo
   echo "install.sh | grep 'ip\.addr' # for vm ip address(es)"
}

ARTIFACT_FOLDER=$SCRIPT_DIR/artifacts
ARTIFACT=$ARTIFACT_FOLDER/packer-archlinux
VM_NAME=arch
VM_IMAGE=/tmp/packer-archlinux

INSTALL_SIZE=12
INSTALL_MEMORY=4096
INSTALL_VCPUS=2
INSTALL_NETWORK=bridge=virbr0,model=virtio

START_VM=1
FORCE_BUILD=0

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
   -h | --help )
      Help
      exit 1
      ;;
   -b | --build )
      FORCE_BUILD=1
      ;;
   --no-start )
      START_VM=0
      ;;
   -n | --name )
      shift; VM_NAME=$1
      ;;
   -d | --dest )
      shift; VM_IMAGE=$1
      ;;
   -m | --mem )
      shift; INSTALL_MEMORY=$1
      ;;
   -s | --hd-size )
      shift; INSTALL_SIZE=$1
      ;;
   -c | --vcpus )
      shift; INSTALL_VCPUS=$1
      ;;
   -t | --network )
      shift; INSTALL_NETWORK=$1
      ;;
esac; shift; done
if [[ "$1" == '--' ]]; then shift; fi

if [[ $FORCE_BUILD -eq 1 ]]; then
   echo 'removing artifacts...'
   rm -rf $ARTIFACT_FOLDER || true
   
   echo 'building image...'
   packer build archlinux.pkr.hcl
fi

echo 'copying image...'
cp "$ARTIFACT" "$VM_IMAGE"

echo 'installing virtual machine...'
virt-install \
   -n $VM_NAME \
   --connect=qemu:///system \
   --description "packer-archlinux" \
   --os-variant=linux2022 \
   --ram=$INSTALL_MEMORY \
   --vcpus=$INSTALL_VCPUS \
   --disk path=$VM_IMAGE,bus=virtio,size=$INSTALL_SIZE \
   --graphics vnc \
   --network $INSTALL_NETWORK \
   --boot hd \
   --import \
   --noreboot \
   --wait 0

if [[ $START_VM -eq 1 ]]; then
   echo 'starting virtual machine...'
   virsh --connect qemu:///system start arch
   
   echo 'gathering virtual machine agent information...'
   echo 'waiting 15 seconds for boot...'
   sleep 15

   virsh --connect qemu:///system guestinfo arch
fi
