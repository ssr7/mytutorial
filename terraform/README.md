# Provision virtual machine for k8s environment in Proxmox
- Auto provision for installing 3 vm in proxmox for k8s. 
- Cloud-Init is necessary
## Make template
- You need to download generic almalinux 9 file and convert it to template in the Proxmox
````bash
$> ssh proxmox-server
$> wget https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-9.2-20230513.x86_64.qcow2
$> qm create 999  --name "alma-9-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
$> qm importdisk 999 AlmaLinux-9-GenericCloud-9.2-20230513.x86_64.qcow2  local-lvm  --format qcow2
$> qm set 999  --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-999-disk-0
$> qm set 999 --boot c --bootdisk scsi0
$> qm set 999 --serial0 socket --vga serial0
$> qm set 999  --ide2 local-lvm:cloudinit
$> qm set 999 --agent enabled=1
$> qm set 999 --cpu host # because of redhat 9 changes 
$> qm template 999
````
## Create API token
````bash
$> ssh proxmox-server
$> pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt"
$> pveum user add terraform-prov@pve --password <password>
$> pveum aclmod / -user terraform-prov@pve -role TerraformProv
$> pveum user token add tfuser@pve terraform --privsep 0   # save token  and set in variables.tf 
````

## Variables.tf
- Please update some variables according to your environment like: 
- `ssh_key` 
- `proxmox_api_secret_token`
- `ci_cipassword`
- `ci_nameserver`
- Also you use shell variable for some variables.  more info at  [terraform doc](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
````bash
export PM_API_TOKEN_ID="terraform-prov@pve!mytoken"
export PM_API_TOKEN_SECRET="afcd8f45-acc1-4d0f-bb12-a70b0777ec11"
````

## providers.tf
- Please set `PROXMOX-URL`

## Main.tf
- Please change some variables like ip address

## Run 
- You need to install terraform on your host  [Install terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli))
- Run below commands:
````bash
$> terraform init
$> terraform plan
$> terraform apply
````
