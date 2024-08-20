
resource "null_resource" "ansible_haproxy_config" {
  count = local.ha_enabled ? 1 : 0

  provisioner "local-exec" {
    command = "ansible-playbook ${path.root}/files/ansible/haproxy-config-playbook.yaml -i '${var.cp_lb_ip},'"

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ANSIBLE_REMOTE_USER       = var.ansible_user
      ANSIBLE_PASSWORD          = var.ansible_password
      MASTER_ENDPOINTS      = join(",", local.master_endpoints)
      JINJA_TEMPLATE            = "${path.cwd}/files/loadbalancer/haproxy-control-plane-lb.conf.j2"
    }
  }

  triggers = {
    nodes = md5(join(",", local.master_endpoints))
  }


  depends_on = [vcd_vapp_vm.haproxy_lb]
}