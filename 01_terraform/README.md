## Terraform
Provision Proxmox VMs, networks, and cloud-init using Terraform.
- Use `main.tf` to define your infrastructure.
- Separate vars and environment overrides as needed.





Here’s a detailed step-by-step guide to creating an Ubuntu Proxmox VM template with network access, provisioning it for Terraform, and converting it into a reusable template.

⸻

🧱 1. Create a New VM in Proxmox
	1.	Download an Ubuntu Cloud Image (preferably minimal cloud-init ready):

wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img


	2.	Convert the image to a Proxmox-compatible format:

qm create 9000 --name ubuntu-template --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9000 jammy-server-cloudimg-amd64.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --boot c --bootdisk scsi0


	3.	Attach cloud-init drive:

qm set 9000 --ide2 local-lvm:cloudinit


	4.	Configure cloud-init settings:

qm set 9000 --ciuser ubuntu --cipassword 'yourpassword'
qm set 9000 --ipconfig0 ip=dhcp



⸻

🛠 2. Install Software and Prepare the Template
	1.	Start the VM and connect:

qm start 9000
qm terminal 9000


	2.	Login with the cloud-init user (ubuntu) and install software:

sudo apt update && sudo apt upgrade -y
sudo apt install -y qemu-guest-agent curl unzip


	3.	Enable qemu-guest-agent:

sudo systemctl enable qemu-guest-agent


	4.	(Optional) Install SSH keys or Terraform dependencies if needed:

mkdir -p ~/.ssh
echo "your-public-key" > ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys


	5.	Clean up to keep the image light:

sudo cloud-init clean
sudo apt clean
sudo rm -rf /var/lib/cloud/*



⸻

📦 3. Convert the VM into a Template
	1.	Shutdown the VM:

qm shutdown 9000


	2.	Convert to a template:

qm template 9000



Now you have a cloud-init enabled Ubuntu VM template ready for use with Terraform.

⸻

🤖 4. Use with Terraform

Example Terraform snippet to deploy from the template:

resource "proxmox_vm_qemu" "ubuntu_vm" {
  name        = "vm-${count.index}"
  target_node = "proxmox-node"
  clone       = "ubuntu-template"
  cores       = 2
  memory      = 2048
  count       = 1

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  ipconfig0 = "ip=dhcp"

  sshkeys = file("~/.ssh/id_rsa.pub")
}



⸻

✅ Best Practices
	•	Always install qemu-guest-agent to allow Proxmox to properly interact with the VM.
	•	Use cloud-init to make your VMs dynamic and easily customizable.
	•	Test networking with ping, and ensure your vmbr0 bridge is correctly configured.

⸻

Let me know if you’d like to automate more steps or need a cloud-init config example!