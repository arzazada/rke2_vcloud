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
    passwd:  ${hashed_pass}

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
      tls-san:
        - ${env}-rke2.${domain}
        - ${lb_ip}
%{ for index, endpoint in master_endpoints ~}
        - ${env}-master-node-${index + 1}
        - ${endpoint}
%{ endfor ~}
      write-kubeconfig-mode: "0600"
      cluster-cidr: ${cluster_cidr}
      service-cidr: ${service_cidr}
      kube-apiserver-arg:
        - '--enable-admission-plugins="DefaultTolerationSeconds"'
        - '--default-not-ready-toleration-seconds=10'
        - '--default-unreachable-toleration-seconds=10'
      kube-controller-manager-arg:
        - '--node-monitor-period=2s'
        - '--node-monitor-grace-period=16s'


packages:
  - vim

bootcmd:
  - printf "[Resolve]\nDNS=8.8.8.8 8.8.4.4" > /etc/systemd/resolved.conf
  - [ systemctl, restart, systemd-resolved ]

runcmd:
  - [ sh, -c, 'sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config.d/60-cloudimg-settings.conf' ]
  - [ sh, -c, 'sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config' ]
  - [ sh, -c, 'systemctl restart sshd' ]
  - [ sh, -c, 'curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=v1.28.3+rke2r2 sh -' ]
  - [ sh, -c, 'sleep 30' ]
  - [ sh, -c, 'systemctl enable --now rke2-server.service' ]
  - [ bash, -c, 'echo "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml" >> ~/.bashrc' ]
  - [ bash, -c, 'echo "export PATH=$PATH:/var/lib/rancher/rke2/bin/" >> ~/.bashrc' ]
  - [ bash, -c, 'echo alias k="kubectl" >> ~/.bashrc' ]
  - [ sh, -c, 'timedatectl set-timezone Asia/Baku' ]