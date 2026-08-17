build {
  name = "build.${var.os_dist}-${var.os_ver}-${var.os_id}"

  sources = ["source.qemu.vm-upgrade"]

  provisioner "shell" {
    execute_command = "echo '${var.os_pass}'|{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    inline = [
      "set -x",
      "mkdir -pv /version.d",
      "F=/version.d/version-${var.os_dist}-${var.os_ver}-${var.os_id}.txt",
      "echo info.date = $(date +%Y-%m-%d_%H:%M:%S) > $F",
      "echo info.name = ${var.os_dist}-${var.os_ver}-${var.os_id} >> $F",
      "echo info.from = ${var.os_dist}-${var.os_ver}-${var.os_from} >> $F"
    ]
  }

  provisioner "ansible" {
    user             = "${var.os_user}"
    extra_arguments  = ["-e","h=default","-e","ansible_ssh_pass=${var.os_pass}","-b","-e","p=dracut-network,nfs-utils,readonly-root"]
    playbook_file    = "${var.os_anpb}/playbooks/001500-linux_admin/yum_install.yml"
  }
  provisioner "ansible" {
    user             = "${var.os_user}"
    extra_arguments  = ["-e","h=default","-e","ansible_ssh_pass=${var.os_pass}","-b"]
    playbook_file    = "${var.os_anpb}/playbooks/001580-rocky9/rocky9_nfs_postinstall.yml"
  }

  provisioner "shell" {
    execute_command = "echo '${var.os_pass}'|{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    expect_disconnect = true
    pause_before      = "10s"
    timeout           = "10s"
    inline = [
      "set -x",
      "echo 'require host-name, root-path;' >> /usr/lib/dracut/modules.d/40network/dhclient.conf",
      "echo 'hostonly=no' > /etc/dracut.conf.d/hostonly.conf",
      "echo 'add_dracutmodules+=nfs' > /etc/dracut.conf.d/module_nfs.conf",
      "dracut --force",
      "cd /boot",
      "chmod a+r vmlinuz-*",
      "chmod a+r initramfs-*",
      "ln -snfv vmlinuz-$(uname -r) vmlinuz-default",
      "ln -snfv initramfs-$(uname -r).img initramfs-default",
      "reboot"
    ]
  }
  provisioner "shell" {
    execute_command = "echo '${var.os_pass}'|{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    expect_disconnect = true
    pause_before      = "10s"
    timeout           = "10s"
    inline = [
      "set -x",
      "yum -y remove setroubleshoot-server",
      "systemctl disable --now pmcd pmie pmlogger pmlogger_farm firewalld man-db-restart-cache-update"
    ]
  }

  provisioner "shell-local" {
    inline = [
      "set -x",
      "echo ${var.os_date} > ${var.os_out}/${var.os_dist}-${var.os_ver}-${var.os_id}/${var.os_dist}-${var.os_ver}-x86_64.date"
    ]
  }

  post-processors {
    post-processor "checksum" {
      checksum_types = ["sha1"]
      output = "${var.os_out}/${var.os_dist}-${var.os_ver}-${var.os_id}/${var.os_dist}-${var.os_ver}-x86_64.txt"
    }
  }
}
