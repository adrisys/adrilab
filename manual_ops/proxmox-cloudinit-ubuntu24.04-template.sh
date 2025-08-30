#!/bin/bash
# Script to create a clean Ubuntu 24.04 LTS cloud-init template in Proxmox
# Assumes it is running on /root. TODO: Make it more flexible

# Run this on the Proxmox node as root

set -e

# Variables
VMID=9000
VMNAME="ubuntu-template-24.04-LTS"
STORAGE="vm-storage"
BRIDGE="vmbr0"
IMG_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
IMG_NAME="noble-server-cloudimg-amd64.img"

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

# Download the Ubuntu cloud image
echo "Downloading Ubuntu 24.04 LTS cloud image..."
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

# Check if the customized image file exists
if [ ! -f "$(pwd)/$IMG_NAME" ]; then
    echo "❌ Error: Customized image file not found at $(pwd)/$IMG_NAME"
    echo "Available files:"
    ls -la *.img *.qcow2 2>/dev/null || echo "No image files found"
    exit 1
fi

echo "✅ Image file found: $(pwd)/$IMG_NAME"
echo "   File size: $(du -h "$(pwd)/$IMG_NAME" | cut -f1)"

# Create the new VM
echo "Creating VM $VMNAME with ID $VMID..."
qm create $VMID --name $VMNAME --memory 2048 --cores 2 --net0 virtio,bridge=$BRIDGE --scsihw virtio-scsi-pci

# Import the customized disk
echo "Importing the customized disk..."
if ! qm importdisk $VMID "$(pwd)/$IMG_NAME" $STORAGE; then
    echo "❌ Error: Failed to import disk"
    exit 1
fi

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
