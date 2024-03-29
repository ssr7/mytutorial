## Installation note
- Install `ansible-core`
````bash
$> sudo pip install ansible-core 
````
- Install 3 virtual machine
- OS is AlmaLinux 9.2 minimal
- Install `ansible.posix` for ansible to enable some modules
````bash
$>  ansible-galaxy collection install ansible.posix
````
- You can serup cluster with none root user. please read this (link)[https://buildvirtual.net/deploy-a-kubernetes-cluster-using-ansible/]
- We use `cri-o` as a container deamon
- Run playbook base order
````bash
ansible-playbook -i myhosts.yml 0...yml
ansible-playbook -i myhosts.yml 1...yml
ansible-playbook -i myhosts.yml 2...yml
ansible-playbook -i myhosts.yml 3...yml
````
- We use `nfs` solution for sharing files. So if you need to mount a shared mount point, you need to run: 
````bash
$> systemctl enable nfs-client.target --now
$> mount -t nfs 192.168.10.10:/data/nfs  /mnt/shared
## or add to fstab

$> echo -e  "192.168.10.10:/data/nfs   /mnt/shared  nfs defaults 0 0" >> /etc/fstab
````
