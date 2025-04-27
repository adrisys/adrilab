vm_count       = 3
vm_name        = "cloudinit-test"
vm_description = "A test VM with cloud-init configured"
target_node    = "pve"
clone_template = "ubuntu-template-24.04-LTS"

cores   = 2
sockets = 1
vcpus   = 0
memory  = 2048

cloudinit_storage = "local-lvm"
disk_size         = 32
disk_cache        = "writeback"
disk_storage      = "local-lvm"
disk_replicate    = true

network_model  = "virtio"
network_bridge = "vmbr0"
network_tag    = 50

ipconfig0       = "ip=dhcp"
ssh_public_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5kvBKOfHoTWcE1w/fLVpjrAP/iPn9hMrQKpq49eacp26NZeK0DNyCRMn7glBNWtEs8wBuqRaYkAacU6OTh/CMZTBpFJHejlOPkWt2IwWnq6UI2uKsd6PLzFUo12BJXlJWCxg+dohUO46SX5mhrv+SUdgJwzTfHsXvCbJXhZJSUZflUd1R5BUpm2ospw3Kpf8Rvzg4KxaI8RfyqvgcPZIxMH3F1M39jygJvfigdBzhRe9oJ0y2FQ/yzpfkab7UetoV/2KHbr9By1Evd6xLxFk/3rCuuOqdxcf1EnHKErlt3H+SZrOdns3FWhfD4iSgKQaMW4QvEqRmF8QWssguD90T7AgD/YJ8yvwSsqaX4jFVUF3RbOh1vWYkjv3iDfZUwPEuUVBm0sEXTYaVMfQmjLBprxFEvOrux28D9o5lJW3p1bPvaMsfe55OBXlVyzk5sq/Ry4Bi6Aq6iEBJbf3/13l0Un4Kv8hQB1i/S5vb4FNWk8/BAzvJ7N97VvwotRmYkzCPiH0NkZCjWAItHq2ykVkVyMSctBojrQSMVKjPPEgTING7UXFeFxMPKwwq38BrY1qgHIB4BID/uZTDVc00t7Hn+puo6ytbn+K5aYYWVzeyoYIAV7SPbiy7FcEO7hzEbUZrAje6WKyFRLLrbDGanVnlu524fGCL+ZgC7DmdTzQbPw== adrian.navarro@outlook.com"

ciuser     = "adri"
cipassword = "adri"
