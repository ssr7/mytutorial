resource "proxmox_vm_qemu" "proxmox_vm" {
  count             = var.vm_count
  name              = var.vm_name[count.index]
  target_node       = var.target_node
  clone             = var.template_name
  os_type           = var.os_type
  cores             = var.cores
  sockets           = var.sockets
  full_clone        = var.full_clone
  cpu               = var.cpu
  memory            = var.memory
  scsihw            = var.scsihw
  bootdisk          = var.bootdisk
  agent             = var.agent
disk {
    size            = var.disk_size
    type            = var.disk_type
    storage         = var.disk_storage
    #storage_type    = "lvm"
    #iothread        = true
  }
network {
    model           = var.network_model
    bridge          = var.network_bridge
  }
lifecycle {
    ignore_changes  = [
      network,
    ]
  }
# Cloud Init Settings
  # defaul linux in alma linux is: almalinux
  cipassword= var.ci_cipassword
  ipconfig0 = "ip=172.16.0.${count.index + 3}/24,gw=172.16.0.254"
  nameserver = var.ci_nameserver
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}




## config for LXC 


#  count        = 3
#  target_node  = "pve"
#  cores        = 4
#  sockets      = "1"
##  hostname     = "hostname"
##  ostemplate  = "local:vztmpl/rockylinux-8-default_20210929_amd64.tar.xz"
# # Set the CD-ROM drive to use the ISO image
#  cdrom {
#    file = "local:iso/AlmaLinux-9-latest-x86_64-minimal.iso"
#  }
#  password     = "pass"
#  unprivileged = true
#  ostype       = "centos"
#  memory       ="4096"
#  # Terraform will crash without rootfs defined
#  rootfs {
#    storage = "local-lvm"
#    size    = "20G"
#    storage_type    = "lvm"
#
#  }
#ssh_public_keys = <<-EOT
#  ${var.ssh_key}
#  EOT
#
#  network {
#    name   = "eth0"
#    bridge = "vmbr0"
#    ip     = "172.16.1.${count.index+33}/24,gw=172.16.1.254"
#  }
#}
#
