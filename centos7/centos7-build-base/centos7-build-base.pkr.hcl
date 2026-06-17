build {
  name = "build.${var.os_dist}-${var.os_ver}-${var.os_id}"

  sources = ["source.qemu.vm-install"]

  provisioner "shell" {
    execute_command = "echo '${var.os_pass}'|{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    inline = [
      "set -x",
      "mkdir -p /version.d",
      "F=/version.d/version-${var.os_dist}-${var.os_ver}-${var.os_id}.txt",
      "echo info.date = $(date +%Y-%m-%d_%H:%M:%S) > $F",
      "echo info.name = ${var.os_dist}-${var.os_ver}-${var.os_id} >> $F",
      "echo info.from = ${var.os_dist}-${var.os_ver}-${var.os_from} >> $F"
    ]
  }

  provisioner "shell" {
    execute_command = "echo '${var.os_pass}'|{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    inline = [
      "set -x",
      "sed -i '/^HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth0",
      "rpm --import /etc/pki/rpm-gpg/*",
      "yum-config-manager --disable '*' > /dev/null",
      "F=/etc/yum.repos.d/centos-${var.os_ver}.repo",
      "cat <<'EOF' >> $F\n[everything-${var.os_ver}]\nname=everything-${var.os_ver}\nbaseurl=http://${var.os_web}/sw/linux/centos/${var.os_ver}/x86_64/install-dvd2\nEOF",
      "cat <<'EOF' >> $F\n[updates-${var.os_ver}]\nname=updates-${var.os_ver}\nbaseurl=http://${var.os_web}/sw/linux/centos/${var.os_ver}/x86_64/updates\nEOF",
      "yum -q clean all"
    ]
  }

  provisioner "ansible" {
    user             = "${var.os_user}"
    extra_arguments  = ["-e","h=default","-e","ansible_ssh_pass=${var.os_pass}","-b"]
    playbook_file    = "${var.os_anpb}/playbooks/999202-bdev/bdev_postinstall_image.yml"
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
