[master]
k8s-master ansible_host=${master_ip}

[workers]
%{ for name, ip in worker_ips ~}
${name} ansible_host=${ip}
%{ endfor ~}

[k8s:children]
master
workers

[k8s:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
