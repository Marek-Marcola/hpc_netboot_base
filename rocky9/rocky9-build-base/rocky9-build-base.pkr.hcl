build {
  name = "build.${var.os_dist}-${var.os_ver}-${var.os_id}"

  sources = ["source.qemu.vm-install"]

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

  provisioner "shell" {
    execute_command = "echo '${var.os_pass}'|{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    inline = [
      "set -x",
      "rpm --import /etc/pki/rpm-gpg/*",
      "yum-config-manager --disable '*' > /dev/null",
      "F=/etc/yum.repos.d/rocky-${var.os_ver}.repo",
      "cat <<'EOF' >> $F\n[baseos-${var.os_ver}-dvd1]\nname=baseos-${var.os_ver}-dvd1\nbaseurl=http://${var.os_web}/sw/linux/rocky/${var.os_ver}/x86_64/dvd1/BaseOS\nEOF",
      "cat <<'EOF' >> $F\n[appstream-${var.os_ver}-dvd1]\nname=appstream-${var.os_ver}-dvd1\nbaseurl=http://${var.os_web}/sw/linux/rocky/${var.os_ver}/x86_64/dvd1/AppStream\nEOF",
      "cat <<'EOF' >> $F\n[baseos-${var.os_ver}-os]\nname=baseos-${var.os_ver}-os\nbaseurl=http://${var.os_web}/sw/linux/rocky/${var.os_ver}/x86_64/os/BaseOS\nEOF",
      "cat <<'EOF' >> $F\n[appstream-${var.os_ver}-os]\nname=appstream-${var.os_ver}-os\nbaseurl=http://${var.os_web}/sw/linux/rocky/${var.os_ver}/x86_64/os/AppStream\nEOF",
      "cat <<'EOF' >> $F\n[highavailability-${var.os_ver}-os]\nname=highavailability-${var.os_ver}-os\nbaseurl=http://${var.os_web}/sw/linux/rocky/${var.os_ver}/x86_64/os/HighAvailability\nEOF",
      "cat <<'EOF' >> $F\n[crb-${var.os_ver}-os]\nname=crb-${var.os_ver}-os\nbaseurl=http://${var.os_web}/sw/linux/rocky/${var.os_ver}/x86_64/os/CRB\nEOF",
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
