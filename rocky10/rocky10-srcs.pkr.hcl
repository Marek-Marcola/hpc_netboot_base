source "qemu" "vm-install" {
  accelerator      = "kvm"
  cpu_model        = "host"
  boot_command     = ["<up><wait>","e","<down><down><down><left>"," inst.cmdline inst.text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/ks-${var.os_dist}-10.cfg net.ifnames=0 biosdevname=0 <f10>"]
  boot_wait        = "10s"
  cpus             = "${var.vm_cpu}"
  memory           = "${var.vm_mem}"
  disk_size        = "${var.vm_disk}"
  format           = "qcow2"
  headless         = true
  http_directory   = "http"
  disk_image       = "false"
  iso_checksum     = "file:${var.os_sum}"
  iso_url          = "${var.os_iso}"
  output_directory = "${var.os_out}/${var.os_dist}-${var.os_ver}-${var.os_id}"
  shutdown_command = "echo '${var.os_pass}'|sudo -S shutdown -P now"
  ssh_username     = "${var.os_user}"
  ssh_password     = "${var.os_pass}"
  ssh_wait_timeout = "30m"
  vm_name          = "${var.os_dist}-${var.os_ver}-x86_64.qcow2"
}

source "qemu" "vm-upgrade" {
  accelerator      = "kvm"
  cpu_model        = "host"
  boot_wait        = "10s"
  cpus             = "${var.vm_cpu}"
  memory           = "${var.vm_mem}"
  disk_size        = "${var.vm_disk}"
  format           = "qcow2"
  headless         = true
  disk_image       = "true"
  iso_checksum     = "file:${var.os_sum}"
  iso_url          = "${var.os_iso}"
  output_directory = "${var.os_out}/${var.os_dist}-${var.os_ver}-${var.os_id}"
  shutdown_command = "echo '${var.os_pass}'|sudo -S shutdown -P now"
  ssh_username     = "${var.os_user}"
  ssh_password     = "${var.os_pass}"
  ssh_wait_timeout = "30m"
  vm_name          = "${var.os_dist}-${var.os_ver}-x86_64.qcow2"
}
