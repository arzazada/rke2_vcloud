#cloud-config
groups:
  - ubuntu: [root,sys]
  - devops

users:
  - default
  - name: devops
    primary_group: devops
    groups: sudo
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    lock_passwd: false
    passwd: ${hashed_pass}
  - name: ci-user
    primary_group: ci-user
    groups: sudo
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    lock_passwd: false
    passwd: ${hashed_pass}
manage_etc_hosts: true

write_files:
  - path: /etc/cloud/templates/hosts.debian.tmpl
    content: |
      127.0.0.1 localhost
      127.0.1.1 $fqdn $hostname
%{ for index, endpoint in master_endpoints ~}
      ${endpoint} ${env}-master-node-${index + 1}
%{ endfor ~}
%{ for index, endpoint in worker_endpoints ~}
      ${endpoint} ${env}-worker-node-${index + 1}
%{ endfor ~}



packages:
  - vim

bootcmd:
  - printf "[Resolve]\nDNS=8.8.8.8 8.8.4.4" > /etc/systemd/resolved.conf
  - [ systemctl, restart, systemd-resolved ]

runcmd:
  - [ sh, -c, 'sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config.d/60-cloudimg-settings.conf' ]
  - [ sh, -c, 'sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config' ]
  - [ sh, -c, 'systemctl restart sshd' ]
  - [ sh, -c, 'sudo apt-get update' ]
  - [ sh, -c, 'apt install -y haproxy' ]
  - [ sh, -c, 'systemctl enable --now haproxy' ]
  - [ sh, -c, 'timedatectl set-timezone Asia/Baku' ]