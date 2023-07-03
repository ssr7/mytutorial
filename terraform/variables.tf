variable "proxmox_api_secret_token" {
 description = "Proxmox token api secret key"
 type = string
 default = "API_TOEKN"
}
variable "ssh_key" {
  default = "PUBLIC SSH KEY"
}

variable "vm_count" { 
 description = "count of vm"
 type =  number
 default =  3
 }
variable "vm_name" { 
 description = "name"
 type =  list(string)
 default =  ["master", "worker1" , "worker2"]
 }
variable "target_node" { 
 description = "target_node"
 type =  string 
 default =  "pve"
 }
variable "template_name" { 
 description = "template name"
 type =  string 
 default =  "alma-9-template"
 }
variable "os_type" { 
 description = "os_type"
 type =  string 
 default =  "cloud-init"
 }
variable "cores" { 
 description = "cores"
 type =  number
 default =  2
 }
variable "sockets" { 
 description = "sockets"
 type =  number
 default =  2
 }
variable "full_clone" { 
 description = "full_clone"
 type =  bool 
 default =  true
 }
variable "cpu" { 
 description = "cpu"
 type =  string 
 default =  "host"
 }
variable "memory" { 
 description = "memory"
 type =  number
 default =  4096
 }
variable "scsihw" { 
 description = "scsihw"
 type =  string 
 default =  "virtio-scsi-pci"
 }
variable "bootdisk" { 
 description = "bootdisk"
 type =  string 
 default =  "scsi0"
 }
variable "agent" { 
 description = "agent"
 type =  string 
 default =  1
 }
variable "disk_size" { 
 description = "size"
 type =  string 
 default =  "20G"
 }
variable "disk_type" { 
 description = "type"
 type =  string 
 default =  "virtio"
 }
variable "disk_storage" { 
 description = "storage"
 type =  string 
 default =  "local-lvm"
 }
variable "network_model" { 
 description = "model of network card"
 type =  string 
 default =  "virtio"
 }
variable "network_bridge" { 
 description = "bridge"
 type =  string 
 default =  "vmbr0"
 }
variable "ci_cipassword" { 
 description = "password of default user in cloud init. default user in almalinux 9 is almalinux"
 type =  string 
 default =  "password"
 }
variable "ci_nameserver" { 
 description = "nameservers list"
 type =  string 
 default =  "8.8.8.8"
 }
