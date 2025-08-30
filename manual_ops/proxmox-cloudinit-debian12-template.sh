#!/bin/bash
# Script to create a clean Debian 12 cloud-init template in Proxmox
# Assumes it is running on /root. TODO: Make it more flexible
# Run this on the Proxmox node as root

set -e

# Variables
VMID=9001
VMNAME="debian-template-12"
STORAGE="vm-storage"
BRIDGE="vmbr0"
IMG_URL="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
IMG_NAME="debian-12-genericcloud-amd64.qcow2"

# Check if VMID already exists
if qm list | awk '{print $1}' | grep -qw "$VMID"; then
  echo "❌ ERROR: VM ID $VMID already exists. Please choose a different ID."
  exit 1
fi

# Check if VM Name already exists
if qm list | awk '{print $2}' | grep -qw "$VMNAME"; then
  echo "❌ ERROR: VM name $VMNAME already exists. Please choose a different name."
  exit 1
fi

# Download the Debian 12 cloud image
echo "Downloading Debian 12 cloud image..."
wget -O $IMG_NAME $IMG_URL

# Install libguestfs-tools if not already installed
echo "Installing libguestfs-tools if needed..."
apt update -y && apt install -y libguestfs-tools

# Customize the image
echo "Customizing the image with virt-customize..."
virt-customize -a $IMG_NAME \
  --install qemu-guest-agent,haveged \
  --update \
  --run-command 'apt upgrade -y' \
  --run-command 'apt autoremove -y' \
  --run-command 'apt clean' \
  --run-command 'cloud-init clean' \
  --run-command 'truncate -s 0 /etc/machine-id' \
  --run-command 'rm -f /var/lib/dbus/machine-id' \
  --run-command "sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config" \
  --run-command "sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config" \
  --run-command "sed -i 's/^#PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config" \
  --run-command "sed -i 's/^PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config" \
  --run-command "systemctl reload sshd"

# Create the new VM
echo "Creating VM $VMNAME with ID $VMID..."
qm create $VMID --name $VMNAME --memory 2048 --cores 2 --net0 virtio,bridge=$BRIDGE --scsihw virtio-scsi-pci

# Import the customized disk
echo "Importing the customized disk..."
qm importdisk $VMID /root/$IMG_NAME $STORAGE

# Attach the imported disk as SCSI
qm set $VMID --scsi0 $STORAGE:vm-$VMID-disk-0

# Set cloud-init drive
qm set $VMID --ide2 $STORAGE:cloudinit

# Set boot options
qm set $VMID --boot c --bootdisk scsi0

# Enable QEMU agent and hotplugging
qm set $VMID --agent enabled=1
qm set $VMID --hotplug disk,network,usb

# (Optional) Enable serial console for troubleshooting
# qm set $VMID --serial0 socket --vga serial0

# Convert VM to template
echo "Converting VM to template..."
qm template $VMID

echo "✅ Template '$VMNAME' with ID '$VMID' successfully created!"
