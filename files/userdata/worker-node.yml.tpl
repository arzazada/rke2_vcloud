#cloud-config
groups:
  - ubuntu: [root,sys]
  - devops

manage_etc_hosts: true

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


write_files:
  - path: /etc/cloud/templates/hosts.debian.tmpl
    content: |
      127.0.0.1 localhost
      127.0.1.1 $fqdn $hostname
      ${lb_ip} ${env}-rke2.${domain}
%{ for index, endpoint in master_endpoints ~}
      ${endpoint} ${env}-master-node-${index + 1}
%{ endfor ~}
%{ for index, endpoint in worker_endpoints ~}
      ${endpoint} ${env}-worker-node-${index + 1}
%{ endfor ~}


  - path: /etc/rancher/rke2/config.yaml
    permissions: '0755'
    content: |
      token: ${token_secret_key}
      server: https://${env}-rke2.${domain}:9345



packages:
  - vim

bootcmd:
  - printf "[Resolve]\nDNS=8.8.8.8 8.8.4.4" > /etc/systemd/resolved.conf
  - [ systemctl, restart, systemd-resolved ]

runcmd:
  - [ sh, -c, 'sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config' ]
  - [ sh, -c, 'sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config.d/60-cloudimg-settings.conf' ]
  - [ sh, -c, 'systemctl restart sshd' ]
  - [ sh, -c, 'curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=agent INSTALL_RKE2_VERSION=v1.28.3+rke2r2 sh -' ]
  - [ sh, -c, 'sleep 30' ]
  - [ sh, -c, 'systemctl enable --now rke2-agent.service' ]
  - [ sh, -c, 'timedatectl set-timezone Asia/Baku' ]